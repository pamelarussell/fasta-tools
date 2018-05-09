#!/usr/bin/perl

use strict;
use warnings;

# Help message
my $help_str = 	"\n-------------------------------------------------------------------------------------\n\n" .
				"Fasta sequence extractor:\nExtract full fasta sequences whose headers match a given pattern.\n\n" .
				"Usage:\nfasta_seq_extractor.pl <fasta file> <pattern to match in fasta header> <outfile>\n\n" .
				"Example:\nfasta_seq_extractor.pl gencode.fa TUG1-[0-9]+ tug1.fa" .
				"\n-------------------------------------------------------------------------------------\n\n";

# Get parameters from command line
my $infile = $ARGV[0] or die_with_message("Missing argument: input fasta file");
my $pattern = $ARGV[1] or die_with_message("Missing argument: pattern");
my $outfile = $ARGV[2] or die_with_message("Missing argument: output fasta file");

# Don't overwrite output file
die_with_message("File exists: $outfile") if -e $outfile;

# Die with helpful message
# Args:
#	1. Short detail message to add to larger template
sub die_with_message {
	my $mssg = shift;
	die("\n\n********** $mssg **********\n\n$help_str");
}

# Read the input file line by line
open(my $reader, $infile) or die("\nCould not open $infile:\n$!");
open(my $writer, '>', $outfile) or die("\nCould not open $outfile:\n$!");
my $write_curr = 0; # Boolean whether to write the current line to outfile
while (my $row = <$reader>) {
	chomp $row;
	$write_curr = ($row =~ $pattern) if $row =~ /^>/;
	print $writer "$row\n" if $write_curr;
}
close $writer;
close $reader;

print("\n\nAll done!\n\n")

