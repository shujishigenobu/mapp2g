name = nil
target = nil
ARGF.each do |l|
  
  if m = /\s+Query:\s/.match(l)
    name = m.post_match.chomp.split[0]
  elsif m = /\s+Target:\s/.match(l)
    target = m.post_match.split[0]
  elsif /^#{target}/.match(l) &&
      (/\texonerate:est2genome\t/.match(l) || /\texonerate:protein2genome:local\t/.match(l)) &&
      (/\tcds\t/.match(l) || /\texon\t/.match(l) || /\tgene\t/.match(l))
#    puts l
    a = l.chomp.split(/\t/)
    b = Array.new(9)
    a.each_with_index{|x, i| b[i] = x}
    if b[2] == "gene"
      b[-1] = "ID=#{name}"
      b[2] = "match"
    elsif (b[2] == "cds" || b[2] == "exon")
      b[-1] = "Parent=#{name}"
      b[2] = "match_part"
    else
      raise
    end
    puts b.join("\t")
  end

end
