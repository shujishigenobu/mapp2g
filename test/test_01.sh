#!/bin/env bash

#makeblastdb -in work/Dmel_genome.fasta -dbtype nucl -parse_seqids

#MAPP2G_EXE=mapp2g
MAPP2G_EXE=../exe/mapp2g

$MAPP2G_EXE -g work/Dmel_genome.fasta -q data/Dmel_Dll_pep.fasta -o work/mapp2g_out
