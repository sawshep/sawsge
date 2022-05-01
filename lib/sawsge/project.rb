# frozen_string_literal: true

class Sawsge
  def project
    page_paths = @resource_paths.select { |path| File.extname(path) == '.md' }

    @resource_paths -= page_paths

    page_objects = page_paths.map { |path| Page.new(path, @config) }

    @all_objects.merge page_objects
  end
end
