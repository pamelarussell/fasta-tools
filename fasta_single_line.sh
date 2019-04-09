#!/bin/bash

help_str="\n-----------------\nfasta_single_line.sh\n-----------------\n\nUsage: fasta_single_line.sh <input_fasta_file> <output_fasta_file> <optional_min_len_to_include_seq>\n"

if [ "$1" == "-h" ]; then
  echo -e $help_str
  exit 0
fi

if [ "$#" -lt 2 ]; then
    echo -e $help_str
    exit -1
fi

if [ "$#" -gt 2 ]; then
  min_len=$3
else
  min_len=0
fi

input=$1
output=$2

cat $input | \
awk -v min_len=$min_len '
  BEGIN {header = ""; seq = ""}
  $1 ~ /^>/ && NR == 1 {header = $1; seq = ""}
  $1 ~ /^>/ && NR > 1 {
    if(length(seq) >= min_len) {
      print header "\n" seq
    }; header = $1; seq = ""
  }
  $1 !~ /^>/ {seq = seq $1}
  END {if(length(seq) >= min_len) {
    print header "\n" seq
  }}
' > $output
