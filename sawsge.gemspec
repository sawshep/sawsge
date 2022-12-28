# frozen_string_literal: true

require_relative 'lib/sawsge/version'

Gem::Specification.new do |s|
  s.name        = 'sawsge'
  s.version     = Sawsge::VERSION
  s.executables << 'sawsge'
  s.summary     = 'Simple Markdown static site generator for blogs or projects'
  s.description = 'Sawsge is an opinionated static site generator with TOML-configurable modes for blogs and projects. It takes Markdown files as source and uses Pandoc behind the scences to generate HTML files.'
  s.authors     = ['Sawyer Shepherd']
  s.email       = 'contact@sawyershepherd.org'
  s.files       = %w[
    Gemfile
    LICENSE
    README.md
    bin/sawsge
    lib/sawsge.rb
    lib/sawsge/blog.rb
    lib/sawsge/config.rb
    lib/sawsge/home.rb
    lib/sawsge/page.rb
    lib/sawsge/post.rb
    lib/sawsge/project.rb
    lib/sawsge/resource.rb
    lib/sawsge/version.rb
    sawsge.gemspec
  ]
  s.homepage    = 'https://github.com/sawshep/sawsge'
  s.license     = 'GPL-3.0'
  s.required_ruby_version = '>= 2.7'
  s.add_runtime_dependency 'pandoc-ruby', '~> 2.1'
  s.add_runtime_dependency 'tomlrb', '~> 2.0', '>= 2.0.1'
  s.add_runtime_dependency 'nokogiri', '~> 1.12', '>= 1.12.4'
  s.add_runtime_dependency 'parallel', '~> 1.22', '>= 1.22.1'
end
