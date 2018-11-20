#! /usr/bin/perl

#
#   fast_patch.pl - Automatically refactor Latex code
#
#   Copyright (c) 2018 Filippo Ranza <filipporanza@gmail.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.


use warnings;
use strict;

use File::Temp qw/ tempfile tempdir /;
use File::Copy qw/ move /;

my $DEF_MACRO_FILE = 'macro.txt';


sub load_marco{
    # open and parse macro.txt
    # this file contains some optinal
    # macros. Those macros will be applied
    # by patch on each line.
    my %out;
    if (-f $DEF_MACRO_FILE){
        open my $fp, $DEF_MACRO_FILE || die "$!";
        while(<$fp>){
            # ignore empty lines or line that starts with #
            if(/^$/ or /^#/){
                next;
            }
            # macros are in this format:
            # MACRO_NAME 'text_to_substitute' or
            # MACRO_NAME  "text_to_substitute"
            if (/^(.+)\s+'(.+)'$/ || /^(.+)\s+\"(.+)"$/){
                $out{$1} = $2;
            }
            else{
                die "Error in $DEF_MACRO_FILE\n$_ doesn't match MACRO 'VALUE' format";
            }
        }
        close $fp;
    }
    return %out;
}

sub indent_print{
    # adjust code indetation, and print
    # each latex block content is indent by
    # one more \t
    (my $i, my $out, my $c) = @_;

    unless ($c) {
      $i-- if(/\\end\{.+\}/);
    }

    my $indent = "\t" x $i;
    s|^(\s*)(.+)$|$indent$2|;
    print {$out} $_;

    unless ($c) {
      $i++ if(/\\begin\{.+\}/);
    }

    return $i;
}

sub refactor_equation{
  # refactor the content of a align or equation block

  # set \letf and \right to all parenthesis
  s|(\\left)?\(|\\left\(|g;
  s|(\\right)?\)|\\right\)|g;

  s|(\\left)?\[|\\left\[|g;
  s|(\\right)?\]|\\right\]|g;

  # convert each || into \abs{} and each \|\| into \norm{}
  s/\\\|([^\\\|]+)\\\|/\\norm\{$1\}/g;
  s/\|([^\|]+)\|/\\abs\{$1\}/g;

}

sub patch{
    (my $in, my $out) = @_;

    my %macros = load_marco;
    my $ps = 0;
    my $indent = 0;
    while(<$in>){

        # skip comments
        if(/^\s*%.*/){
          # avoid block check on comments,
          # just print them with current indetation
          $indent = indent_print $indent, $out, 1;
          next;
        }

        # check if the line is inside  an 'align'/'equation' block
        # support nested align/equation(probably not supported by Latex)
        $ps++ if(/\\begin\{align|equation(.+)?\}/);
        $ps-- if(/\\end\{align|equation(.+)?\}/);

        # if the line is inside an 'align'/'equation' block
        if($ps){
          refactor_equation;
        }

        # apply externally defined macros
        for my $k (keys %macros){
            s|$k|$macros{$k}|g;
        }

        $indent = indent_print $indent, $out;
    }
}


sub run_patch{
    # run the automatic refactor on
    # each input file:
    # open the file for reading, a temp file as
    # output, call 'patch'
    # then renames the input as ORIGINAL.bak
    # and the temp as ORIGINAL
    (my $in_name) = @_;
    open my $in, $in_name || die "$!";
    (my $out, my $out_name) = tempfile();

    patch $in, $out;

    close $in;
    close $out;

    move $in_name, "$in_name.bak" || print $!;
    move $out_name, "$in_name" || print $!;

}



foreach my $arg (@ARGV){
    run_patch $arg;
}
