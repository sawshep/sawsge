# frozen_string_literal: true

class Sawsge
  # An HTML page
  class Page < Resource
    attr_reader :title

    def initialize(path, config)
      super(path)

      markdown = File.read(@path)
      options = {
        :from => :markdown,
        :to   => :html
      }
      html_body_fragment = PandocRuby.convert(markdown, options)

      header = File.read config.header_path
      footer = File.read config.footer_path

      # @document = Nokogiri::HTML5(header + footer)
      # @body = Nokogiri::HTML5.fragment(header + html_body_fragment + footer)
      @document = Nokogiri::HTML5(header + html_body_fragment + footer)

      # Place body fragment after header (and before footer)
      # header_location = @document.at_css('header')
      # @body = header.add_next_sibling(@body)

      # Parse the body fragment instead of the whole document,
      # as the header may have another h1 within
      @title = begin
        h1 = @document.at_css('h1')
        h1 ? h1.content : ''
      end
      @document.at_css('title').content = @title

      if config.external_links_target_blank
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

    def build(out_dirname)
      serialized_html = @document.serialize
      out_path = File.join(out_dirname, @path.sub('index.md', 'index.html'))
      out_dir = File.join(out_dirname, File.dirname(@path))

      FileUtils.mkpath out_dir
      File.new(out_path, 'w').syswrite(serialized_html)
    end
  end
end
