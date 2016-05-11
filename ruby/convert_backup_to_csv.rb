#!/usr/bin/env ruby

fields = %w{name threadRank hunblarityRank likeRank commentRank reblogRank hunblarityPos}

puts fields.join(",")

ARGF.each_line do |line|
  if line=~/\{(.*)\}/
    data = $1
    values = data.split(',').inject({}){|acc,v| x=v.split(':');acc[x[0]]=x[1];acc }
    puts fields.map{|f|values[f]}.join(",")
  end
end
