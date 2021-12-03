# A blogpost style HTML page
class Post < Page
  attr_reader :date, :summary
  def initialize(path)
    super(path)

    # There's got to be a more idiomatic way to do this! The
    # current implementation is disguisting.
    parts = @path.each_filename.to_a[1..]
    [SRC_FOLDER, POST_FOLDER].each do |dirname|
      parts.delete(dirname)
    end
    @date = "#{parts[0]}-#{parts[1]}-#{parts[2]}"
    @content.sub!("</h1>", "</h1><date>#{@date}</date>")

    # Look what's in <summary></summary>
    @summary = parse_tag(@content, "summary")
  end
end
