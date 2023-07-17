# Mapp2g

## Installation

### Pre-requisites

  * NCBI blast
  * exonerate
  
These two software should be installed. mapp2g is wrtten in Ruby. Ruby sholud be installed.

### Install mapp2g using gem

```
gem install mapp2g
```

## Usage

```
Usage: mapp2g [options]
    -q, --query QUERY                query amino acid sequences in FASTA format
    -g, --genome BLASTDB             genome reference as blastdb
    -o, --outdir [OUTDIR]            output directory. DEFAULT: mapp2g_out_{process_id}
    -v, --version                    show version number
    -h, --help                       show this help message and exit
```

Query sequences should be in FASTA format. Multiple sequences can be included in one file.


(example)
```
mapp2g -q human_genome.fasta -q p53.protein.fasta
```

Reference genomes should be formated in blastdb before running mapp2g. blastdb can be made as follws:

```
makeblastdb -in human_genome.fasta -dbtype nucl -parse_seqids
```

## Outputs

For each query, the following files are generated.

- query sequence in fasta
- blast output in tab-delmited format (format 6)
- exonerate full output
- exonerate alignment in gff3 format
- report.json

report.json contains all of the information above in json line format.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
