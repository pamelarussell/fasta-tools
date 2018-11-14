#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;

# Help message
my $help_str = 	"\n-------------------------------------------------------------------------------------\n\n" .
				"Fasta sequence extractor:\nExtract full fasta sequences whose headers match a given pattern.\n\n" .
				"Options:\n" .
				"-h: print help menu and exit\n" .
				"-f <required>: input fasta file\n" .
				"-p: pattern to match in sequence headers\n" .
				"-l: file containing list of sequence headers to keep\n" .
				"-o <required>: output fasta file\n" .
				"Must provide at least one of -p and -l.\n" .
				"\nExample:\nfasta_seq_extractor.pl -f gencode.fa -p TUG1-[0-9]+ -o tug1.fa" .
				"\n-------------------------------------------------------------------------------------\n\n";

# Get parameters from command line
my %options = ();
getopts("hf:p:l:o:", \%options);
die_with_message("Help menu") if defined $options{h};
my $infile = $options{f};
my $pattern = $options{p};
my $listfile = $options{l};
my $outfile = $options{o}; 
die_with_message("Missing required argument") if not defined $infile or not defined $outfile;


# Don't overwrite output file
die_with_message("File exists: $outfile") if -e $outfile;


# Die with helpful message
# Args:
#	1. Short detail message to add to larger template
sub die_with_message {
	my $mssg = shift;
	die("\n\n********** $mssg **********\n\n$help_str");
}


# Read list of sequence headers into array
my @seqids;
if(defined $listfile) {
	open(my $fh, "<", $listfile) or die "Failed to open file: $listfile";
	while(<$fh>) {
		chomp;
		push @seqids, $_;
	}
	close $fh;
}


# Read the input file line by line
print("\nReading sequences from $infile...\n");
open(my $reader, $infile) or die("\nCould not open $infile:\n$!");
open(my $writer, '>', $outfile) or die("\nCould not open $outfile:\n$!");
my $write_curr = 0; # Boolean whether to write the current line to outfile
my $num_written = 0;
while (my $row = <$reader>) {
	chomp $row;
	if($row =~ /^>/) {
		my $seqid = $row;
		$seqid =~ s/^>//g;
		$write_curr = 0;
		$write_curr = 1 if defined $pattern && $seqid =~ $pattern;
		$write_curr = 1 if (grep { $_ eq $seqid } @seqids);
        $num_written = $num_written + $write_curr;
	}
	print $writer "$row\n" if $write_curr;
}
close $writer;
close $reader;


print("\nWrote $num_written sequences to file $outfile.\n");
print("\nAll done!\n\n")



