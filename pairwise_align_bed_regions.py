import argparse

from Bio import SeqIO
from Bio import pairwise2
from Bio.SubsMat import MatrixInfo as matlist
from Bio.pairwise2 import format_alignment

import pybedtools

# Program description
parser = argparse.ArgumentParser(description = """
pairwise_align_bed_regions.py
 
This program first extracts the sequence from a fasta file
for each record in a bed file, then performs a pairwise alignment
between each pair of sequences. For each pair of sequences, does
three alignments: the original sequences, the complement of
sequence 2, and the reverse complement of sequence 2.
""")

# Parse the command line
parser.add_argument('--bed', action = 'store', dest = 'bed', required = True, help = 'BED file with one record per sequence to align')
parser.add_argument('--fasta', action = 'store', dest = 'fasta', required = True, help = 'Fasta file containing reference sequences')
parser.add_argument('--min-len', action = 'store', type = int, dest = 'min_len', required = False, default = 0,
                    help = 'Minimum sequence length to perform any alignments')
args = parser.parse_args()
bed = args.bed
fasta = args.fasta
min_len = args.min_len

# Use bedtools to extract sequences from fasta
bt = pybedtools.bedtool.BedTool(bed)
tmp_seqs = bt.sequence(fi = fasta)
seq_records = list(SeqIO.parse(open(bt.seqfn), 'fasta'))
num_seqs = len(seq_records)

# Extract the alignment score from a biopython alignment object
def get_score(align):
    return align[2]

# Align two sequences with biopython pairwise align
def align(seq1, seq2):
    return pairwise2.align.localms(seq1, seq2, 2, -1, -0.5, -0.1)

# Align and pretty print
def print_align(seq1, seq2, seq1_name, seq2_name):
    print("\n")
    print("Seq 1: %s" % seq1_name)
    print("Seq 2: %s" % seq2_name)
    print("")
    aligns = align(seq1, seq2)
    print(format_alignment(*aligns[0]))
    print("")

# Do the alignments
for i in range(0, num_seqs - 1):
    for j in range(i + 1, num_seqs):
        seq_rec1 = seq_records[i]
        seq_rec2 = seq_records[j]
        seq1_name = seq_rec1.name
        seq2_name = seq_rec2.name
        seq1 = seq_rec1.seq
        seq2 = seq_rec2.seq
        seq2c = seq2.complement()
        seq2rc = seq2.reverse_complement()
        if(len(seq1) > min_len and len(seq2) > min_len):
            print_align(seq1, seq2, seq1_name, seq2_name)
            print_align(seq1, seq2c, seq1_name, "%s_complement" % seq2_name)
            print_align(seq1, seq2rc, seq1_name, "%s_reverse_complement" % seq2_name)


