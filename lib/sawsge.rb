# frozen_string_literal: true

require 'fileutils'
require 'nokogiri'
require 'pandoc-ruby'
require 'parallel'
require 'pathname'
require 'set'
require 'tomlrb'
require 'uri'

require 'sawsge/resource'
require 'sawsge/page'
require 'sawsge/post'
require 'sawsge/home'
require 'sawsge/blog'
require 'sawsge/project'
require 'sawsge/config'

# Returns the first directory in a path, eg.
# `foo/bar/bin.txt` becomes `foo`
def top_parent_dir(path)
  Pathname.new(path).each_filename.to_a[0]
end

class Sawsge
  HELP_STRING = 'Usage: sawsge [DIRECTORY]'

  CONFIG_FILENAME = 'config.toml'

  def initialize(src_dir)
    @config = Config.new(src_dir)
  end

  def self.cli
    src_dir = ARGV[0] || Dir.pwd
    new(src_dir).build
  end

  def build
    # Gross, but easy
    Dir.chdir @config.src_dir

    # Find all files recursively
    @resource_paths = Dir.glob('**/*').select do |path|
      File.file?(path) &&
        top_parent_dir(path) != @config.out_dirname &&
        # Exclude explicitly ignored files
        !@config.reserved_filenames.include?(path)
    end

    @resource_objects = Set.new
    @all_objects = Set.new

    # Execute blog or project specific code.
    send @config.mode

    resources = @resource_paths.map { |path| Resource.new(path) }
    @all_objects += resources

    # Delete any old builds
    FileUtils.remove_dir @config.out_dirname if Pathname.new(@config.out_dirname).exist?
    FileUtils.mkpath @config.out_dirname

    # Write each file
    Parallel.each(@all_objects) { |x| x.build @config.out_dirname }
  end
end
