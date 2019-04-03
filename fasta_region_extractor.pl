#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';
use List::Util qw[min max];

# Help message
my $help_str = 	"
-------------------------------------------------------------------------------------


Fasta region extractor: Extract a region of a fasta sequence.
				
Usage:
	fasta_region_extractor.pl <fasta file> <reference name> <0-based start> <0-based exclusive end> <outfile>
					
Example:
	fasta_region_extractor.pl hg38.fa chr1 1000000 2000000 hg38_chr1_1000000_2000000.fa
				
				
-------------------------------------------------------------------------------------
				
";

# Get parameters from command line
die_with_message("Incorrect number of arguments") if @ARGV != 5;
my $infile = $ARGV[0];
my $ref = $ARGV[1];
my $start = int $ARGV[2];
my $end = int $ARGV[3];
my $outfile = $ARGV[4];

# Don't overwrite output file
die_with_message("File exists: $outfile") if -e $outfile;

# Read the input file line by line and build up the extracted sequence
open(my $reader, $infile) or die("\nCould not open $infile:\n$!");
my $line_start = 0;
my $line_end = 0;
my $in_ref = 0;
my $region_seq = "";
while (my $row = <$reader>) {
	chomp $row;
	if($in_ref) {
		# Update line coordinates
		$line_start = $line_end;
		$line_end = $line_start + length($row);
		# Break if got entire sequence
		if ($line_start >= $end) {last;}
		# Check that we haven't run out of this reference sequence
		die("\n\nError: encountered next reference sequence $row before getting enough of sequence $ref\n\n") if $row =~ /^>/;
		# Add more sequence if applicable
		$region_seq = $region_seq . extract_overlap($row, $line_start, $line_end, $start, $end)
	}
	if($row =~ /^>${ref}$/) {
		$in_ref = 1;
	}
}
# Die if never found the reference sequence
$in_ref or die("\nNo reference sequence \"$ref\"\n\n");

# Write the output
open(my $writer, '>', $outfile) or die("\nCould not open $outfile:\n$!");
print $writer ">" . $ref . "_" . $start . "_" . $end . "\n";
my $written_line_end = 0;
my $fasta_line_size = 80;
while ($written_line_end < length($region_seq)) {
	print $writer substr($region_seq, $written_line_end, $fasta_line_size) . "\n";
	$written_line_end += $fasta_line_size;
}
close $writer;
close $reader;
print("\n\nAll done!\n\n");



##### Subroutines #####

# Die with helpful message
# Args:
#	1. Short detail message to add to larger template
sub die_with_message {
	my $mssg = shift;
	die("\n\n********** $mssg **********\n\n$help_str");
}

# Get the part of an overlap that is contained in a subsequence of an overall sequence.
# For example, get the part of a desired chromosome region that is contained in one line
# of a fasta file when you know where the line is situated within the full reference sequence
#
# Args:
#   1. Sequence
#   2. Zero-based coordinate for first position of sequence
#   3. Zero-based exclusive end coordinate of sequence
#   4. Zero-based start position of overlap to extract from overall sequence
#   5. Zero-based exclusive end position of overlap to extract from overall sequence
#
# Returns:
#   The part of the sequence or "" if desired overlap does not overlap the declared span of the sequence
sub extract_overlap {
	my $seq = shift;
	my $seq_begin = shift;
	my $seq_end = shift;
	my $overlap_start = shift;
	my $overlap_end = shift;
	
	if($overlap_start < $seq_end && $overlap_end > $seq_begin) {
		my $extract_start = max(0, $overlap_start - $seq_begin);
		my $extract_end = min(length($seq), $overlap_end - $seq_begin);
		my $extract_len = $extract_end - $extract_start;
		return substr $seq, $extract_start, $extract_len;
	}
	else {return ""};
}


