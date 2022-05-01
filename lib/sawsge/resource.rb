# frozen_string_literal: true

class Sawsge
  # Any generic file in the website directory
  class Resource
    attr_reader :path

    def initialize(path)
      # Path is relative to SRC_DIR, does not include it
      @path = path
    end

    def build(out_dirname)
      FileUtils.mkpath File.join(out_dirname, File.dirname(@path))
      FileUtils.cp @path, File.join(out_dirname, @path)
    end
  end
end
