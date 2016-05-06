#!/usr/bin/env ruby

require 'json'
require 'csv'
require 'fileutils'

FileUtils.mkdir_p("output")

def sanitize_comment(comment)
  comment.to_s.tr('/\\\\"\'','').gsub(/<img[^>]*>/ui,'IMAGE').gsub(/<[^>]*>/ui,'').gsub(/^(.{50,}?).*$/m,'\1...')
end

count = 0

blogs = {}
post_map = {} # maps post IDs to the last ID which actually has content

puts "Pre processing"
# pre-processing. Collect blogs and how reblogs actually link to threads and comments (as we don't care about commentless reblogs)
File.open(ARGV[0], "r:UTF-8") do |input|
  input.each_line do |line|
    count += 1
    print "." if count%100000==0
    if line.start_with?("POST ")
      data = JSON.parse(line[5..-1])
      blogs[data['dst']] = true
      if data['trail'] && !data['trail'].empty?
        post_map[data['id']] = [data['trail'].first['id'], data['trail'].last['id'], data['trail'].first['src'], data['trail'].last['src'], data['type']]
      else
        root_name = data['root'] || data['src']
        root_id = data['root_id'] || data['id']
        post_map[data['id']] = [root_id, root_id, root_name, root_name, data['type']]
      end
    end
  end
end

CSV.open("output/blog.csv","wb:UTF-8") do |blog| # used for Blog
  blog << ["name"]
  blogs.each do |k,v|
    blog << [k]
  end
end

File.open(ARGV[0],"r:UTF-8") do |input|
CSV.open("output/thread.csv","wb:UTF-8") do |thread| # used for Thread, :POSTED
thread << ["id","from","comment","type","internal"]

CSV.open("output/comment.csv","wb:UTF-8") do |comment| # used for Comment, :COMMENTED, :IS_COMMENT_OF, :IS_REPLY_OF
comment << ["id","from","comment","type","thread_id","parent_id"]

CSV.open("output/like.csv","wb:UTF-8") do |like| # used for :LIKED_BLOG, :LIKED_COMMENT, :LIKED_THREAD
like << ["from","blog_name","comment_id","thread_id", "type"]

CSV.open("output/reblog.csv","wb:UTF-8") do |reblog| # used for :REBLOGGED_BLOG, :REBLOGGED_THREAD_OF, :REBLOGGED_COMMENT_OF, :REBLOGGED_COMMENT, :REBLOGGED_THREAD
reblog << ["from","blog_name","thread_starter_name","comment_poster_name","comment_id","thread_id","type"]

puts "Processing"
input.each_line do |line|
  count -= 1
  puts "Lines left to process: #{count}" if count%100000 == 0
  if line.start_with?("POST ")
    data = JSON.parse(line[5..-1])
    if blogs[data['dst']]
      root_name = data['root'] || data['src'] || data['dst']
      root_id = data['root_id'] || data['id']
      root_comment = data['root_comment'] || data['comment'] || ""

      last_comment_id = root_id
      last_comment_poster = root_name

      thread << [root_id, root_name, sanitize_comment(root_comment), data['type'], blogs[root_name] ? true : false]

      # we always want to have a root comment as well, to make the relations easier
      comment << [root_id, root_name, sanitize_comment(root_comment), data['type'], root_id, nil]

      if data['trail'] && !data['trail'].empty?
        # we always want to have the root comment as root, even if it was cleared afterwards - possible on media posts
        if data['trail'].first['id'] != root_id
          data['trail'].unshift({'content' => root_comment,'id' => root_id,'src' => root_name})
        end

        # for each parent-child pair create a comment
        data['trail'].each_cons(2) do |parent,child|
          comment << [child['id'],child['src'],sanitize_comment(child['content']), data['type'], root_id, parent['id']]
          last_comment_id = child['id']
          last_comment_poster = child['src']
        end
      end

      reblog << [data['src'], data['dst'], root_name, last_comment_poster, last_comment_id, root_id, data['type']]
    end
  elsif line.start_with?("LIKE ")
    data = JSON.parse(line[5..-1])
    map = post_map[data['post_id']]
    if blogs[data['dst']] && map
      like << [data['src'], data['dst'], map[0], map[1], map[4]]
    end
  end
end

end
end
end
end
end
