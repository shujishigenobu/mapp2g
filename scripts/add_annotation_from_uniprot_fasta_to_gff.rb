#===
# add_annotation_from_uniprot_fasta_to_gff.rb
#
# This script adds annotation from UniProt FASTA file to GFF file.
# 
# Usage: ruby add_annotation_from_uniprot_fasta_to_gff.rb <uniprot_proteome_referene_fasta> <gff> 
# 
# Example: ruby add_annotation_from_uniprot_fasta_to_gff.rb UP000001593_45351.fasta mygff.gff3 > mygff_with_annotation.gff3
# 

require 'uri'

# https://www.uniprot.org/help/fasta-headers
#
# UniProtKB
#
# >db|UniqueIdentifier|EntryName ProteinName OS=OrganismName OX=OrganismIdentifier [GN=GeneName ]PE=ProteinExistence SV=SequenceVersion
#
# Where:
#
#     db is 'sp' for UniProtKB/Swiss-Prot and 'tr' for UniProtKB/TrEMBL.
#     UniqueIdentifier is the primary accession number of the UniProtKB entry.
#     EntryName is the entry name of the UniProtKB entry.
#     ProteinName is the recommended name of the UniProtKB entry as annotated in the RecName field. For UniProtKB/TrEMBL entries without a RecName field, the SubName field is used. In case of multiple SubNames, the first one is used. The 'precursor' attribute is excluded, 'Fragment' is included with the name if applicable.
#     OrganismName is the scientific name of the organism of the UniProtKB entry.
#     OrganismIdentifier is the unique identifier of the source organism, assigned by the NCBI.
#     GeneName is the first gene name of the UniProtKB entry. If there is no gene name, OrderedLocusName or ORFname, the GN field is not listed.
#     ProteinExistence is the numerical value describing the evidence for the existence of the protein.
#     SequenceVersion is the version number of the sequence.

# >db|UniqueIdentifier|EntryName ProteinName OS=OrganismName OX=OrganismIdentifier [GN=GeneName ]PE=ProteinExistence SV=SequenceVersion

fastaf = ARGV[0]
gfff = ARGV[1]
data = Hash.new


module Escape

  # ref: https://github.com/bioruby/bioruby/blob/master/lib/bio/db/gff.rb

  # unsafe characters to be escaped for normal columns
  UNSAFE = /[^-_.!~*'()a-zA-Z\d\/?:@+$\[\] "\x80-\xfd><;=,]/n

  # unsafe characters to be escaped for seqid columns
  # and target_id of the "Target" attribute
  UNSAFE_SEQID = /[^-a-zA-Z0-9.:^*$@!+_?|]/n

  # unsafe characters to be escaped for attribute columns
  UNSAFE_ATTRIBUTE = /[^-_.!~*'()a-zA-Z\d\/?:@+$\[\] "\x80-\xfd><]/n

  URI_PARSER = URI::Parser.new

  def self.escape_attribute(str)
    URI_PARSER.escape(str, UNSAFE_ATTRIBUTE)
  end

end

File.open(fastaf).each do |l|
  if /^>/.match(l)
#    puts l
    m = /^>(\S+)\|(\S+)\|(\S+)\s+(.+)\s+OS\=(.+)\s+OX\=(\d+)\s+(GN\=(.+)\s+)?PE\=(\d+)\s+SV\=(\d+)/.match(l)
    db = m[1]
    id = m[2]
    entry_name = m[3]
    protein_name = m[4]
    organism_name = m[5]
    organism_id = m[6]
    gene_name = m[8]
    prot_exis = m[9]
    seq_ver = m[10]

    h = {
      :db => db,
      :id => id,
      :entry_name => entry_name,
      :protein_name => protein_name,
      :organism_name => organism_name,
      :organism_id => organism_id,
      :gene_name => gene_name,
      :prot_exis => prot_exis,
      :seq_ver => seq_ver
    }
    data[id] = h

#    p [db, id, entry_name, protein_name, organism_name, organism_id]
  end

end

File.open(gfff).each do |l|
  a = l.chomp.split(/\t/)
  col_type = a[2]
  col_attr = a[8]
  if col_type == "match"
    id = /ID\=(.+)/.match(col_attr)[1]
#    p id
    d = data[id]
    h = Hash.new
    dbxref = Hash.new
    h['Name'] = Escape.escape_attribute(d[:protein_name])
    dbxref['EMBL'] = d[:id]
    dbxref['Uniprot'] = d[:entry_name]
    dbxref['tax'] = d[:organism_id]
    h['Dbxref'] = dbxref.map{|k, v| "#{k}:#{Escape.escape_attribute(v)}"}.join(",")
    if d[:gene_name]
      h['Alias'] = [Escape.escape_attribute(d[:gene_name])].join(",")
    end
    new_attr_col = col_attr + ";" + h.map{|k, v| "#{k}=#{v}"}.join(";")
    b = a.dup
    b[8] = new_attr_col
    puts b.join("\t")
  else
    puts l
  end
end