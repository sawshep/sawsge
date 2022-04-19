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
  s.files       = [
    'LICENSE',
    'README.md',
    'bin/sawsge',
    'sawsge.gemspec',
    'lib/sawsge/version.rb',
    'lib/sawsge.rb',
    'lib/blog.rb',
    'lib/home.rb',
    'lib/page.rb',
    'lib/post.rb',
    'lib/project.rb',
    'lib/resource.rb'

  ]
  s.homepage    = 'https://github.com/sawshep/sawsge'
  s.license     = 'GPL-3.0'
  s.required_ruby_version = '>= 3.0'
  s.add_runtime_dependency 'pandoc-ruby', '~> 2.1'
  s.add_runtime_dependency 'toml', '~> 0.3'
end
