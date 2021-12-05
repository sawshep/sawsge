# An HTML page
class Page < Resource
  attr_reader :title
  def initialize(path)
    super(path)
    @content = PandocRuby.convert(File.new(@path, "r").read, from: :markdown, to: :html)
    @title = parse_tag(@content, "h1")
    @content = HEADER + @content + FOOTER
    # Sub replaces the first occurance
    @content.sub!("<title></title>", "<title>#{@title}</title")
  end

  def build
    FileUtils.mkpath(File.join(OUT_DIRNAME, File.dirname(@path)))
    File.new(File.join(OUT_DIRNAME, @path.sub("index.md", "index.html")), "w").syswrite(@content)
  end
end
