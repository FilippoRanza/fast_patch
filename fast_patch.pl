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
    my %out;
    if (-f $DEF_MACRO_FILE){
        open my $fp, $DEF_MACRO_FILE || die "$!";
        while(<$fp>){

            if(/^$/ or /^#/){
                next;
            }

            if (/^(.+)\s+'(.+)'$/ or /^(.+)\s+"(.+)"$/){
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



sub patch{
    (my $in, my $out) = @_;

    my %macros = load_marco;
    my $ps = 0;
    while(<$in>){

        $ps = 1 if(/\\begin\{align|equation(.+)?\}/);
        $ps = 0 if(/\\end\{align|equation(.+)?\}/);
        if($ps){
            s|(\\left)?\(|\\left\(|g;
            s|(\\right)?\)|\\right\)|g;

            s|(\\left)?\[|\\left\[|g;
            s|(\\right)?\]|\\right\]|g;

            s/\\\|([^\|]+)\\\|/\\norm\{$1\}/g;
            s/\|([^\|]+)\|/\\abs\{$1\}/g;

        }

        for my $k (keys %macros){
            s|$k|$macros{$k}|g;
        }

        print {$out} $_;
    }
}

sub run_patch{
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
