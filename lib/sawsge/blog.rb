# frozen_string_literal: true

class Sawsge
  def blog
    home_path = 'index.md'

    # Does not work if you have parent directories for your
    # posts dir, e.g. you set posts_dirname in config.toml to
    # foo/bar/baz/etc...
    post_paths = @resource_paths.select do |path|
      top_parent_dir(path) == @config.posts_dirname && File.extname(path) == '.md'
    end
    # So posts are added to Home in chronological order
    post_paths.reverse!

    @resource_paths -= post_paths
    @resource_paths.delete home_path

    post_objects = post_paths.map { |path| Post.new(path, @config) }
    home_object = Home.new(home_path, post_objects, @config)
    @all_objects = post_objects + [home_object]
  end
end
