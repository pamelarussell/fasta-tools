#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: fasta_seq_lens.sh <fasta_file>"
    exit -1
fi

fasta=$1

cat $fasta | \
awk '
  BEGIN {name = ""; len=0}
  $1 ~ /^>/ && NR > 0 {print name "\t" len; name = $1; gsub("^>", "", name); len = 0}
  $1 !~ /^>/ {len = len + length($1)}
  END {print name "\t" len}
'
