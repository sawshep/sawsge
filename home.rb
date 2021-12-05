# The homepage
class Home < Page
  def initialize(path, posts)
    super(path)
    posts.each do |post|
      # Adds collapseable summary of each post on the front
      # page
      link =  "<details open>" +
                "<summary>" +
                  "<a href=\"/#{File.dirname(post.path)}\">#{post.title}</a> <date>#{post.date}</date>" +
                "</summary>" +
                "<p>#{post.summary}</p>" +
                "<a href=\"#{File.dirname(post.path)}\">Read more</a>" +
              "</details>";
      @content += link
    end
  end
end
