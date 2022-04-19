module Sawsge
  # Any generic file in the website directory
  class Resource
    attr_reader :path
    def initialize(path)
      # Path is relative to SRC_DIR, does not include it
      @path = path
    end
    def build
      FileUtils.mkpath File.join(OUT_DIRNAME, File.dirname(@path))
      FileUtils.cp @path, File.join(OUT_DIRNAME, @path)
    end
  end
end
