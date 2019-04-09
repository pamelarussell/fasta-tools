#!/bin/bash

help_str="\n-----------------\nfasta_single_line.sh\n-----------------\n\nUsage: fasta_single_line.sh <input_fasta_file> <output_fasta_file>\n"

if [ "$1" == "-h" ]; then
  echo -e $help_str
  exit -1
fi

if [ "$#" -ne 2 ]; then
    echo -e $help_str
    exit -1
fi

input=$1
output=$2

cat $input | \
awk '
  BEGIN {header = ""; seq = ""}
  $1 ~ /^>/ && NR == 1 {header = $1; seq = ""}
  $1 ~ /^>/ && NR > 1 {print header "\n" seq; header = $1; seq = ""}
  $1 !~ /^>/ {seq = seq $1}
  END {print header "\n" seq}
' > $output
