# fast_patch
Automatically refactor Latex code

## Usage
```
    [perl] fast_patch.pl latex_file [...]
```
This script modify *inplace* all given latex files. The update version
has the ORIGINAL name while a backup version is also created. Backup is
named ORIGINAL.bak . ORIGINAL is the name of the current input file.


### MACRO
User can optionally add a file named *macro.txt* into the working directory.
In this file the user can specify some macros the fast_patch.pl will add
to each line. The user must pay attention to the macro names: if a name
collides a latex command this will be overwritten.

#### macro.txt format
*macro.txt* is a line based file, each line contains a macro:

a macro has the following format
```
    NAME 'VALUE'
```
or
```
    NAME "VALUE"
```

fast_patch.pl will search for each occurrence of each *NAME* and replace
it with the proper *VALUE*.

Lines that starts with '#' are considerd comments and are ignored.
 
