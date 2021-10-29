#! /usr/bin/env ruby

require 'pathname'
require 'fileutils'
require 'nokogiri'

SRC_DIR = Pathname.new("src")
OUT_DIR = Pathname.new("out")

# Tells you what's inside the tag of your choosing
def parse_tag(html, tag)
  title = Nokogiri::HTML(html).css(tag).text
end

class Page
  CONTENT_TITLE_TAG = "h1"
  attr_reader :path, :title, :content
  def initialize(path)
    # We should be chdir-ed into the src dir when this is run
    @content = File.new(path, "r").read
    @path = path
    @title = parse_tag(content, CONTENT_TITLE_TAG)
  end

  # Returns the full html, with header/footer modified to needs
  def build(header, footer)
    header.sub!("<title></title>", "<title>#{title}</title")
    return header + @content + footer
  end
end

# Separated from Page for extensibility in the future
class Post < Page
  def initialize(path)
    super(path)
    #@date = date
  end
end

class Home < Page
  def initialize(path, posts)
    super(path)
    posts.each do |post|
      link = "<p><a href=\"/#{post.path}\">#{post.title}</a></p>"
      @content += link
    end
  end
end

class Website
  HEADER_PATH = "header.html"
  FOOTER_PATH = "footer.html"
  POSTS_DIR = "post"
  HOME_PATH = "index.html"
  def initialize(src_dir, out_dir)
    @src_dir = File.expand_path(src_dir)
    @out_dir = File.expand_path(out_dir)

    Dir.chdir @src_dir

    @header = File.new(HEADER_PATH, "r").read
    @footer = File.new(FOOTER_PATH, "r").read

    @posts = Array.new
    Dir.glob(POSTS_DIR + "/**/*.html").reverse.each do |path|
      @posts.append(Post.new(path))
    end

    @home = Home.new(HOME_PATH, @posts)

    @pages = @posts.append(@home)
  end

  def build
    # Make out directory
    FileUtils.mkpath(@out_dir)
    Dir.chdir @out_dir

    # Write each page
    @pages.each do |page|
      html = page.build(@header, @footer)
      FileUtils.mkpath(Pathname.new(page.path).dirname)
      File.new(page.path, "w").syswrite(html)
    end
  end
end

Website.new(Pathname.new("src"), Pathname.new("out")).build
