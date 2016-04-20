require 'json'
require 'csv'
require 'fileutils'

FileUtils.mkdir_p("output")

def determine_gpoy(data)
  # photo posts, with a comment saying gpoy somewhere
  data['type'] == 'photo' &&
  ['gpoy','gépoy','gepoy','gpoj','gépoj','gepoj'].any? do |v|
    ['comment','root_comment','tags'].any? do |k|
      data[k].to_s.downcase.include?(v)
    end
  end
end

CSV.open("output/original.csv","wb") do |orig| # who reblogged your original content
CSV.open("output/relations.csv", "wb") do |rel| # who reblogged you
CSV.open("output/tumblrs.csv", "wb") do |tmblr| # names of hungarian tumblrs, and whether they post original content

orig << ["from","to","type"]
rel << ["from", "to", "type"]
tmblr << ["name", "original", "gpoy"]

ARGF.each_line do |line|
  data = JSON.parse(line)
  tmblr << [data['dst'], !data['src'], determine_gpoy(data)] if data['dst']
  rel << [data['src'], data['dst'], data['type']] if data['src'] && data['src'] != data['dst']
  orig << [data['root'], data['dst'], data['type']] if data['root'] && data['root'] != data['dst']
end

end
end
end
