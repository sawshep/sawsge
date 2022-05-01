# frozen_string_literal: true

require 'tomlrb'

class Sawsge
  class Config
    attr_reader :external_links_target_blank,
                :posts_dirname, :footer_filename, :reserved_filenames,
                :src_dir, :out_dirname, :mode, :header_filename,
                :header_path, :footer_path

    def initialize(src_dir)
      config_path = File.join(src_dir, CONFIG_FILENAME)
      config = Tomlrb.load_file(config_path, symbolize_keys: true)

      @src_dir = File.expand_path src_dir

      @out_dirname = config.dig(:general, :out_dirname)
      @mode = config[:general][:mode]

      @header_filename = config.dig(:general, :header_filename)
      @footer_filename = config.dig(:general, :footer_filename)

      @header_path = File.expand_path(File.join(@src_dir, @header_filename))
      @footer_path = File.expand_path(File.join(@src_dir, @footer_filename))

      @reserved_filenames = config[:general][:ignore] + [CONFIG_FILENAME, @header_filename, @footer_filename]

      @external_links_target_blank = config[:general][:external_links_target_blank]

      @posts_dirname = config[:blog][:posts_dirname]
    end
  end
end
