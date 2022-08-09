# frozen_string_literal: true

class Sawsge
  # A blogpost style HTML page
  class Post < Page
    attr_reader :date, :summary

    def initialize(path, config)
      super(path, config)

      # Get the summary and date of the post
      @summary = @document.css('summary').first.content
      @date = begin
          date = @document.css('time').first
          date ? date.content : ''
      end
    end
  end
end
