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

    @resource_paths -= post_paths
    @resource_paths.delete home_path

    post_objects = post_paths.map { |path| Post.new(path, @config) }

    post_objects.sort_by! { |x| x.date }
    # Posts are now in reverse chronological order

    i_last_nil_date = 0
    while post_objects[i_last_nil_date].date.empty?
      i_last_nil_date += 1
    end

    post_objects.rotate!(i_last_nil_date).reverse!
    # Posts are now in chronological order with dateless
    # posts being first

    home_object = Home.new(home_path, post_objects, @config)
    @all_objects = post_objects + [home_object]
  end
end
