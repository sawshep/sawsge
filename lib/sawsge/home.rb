# frozen_string_literal: true

class Sawsge
  # The homepage
  class Home < Page
    def initialize(path, posts, config)
      super(path, config)

      posts.each_with_index do |post, _i|
        # Adds collapseable summary of each post on the front
        # page
        summary_fragment = Nokogiri::HTML5.fragment <<~HTML
          <details open>
            <summary>
              <a href=\"/#{File.dirname(post.path)}\">#{post.title}</a> <date>#{post.date}</date>
            </summary>
            <p>#{post.summary}</p>
            <a href=\"#{File.dirname(post.path)}\">Read more</a>
          </details>
        HTML
        @document.at_css('footer').add_previous_sibling summary_fragment
      end

    end
  end
end
