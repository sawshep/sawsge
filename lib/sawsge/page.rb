# frozen_string_literal: true

module Sawsge
  # An HTML page
  class Page < Resource
    attr_reader :title

    def initialize(path)
      super(path)
      html_body_fragment = PandocRuby.convert(File.new(@path, 'r').read, from: :markdown, to: :html)
      @document = Nokogiri::HTML5(HEADER + FOOTER)
      @body = Nokogiri::HTML5.fragment(html_body_fragment)

      # Place body fragment after header (and before footer)
      header = @document.at_css('header')
      @body = header.add_next_sibling(@body)

      # Parse the body fragment instead of the whole document,
      # as the header may have another h1 within
      @title = begin
        h1 = @body.at_css('h1')
        h1 ? h1.content : ''
      end
      @document.at_css('title').content = @title

      if EXTERNAL_LINKS_TARGET_BLANK
        # For any `a` tag where the href attribute has no
        # hostname (external link) and no existing `target`
        # attribute, add an attribute `target` with value
        # blank. mailto links are also ignored, as common
        # obfuscation techniques can interfere with Nokogiri.
        external_links = @document.css('a').reject do |link|
          uri = URI(link['href'])
          # If a link is malformed, it's not sawsge's problem
          # to fix.
        rescue URI::InvalidComponentError
          false
        else
          host = uri.host
          scheme = uri.scheme
          host.nil? or host.empty? or scheme == 'mailto' or !link['target'].nil?
        end
        external_links.each { |link| link['target'] = '_blank' }
      end
    end

    def build
      serialized_html = @document.serialize
      out_path = File.join(OUT_DIRNAME, @path.sub('index.md', 'index.html'))
      out_dir = File.join(OUT_DIRNAME, File.dirname(@path))

      FileUtils.mkpath out_dir
      File.new(out_path, 'w').syswrite(serialized_html)
    end
  end
end
