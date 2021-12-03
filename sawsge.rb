#! /usr/bin/env ruby

require 'fileutils'
require 'nokogiri'
require 'pandoc-ruby'

require_relative 'resource.rb'
require_relative 'page.rb'
require_relative 'post.rb'
require_relative 'home.rb'


SRC_FOLDER = "src"
OUT_FOLDER = "out"
POST_FOLDER = "post"

ROOT_DIR = Dir.pwd
SRC_DIR = File.join(ROOT_DIR, SRC_FOLDER)
OUT_DIR = File.join(ROOT_DIR, OUT_FOLDER)

HEADER_PATH = "header.html"
FOOTER_PATH = "footer.html"
HEADER = File.new(File.join(SRC_DIR, HEADER_PATH)).read
FOOTER = File.new(File.join(SRC_DIR, FOOTER_PATH)).read


# Tells you what's inside the tag of your choice
def parse_tag(html, tag)
  title = Nokogiri::HTML(html).css(tag).text
end


# Scan for links in files, if resource exists in path dont
# do anything, otherwise mv from src to out
Dir.chdir SRC_DIR

home_path = "index.md"
post_paths = Dir.glob(File.join(POST_FOLDER, "**/*.md"))

resource_paths = Dir.glob("**/*")
dirs = Array.new
resource_paths.each do |path|
  if Dir.exist?(path)
    dirs.push path
  end
end
# This is kind of a slow way to do it, but it's readable and
# it works
resource_paths -= (dirs + post_paths + [home_path, HEADER_PATH, FOOTER_PATH])
Dir.chdir ROOT_DIR


# Initialize all the posts
posts = Array.new
post_paths.each do |path|
  path = Pathname.new(path)
  # Posts should be automatically sorted if using ISO date
  # format
  posts.push Post.new(path)
end
# So dates are in order
posts.reverse!


home = Home.new(home_path, posts)


resources = Array.new
resource_paths.each do |path|
  resources.push Resource.new(path)
end


all_files = posts + resources
all_files.push home

# Delete any old builds
if Pathname.new(OUT_DIR).exist?
  FileUtils.remove_dir OUT_DIR
end
FileUtils.mkpath OUT_DIR

# Write each file
all_files.each do |file|
  file.build
end
