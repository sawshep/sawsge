#! /usr/bin/env ruby

require 'fileutils'
require 'nokogiri'

require 'pandoc-ruby'

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


# Any generic file in the website directory
class Resource
  attr_reader :path
  def initialize(path)
    # Path is relative to SRD_DIR, does not include it
    @path = path
  end
  def build
    FileUtils.cp File.join(SRC_DIR, @path), File.join(OUT_DIR, @path)
  end
end


class Page < Resource
  attr_reader :title
  def initialize(path)
    super(path)
    @content = PandocRuby.convert(File.new(File.join(SRC_DIR, @path), "r").read, from: :markdown, to: :html)
    @title = parse_tag(@content, "h1")
    @content = HEADER + @content + FOOTER
    # Sub replaces the first occurance
    @content.sub!("<title></title>", "<title>#{@title}</title")
  end

  def build
    FileUtils.mkpath(File.join(OUT_DIR, File.dirname(@path)))
    File.new(File.join(OUT_DIR, @path.sub("index.md", "index.html")), "w").syswrite(@content)
  end
end

class Post < Page
  attr_reader :date, :summary
  def initialize(path)
    super(path)

    # There's got to be a more idiomatic way to do this! The
    # current implementation is disguisting.
    parts = @path.each_filename.to_a[1..]
    [SRC_FOLDER, POST_FOLDER].each do |dirname|
      parts.delete(dirname)
    end
    @date = "#{parts[0]}-#{parts[1]}-#{parts[2]}"
    @content.sub!("</h1>", "</h1><date>#{@date}</date>")

    # Look what's in <summary></summary>
    @summary = parse_tag(@content, "summary")
  end
end

class Home < Page
  def initialize(path, posts)
    super(path)
    posts.each_with_index do |post, i|
      # Adds title, date, summary of each post with first
      # post expanded
      #link =  "<details#{i == 0 ? " open" : ""}>" +
      link =  "<details open>" +
                "<summary>" +
                  "<a href=\"/#{File.dirname(post.path)}\">#{post.title}</a> <date>#{post.date}</date>" +
                "</summary>" +
                "<p>#{post.summary}</p>" +
                "<a href=\"#{post.path.dirname}\">Read more</a>" +
              "</details>";
      @content += link
    end
  end
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
