## Dmel genome
URL=https://ftp.ensembl.org/pub/release-108/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.32.dna_sm.toplevel.fa.gz
FASTA=Dmel_genome.fasta
WORKDIR=work

wget $URL
mv Drosophila_melanogaster.BDGP6.32.dna_sm.toplevel.fa.gz ${FASTA}.gz
gunzip ${FASTA}.gz
mv $FASTA $WORKDIR/


