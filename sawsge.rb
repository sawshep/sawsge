#! /usr/bin/env ruby

require 'fileutils'
require 'nokogiri'
require 'pandoc-ruby'
require 'pathname'
require 'toml'
require 'uri'

require_relative 'resource.rb'
require_relative 'page.rb'
require_relative 'post.rb'
require_relative 'home.rb'

HELP_STRING = 'Usage: sawsge DIRECTORY'

if ARGV.length != 1
  abort HELP_STRING
end

SRC_DIR = ARGV[0]

CONFIG_FILENAME = 'config.toml'
CONFIG_STRING = File.new(File.join(SRC_DIR, CONFIG_FILENAME)).read
CONFIG = TOML::Parser.new(CONFIG_STRING).parsed

OUT_DIRNAME = CONFIG['general']['out_dirname']

# TODO: Put these in the config
POSTS_DIRNAME = CONFIG['blog']['posts_dirname']


HEADER_FILENAME = CONFIG['general']['header_filename']
FOOTER_FILENAME = CONFIG['general']['footer_filename']

# If there is no path for the header and footer, neither
# header nor footer is added. Basically an ifndef
# TODO: Maybe there's a higher order way to do this? I don't
# think you're supposed to use if blocks like this, at least
# in Ruby.
HEADER = if HEADER_FILENAME.empty?
           ''
         else
           File.new(File.join(SRC_DIR, HEADER_FILENAME)).read
         end
FOOTER = if FOOTER_FILENAME.empty?
           ''
         else
           File.new(File.join(SRC_DIR, FOOTER_FILENAME)).read
         end

EXTERNAL_LINKS_TARGET_BLANK = CONFIG['general']['external_links_target_blank']

# Resources that will not be put into the out folder
RESERVED_FILENAMES = [CONFIG_FILENAME, HEADER_FILENAME, FOOTER_FILENAME]

MODE = CONFIG['general']['mode']


def top_parent_dir(path)
  Pathname.new(path).each_filename.to_a[0]
end



# Gross, but easy
Dir.chdir SRC_DIR

# resource_paths is a glob for all files in the source
# directory
resource_paths = Dir.glob('**/*').select do |path|
  File.file?(path) && top_parent_dir(path) != OUT_DIRNAME
end
resource_paths -= RESERVED_FILENAMES

resource_objects = Array.new
all_objects = Array.new

case MODE
when 'blog'
  home_path = 'index.md'

  # Does not work if you have parent directories for your
  # posts dir, e.g. you set posts_dirname in config.toml to
  # foo/bar/baz/etc...
  post_paths = resource_paths.select do |path|
    top_parent_dir(path) == POSTS_DIRNAME && File.extname(path) == '.md'
  end
  puts post_paths

  # This is kind of a slow way to do it, but it's readable and
  # it works
  resource_paths -= post_paths
  resource_paths.delete(home_path)

  # This array will be in order from past to present.
  post_objects = post_paths.map { |path| Post.new(path) }
  home_object = Home.new(home_path, post_objects)
  all_objects = post_objects + [home_object]

when 'project'
  page_paths = resource_paths.select { |path| File.extname(path) == '.md' }

  resource_paths -= page_paths

  page_objects = page_paths.map { |path| Page.new(path) }
  all_objects = page_objects
else
  abort HELP_STRING
end


resources = resource_paths.map { |path| Resource.new(path) }
all_objects += resources


# Delete any old builds
if Pathname.new(OUT_DIRNAME).exist?
  FileUtils.remove_dir OUT_DIRNAME
end
FileUtils.mkpath OUT_DIRNAME


# Write each file
all_objects.each { |object| object.build }
