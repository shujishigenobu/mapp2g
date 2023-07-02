#!/bin/env ruby

exonerate_out = (ARGV[0] || "mapp2g_out_ClyHem/mapp2g_out_ClyHem_j609t87/57.exonerate.txt")

query_name = nil
target = nil
cigar = nil
gff2_lines = []
#vulgar = nil

File.open(exonerate_out, "r").each do |l|

  if m = /\s+Query:\s/.match(l)
    query_name = m.post_match.chomp.split[0]
  elsif m = /\s+Target:\s/.match(l)
    target = m.post_match.split[0]
  elsif m = /^cigar:\s/.match(l)
    cigar = m.post_match.chomp
  elsif /^#{target}/.match(l) &&
      (/\texonerate:est2genome\t/.match(l) || /\texonerate:protein2genome:local\t/.match(l)) &&
      (/\texon\t/.match(l) || /\tgene\t/.match(l))
    gff2_lines << l.chomp
  end

end

#puts gff2_lines

gff2_lines.each do |l|
  a = l.chomp.split(/\t/)
  b = Array.new(9)
  a.each_with_index{|x, i| b[i] = x}
  if b[2] == "gene"
    b[2] = "match"
    orig_attribute = b[8].split(";").map{|x| x.strip.split(/\s+/)}.to_h
#    p orig_attribute
    c = cigar.split(/\s+/)
    cigar_pairs = c[9..-1].join.scan(/[MDI]\d+/)
    attribute = {'ID' => query_name,
                 'Target' => [query_name, c[1].to_i + 1, c[2]].join(" "),
                 'Gap'=> cigar_pairs.join(" "),
                 'identity' => orig_attribute['identity'],
                 'similarity' => orig_attribute['similarity']}
    b[8] = attribute.map{|k, v| "#{k}=#{v}"}.join(";")
  elsif b[2] == "exon"
    b[2] = "match_part"
    orig_attribute = b[8].split(";").map{|x| x.strip.split(/\s+/)}.to_h
    attribute = {'Parent' => query_name,
    'identity' => orig_attribute['identity'],
    'similarity' => orig_attribute['similarity']}
    b[8] = attribute.map{|k, v| "#{k}=#{v}"}.join(";")

  else
    raise
  end
  puts b.join("\t")
end


# CIGAR format
# The format starts with the same 9 fields as sugar output (see above), and is followed by a series of <operation, length> pairs where operation is one of match, insert or delete, and the length describes the number of times this operation is repeated.
# 1 query_id: Query identifier
# 2 query_start: Query position at alignment start
# 3 query_end: Query position alignment end
# 4 query_strand: Strand of query matched
# 5 target_id|
# 6 target_start| the same 4 fields
# 7 target_end  | for the target sequence
# 8 target_strand|
# 9 score| The raw alignment score