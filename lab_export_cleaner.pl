################################################################################################
##
##   Lab Export Cleaner               Inigo San Gil, Feb 2021
##
##   Description:    A program that cleans spurious characters from the Mq Labs Export File
##                   Input: comma delimited, Output: commad delimited file named like the original file
##
##   to use:  either invoke perl  lab_export_cleaner.pl  
##
##   Requirements:  Source file names need to be named mq_yesterdays_labs_temp.csv
##   
##   Output: Filenames the same as source, but removed "_temp".
##
##   Desgined for Windows, but should run OK on Nix, MacOS too (untested on those environs)
##
##
################################################################################################

use strict;
my $file    = 'D:\\Minivelos\\Sources\\mq_yesterdays_labs_temp.csv';
my $outfile = 'D:\\Minivelos\\Sources\\mq_yesterdays_labs.csv'; 
my $line;
 
open(DOC, "$file")      or die("Error opening $file $!\n");
open(FOUT, ">$outfile") or die "Could not write out your comma delimited file \n";

while ($line = <DOC>){

$line =~ s/\x92//g;
print "$line";
print FOUT "$line";
}
close(DOC);
close(FOUT);
