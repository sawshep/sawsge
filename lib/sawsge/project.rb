# frozen_string_literal: true

module Sawsge
  def self.project
    page_paths = @resource_paths.select { |path| File.extname(path) == '.md' }

    @resource_paths.subtract page_paths

    page_objects = page_paths.map { |path| Page.new(path) }

    @all_objects.merge page_objects
  end
end
