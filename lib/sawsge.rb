# frozen_string_literal: true

require 'fileutils'
require 'nokogiri'
require 'pandoc-ruby'
require 'pathname'
require 'set'
require 'toml'
require 'uri'

require 'sawsge/resource'
require 'sawsge/page'
require 'sawsge/post'
require 'sawsge/home'
require 'sawsge/blog'
require 'sawsge/project'

module Sawsge
  HELP_STRING = 'Usage: sawsge [DIRECTORY]'

  SRC_DIR = ARGV[0] || Dir.pwd

  CONFIG_FILENAME = 'config.toml'
  CONFIG_STRING = File.read(File.join(SRC_DIR, CONFIG_FILENAME))
  CONFIG = TOML::Parser.new(CONFIG_STRING).parsed

  OUT_DIRNAME = CONFIG['general']['out_dirname']

  # TODO: Put these in the config
  POSTS_DIRNAME = CONFIG['blog']['posts_dirname']

  HEADER_FILENAME = CONFIG['general']['header_filename']
  FOOTER_FILENAME = CONFIG['general']['footer_filename']

  HEADER = HEADER_FILENAME.empty? ? '' : File.read(File.join(SRC_DIR, HEADER_FILENAME))
  FOOTER = FOOTER_FILENAME.empty? ? '' : File.read(File.join(SRC_DIR, FOOTER_FILENAME))

  EXTERNAL_LINKS_TARGET_BLANK = CONFIG['general']['external_links_target_blank']

  IGNORE = CONFIG['general']['ignore']

  # Resources that will not be put into the out folder
  RESERVED_FILENAMES = [CONFIG_FILENAME, HEADER_FILENAME, FOOTER_FILENAME] + IGNORE

  MODE = CONFIG['general']['mode']

  # Returns the first directory in a path, eg.
  # `foo/bar/bin.txt` becomes `foo`
  def self.top_parent_dir(path)
    Pathname.new(path).each_filename.to_a[0]
  end

  def self.sawsge
    # Gross, but easy
    Dir.chdir SRC_DIR

    # Find all files recursively
    @resource_paths = Set.new(Dir.glob('**/*').select do |path|
      File.file?(path) &&
        top_parent_dir(path) != OUT_DIRNAME &&
        !RESERVED_FILENAMES.include?(path)
    end)

    @resource_objects = Set.new
    @all_objects = Set.new

    send MODE

    resources = @resource_paths.map { |path| Resource.new(path) }
    @all_objects.merge resources

    # Delete any old builds
    FileUtils.remove_dir OUT_DIRNAME if Pathname.new(OUT_DIRNAME).exist?
    FileUtils.mkpath OUT_DIRNAME

    # Write each file
    @all_objects.each(&:build)
  end
end
