require_relative '../lib/mapp2g/report'

file = (ARGV[0] || "data/10.exonerate.txt")

exonout = Mapp2g::ExonerateOutput.load(file)

puts exonout.to_gff3