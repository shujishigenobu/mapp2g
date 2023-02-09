#!/bin/env bash

makeblastdb -in work/Dmel_genome.fasta -dbtype nucl -parse_seqids

mapp2g -g work/Dmel_genome.fasta -q data/Dmel_Dll_pep.fasta -o work/mapp2g_out
