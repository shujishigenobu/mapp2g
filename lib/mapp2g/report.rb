module Mapp2g

  class ExonerateOutput

    def self.load(file)
      self.new(File.read(file))
    end

    # @param exonerate_out [String] exonerate output text, not file path
    def initialize(exonerate_out)
      @exonerate_out = exonerate_out
      @query_name = nil
      @target = nil
      @cigar = nil
      @gff2_lines = []
      #vulgar = nil
      parse()
    end

    attr_reader :query_name, :target, :cigar, :gff2_lines

    def parse(opt={})
      @exonerate_out.each_line do |l|
        if m = /\s+Query:\s/.match(l)
          @query_name = m.post_match.chomp.split[0]
        elsif m = /\s+Target:\s/.match(l)
          @target = m.post_match.split[0]
        elsif m = /^cigar:\s/.match(l)
          @cigar = m.post_match.chomp
        elsif /^#{@target}/ =~ l &&
            (/\texonerate:est2genome\t/.match(l) || /\texonerate:protein2genome:local\t/.match(l)) &&
            (/\texon\t/.match(l) || /\tgene\t/.match(l))
          @gff2_lines << l.chomp
        end
      end
    end

    def to_gff3(opt={})
      gff3_lines = []
      @gff2_lines.each do |l|
        a = l.chomp.split(/\t/)
        b = Array.new(9)
        a.each_with_index{|x, i| b[i] = x}
        if b[2] == "gene"
          b[2] = "match"
          orig_attribute = b[8].split(";").map{|x| x.strip.split(/\s+/)}.to_h
      #    p orig_attribute
          c = @cigar.split(/\s+/)
          cigar_pairs = c[9..-1].join.scan(/[MDI]\d+/)
          attribute = {'ID' => @query_name,
                       'Target' => [@query_name, c[1].to_i + 1, c[2]].join(" "),
                       'Gap'=> cigar_pairs.join(" "),
                       'identity' => orig_attribute['identity'],
                       'similarity' => orig_attribute['similarity']}
          b[8] = attribute.map{|k, v| "#{k}=#{v}"}.join(";")
        elsif b[2] == "exon"
          b[2] = "match_part"
          orig_attribute = b[8].split(";").map{|x| x.strip.split(/\s+/)}.to_h
          attribute = {'Parent' => @query_name,
          'identity' => orig_attribute['identity'],
          'similarity' => orig_attribute['similarity']}
          b[8] = attribute.map{|k, v| "#{k}=#{v}"}.join(";")

        else
          raise
        end
        gff3_lines << b.join("\t")
      end
      return gff3_lines.join("\n")
    end

  end

end

