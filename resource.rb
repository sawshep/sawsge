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
