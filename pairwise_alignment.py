import argparse

from Bio import SeqIO
from Bio import pairwise2


parser = argparse.ArgumentParser(description = """
pairwise_alignment.py
 
This program performs a pairwise global alignment between
two sequences in a fasta file.
""")
parser.add_argument('--fasta', action = 'store', dest = 'fasta', required = True, help = 'Fasta file containing two nucleotide sequences')
args = parser.parse_args()

# Read the two sequences
fasta = args.fasta
seqs = list(SeqIO.parse(fasta, "fasta"))
if(len(seqs)) is not 2:
    raise ValueError("Fasta file must contain exactly two sequences")
seq1 = seqs[0].seq
seq2 = seqs[1].seq
name1 = seqs[0].id
name2 = seqs[1].id

align = pairwise2.align.globalxx(seq1, seq2, one_alignment_only = True)


print(align[0])