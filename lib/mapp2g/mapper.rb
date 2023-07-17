require 'tempfile'

module Mapp2g

  class Mapper

    EVALUE_DEFAULT = 1.0e-5
    NCPU_DEFAULT = 4
    MAX_HSP_INTERVAL = 400000
    EXTENSION = 50000
    TMPDIR_DEFAULT = Dir.tmpdir

    def initialize
    end

    ## step 1: tblastn
    def exec_tblastn_to_know_rough_target_region(query, genome, evalue=EVALUE_DEFAULT, ncpu=NCPU_DEFAULT)
      cmd = "tblastn -db #{genome} -query #{query} -max_target_seqs 40 -soft_masking yes -seg yes -outfmt 6 -evalue #{evalue} -num_threads #{ncpu} -culling_limit 2"
      # puts cmd
      res = nil
      IO.popen(cmd){|io| res = io.read} 
#     STDERR.puts res
      if res == ""
      ## no hit
        return nil
      else
        lines = []
        prev_chr = nil
        res.split(/\n/).each do |l|
#          p prev_chr
          a = l.chomp.split(/\t/)
          unless prev_chr
            lines << l
            prev_chr = a[1]
          else
            break if a[1] != prev_chr
            lines << l
            prev_chr = a[1]
          end 
        end
    
        a = lines.shift.chomp.split(/\t/)
        left, right = [a[8].to_i, a[9].to_i].sort
        
#        STDERR.puts [left, right].inspect
    
        lines.each do |l|
          a = l.chomp.split(/\t/)
          from, to = [a[8].to_i, a[9].to_i].sort
          tmpary = [left, right, from, to].sort
          new_left = tmpary.first
          new_right = tmpary.last
          if (new_left - left).abs < MAX_HSP_INTERVAL &&  (new_right - right).abs < MAX_HSP_INTERVAL
            right = new_right
            left  = new_left
          else
            break
          end
        end
#        STDERR.puts [left, right].inspect
        
        top_chromosome = res.split(/\n/)[0].split(/\t/)[1]
        h = {
          :top_chromosome => top_chromosome, 
          :left => left,
          :right => right,
          :blast_result => res
        }
#        STDERR.puts h.inspect
        return h
      end
    end
     

    ## step 2: get top hit
    def prepare_rough_target_genomic_region(genome, top_chromosome, left, right)
      cmd = "blastdbcmd -db #{genome} -entry #{top_chromosome} -outfmt %l "
      res = nil
      IO.popen(cmd){|io| res = io.read}
      seqlength = res.to_i
    
      left_extract = [(left - EXTENSION), 1].sort.last
      right_extract = [(right + EXTENSION), seqlength].sort.first
    
      #p [left_extract, right_extract]
    
      cmd = "blastdbcmd -db #{genome} -entry #{top_chromosome} -range #{left_extract}-#{right_extract} -outfmt %s"
      res = nil
      IO.popen(cmd){|io| res = io.read}
      seq = res.strip
    
      seq = "n" * (left_extract - 1) + seq + "n" * (seqlength - right_extract)
      # [res.size, seq.size, seqlength]
      raise unless seq.size == seqlength
      fas = ">#{top_chromosome}\n#{seq}"
      fas
    end
     
    ## step 3: run exonerate
    
    def exec_exonerate(query, target)
      cmd = "exonerate -q #{query} -t #{target} --model protein2genome --bestn 1 --showquerygff yes --showtargetgff yes --showcigar yes"
      res = nil
      IO.popen(cmd){|io| res = io.read}
      res
    end

    ## standard pipeline from step 1 to 3
    def run(query, genome)
      hit = self.exec_tblastn_to_know_rough_target_region(query, genome)
      if hit
        top_chromosome = hit[:top_chromosome]
        left = hit[:left]
        right = hit[:right]
      
        target_fasta = prepare_rough_target_genomic_region(genome, top_chromosome, left, right)
        tf = Tempfile.new("mapp2g-#{Process.pid}")
        tf.puts(target_fasta)
        tf.close
      
        exonerate_result = exec_exonerate(query, tf.path)
        return {
          :blast_result => hit[:blast_result], 
          :exonerate_result => exonerate_result
        }
      else
        return nil
      end
    end

  end    

end

#---
if __FILE__ == $0

  mapper = Mapp2g::Mapper.new()

  query = ARGV[0]
  genome = ARGV[1]
  res = mapper.run(query, genome)
  puts res

end