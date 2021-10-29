#! /usr/bin/env ruby

require 'pathname'
require 'fileutils'
require 'nokogiri'

root_dir = Pathname.new(File.expand_path(Pathname.new(".")))
src_dir = root_dir + "src"
out_dir = root_dir + "out"

header = File.new(src_dir + "header.html", "r")
footer_html = File.new(src_dir + "footer.html", "r").read

# chdir is a bit of a weird way to do it, but it's the easiest
Dir.chdir(src_dir)
post_paths = Dir.glob("post/**/*.html")
Dir.chdir(root_dir)

post_paths.each { |post_path|
  post_html = File.new(src_dir + post_path).read

  # Make the title of each page whatever the first <h1> tag is
  title = Nokogiri::HTML(post_html).css("h1").text
  header_html = header.read.sub("<title></title>", "<title>#{title}</title>")

  out_path = out_dir + post_path

  FileUtils.mkpath(Pathname.new(out_path).dirname)

  out_html = header_html + post_html + footer_html
  File.new(out_path, "w").syswrite(out_html)
}
