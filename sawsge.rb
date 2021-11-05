#! /usr/bin/env ruby

require 'pathname'
require 'fileutils'
require 'nokogiri'

SRC_DIR = Pathname.new("src")
OUT_DIR = Pathname.new("out")

# Tells you what's inside the tag of your choice
def parse_tag(html, tag)
  title = Nokogiri::HTML(html).css(tag).text
end

# Generic for homepage, posts, maybe css sheet in the future
class Page
  CONTENT_TITLE_TAG = "h1"
  attr_reader :path, :title, :content
  def initialize(path)
    # We should be chdir-ed into the src dir when this is run, no
    # need for src at the start of the path.
    @content = File.new(path, "r").read 
    @path = path.dirname # so the url won't have index.html in it
    @title = parse_tag(content, CONTENT_TITLE_TAG)
  end

  # Returns the full html, with header/footer modified to needs
  def build(header, footer)
    header = header.sub("<title></title>", "<title>#{title}</title")
    return header + @content + footer
  end
end

# Class for blogposts
class Post < Page
  SUMMARY_TAG = "summary"
  attr_reader :summary, :date
  def initialize(path)
    super(path)

    # TODO: There has to be a more idomatic way to do this...
    # Split the dir names into an array, remove the first one
    # because it's always POSTS_DIR. Now, if you didn't want
    # to have any directory for your posts you're going to have
    # a bad time.
    parts = @path.each_filename.to_a[1..]
    @date = "#{parts[0]}-#{parts[1]}-#{parts[2]}"

    @summary = parse_tag(@content, SUMMARY_TAG)
    @content = @content.sub("</h1>", "</h1><date>#{@date}</date>")
  end
end

# Class for homepage
class Home < Page
  def initialize(path, posts)
    super(path)
    posts.each_with_index do |post, i|
      # Adds title, date, summary of each post with first post expanded
      link =  "<details#{i == 0 ? " open" : ""}>" +
                "<summary>" +
                  "<a href=\"/#{post.path}\">#{post.title}</a> <date>#{post.date}</date>" +
                "</summary>" +
                "<p>#{post.summary}</p>" +
              "</details>";
      @content += link
    end
  end
end

class Website
  HEADER_PATH = Pathname.new("header.html")
  FOOTER_PATH = Pathname.new("footer.html")
  # For some reason, the program hangs indefinitely if POSTS_DIR
  # is a Pathname type. WTH!?
  POSTS_DIR = "post"
  HOME_PATH = Pathname.new("index.html")
  STYLESHEET_PATH = "style.css"
  def initialize(src_dir, out_dir)
    @src_dir = Pathname.new(File.expand_path(src_dir))
    @out_dir = Pathname.new(File.expand_path(out_dir))

    Dir.chdir @src_dir

    @header = File.new(HEADER_PATH, "r").read
    @footer = File.new(FOOTER_PATH, "r").read
    @style = File.new(STYLESHEET_PATH, "r").read

    @posts = Array.new
    # Every html file in src/posts
    Dir.glob(POSTS_DIR + "/**/*.*").reverse.each do |path|
      path = Pathname.new(path)
      @posts.append(Post.new(path))
    end

    @home = Home.new(HOME_PATH, @posts)

    @pages = @posts.append(@home)
  end

  def build
    # Delete any old out dir
    if @out_dir.exist?
      FileUtils.remove_dir(@out_dir)
    end
    # Make out directory
    FileUtils.mkpath(@out_dir)
    Dir.chdir @out_dir

    # Write each page
    @pages.each do |page|
      html = page.build(@header, @footer)
      FileUtils.mkpath(Pathname.new(page.path))
      File.new(page.path.join("index.html"), "w").syswrite(html)
    end
    # Copy stylesheet over
    # TODO: Find a better way to do this besides hardcoding
    File.new(STYLESHEET_PATH, "w").syswrite(@style)
  end
end

Website.new(Pathname.new("src"), Pathname.new("out")).build
