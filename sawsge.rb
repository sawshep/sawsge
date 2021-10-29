#! /usr/bin/env ruby

require 'pathname'
require 'fileutils'
require 'nokogiri'

# Tells you what's inside the tag of your choosing
def parse_tag(html, tag)
  title = Nokogiri::HTML(html).css(tag).text
end

class Page
  attr_reader :path, :title, :content
  def initialize(path, title, content)
    @path = path
    @title = title
    @content = content
  end

  def build(header, footer)
    header.sub!("<title></title>", "<title>#{title}</title")
    return header + @content + footer
  end
end

# Separated from Page for extensibility in the future
class Post < Page
  def initialize(path, title, content)
    super(path, title, content)
    @path = path
    #@date = date
  end
end

class Website
  HEADER_PATH = "header.html"
  FOOTER_PATH = "footer.html"
  POSTS_DIR = "post"
  HOME_PATH = "index.html"
  def initialize(src_dir, out_dir)
    @cwd = Dir.pwd
    @src_dir = src_dir
    @out_dir = out_dir
    @header = File.new(@src_dir + HEADER_PATH, "r").read
    @footer = File.new(@src_dir + FOOTER_PATH, "r").read

    # TODO: These two functions do too much.
    # Maybe Pages should simply take a path as an
    # argument and figure out how to modify it's
    # content accordingly itself. However, issues
    # arrise if I still want Post to be a subclass
    # of Page.
    @posts = make_posts
    @home = make_home

    @pages = @posts.append(@home)

  end

  def make_posts
    posts = Array.new
    # Reverse so the latest dates will be at the start
    Dir.chdir @src_dir
    paths = Dir.glob(POSTS_DIR + "/**/*.html").reverse
    Dir.chdir @cwd

    paths.each do |path|
      content = File.new(@src_dir + path, "r").read
      title = parse_tag(content, "h1")
      posts.append(Post.new(path, title, content))
    end
    return posts
  end

  def make_home
    content = File.new(@src_dir + HOME_PATH, "r").read
    title = parse_tag(content, "h1")
    @posts.each do |post|
      content += "<a href=\"/#{post.path}\">#{post.title}</a></br>"
    end
    return Page.new(HOME_PATH, title, content)
  end

  def build
    @pages.each do |page|
      html = page.build(@header, @footer)
      out_path = @out_dir + page.path
      FileUtils.mkpath(Pathname.new(out_path).dirname)
      File.new(out_path, "w").syswrite(html)
    end
  end
end

Website.new(Pathname.new("src"), Pathname.new("out")).build
