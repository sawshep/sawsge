# The homepage
class Home < Page
  def initialize(path, posts)
    super(path)
    posts.each_with_index do |post, i|
      # Adds title, date, summary of each post with first
      # post expanded
      #link =  "<details#{i == 0 ? " open" : ""}>" +
      link =  "<details open>" +
                "<summary>" +
                  "<a href=\"/#{File.dirname(post.path)}\">#{post.title}</a> <date>#{post.date}</date>" +
                "</summary>" +
                "<p>#{post.summary}</p>" +
                "<a href=\"#{post.path.dirname}\">Read more</a>" +
              "</details>";
      @content += link
    end
  end
end
