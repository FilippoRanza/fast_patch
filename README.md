# fast_patch
Automatically refactor Latex code

## Usage
```
    [perl] fast_patch.pl latex_file [...]
```
This script modify *inplace* all given latex files. The update version
has the ORIGINAL name while a backup version is also created. Backup is
named ORIGINAL.bak . ORIGINAL is the name of the current input file.

### Command Line Options
    --verbose  : enables verbose mode



### Refactor Notes
fast_patch.pl automatically modifies file inplace. It starts from a
**correct** latex file an make it better:
1. Properly indent each block
2. Converts each  perenthesis inside an *equation* or *align* block
    into its equivalent with  *\left* or *\rigth*:

    ( for example becomes \left(

3. Apply given *MACROs*

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
