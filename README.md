# sawsge

My simple static site generator for blogs or projects.

## Installation

Sawsge is availible as a
[Gem](https://rubygems.org/gems/sawsge) and as an [AUR
package](https://aur.archlinux.org/packages/sawsge).

Install as a Gem: `gem install sawsge`

**NOTE**: When installing as a Gem, Pandoc must also be
installed.

Install from the AUR: `paru -S sawsge`

## Usage

Run `sawsge [DIRECTORY]` where `[DIRECTORY]` is the source
directory root. If `[DIRECTORY]` is not provided, Sawsge
will target `./`

## File Structure

In the source directory root should exist `header.html`,
`footer.html`, and `config.toml`. Additional files may need
to exist for different modes.

## Config

Here's an example config for a project:
```toml
[general]
# For now this can only be a single directory, no
# subdirectories allowed!
out_dirname = "out"

# "blog" or "project"
mode = "project"

# If (header|footer)_filename is an empty string, no header
# or footer will be added to the rendered pages, although
# for now this will build a broken website.
header_filename = "header.html"
footer_filename = "footer.html"

# All external links will be given the `target=_blank`
# attribute, opening them in new tabs when clicked, unless
# the link has a user-set target.
external_links_target_blank = true

# A list of files, relative to the src root, to exclude from
# builds
ignore = ["README.md"]

[blog]
posts_dirname = "post"
```

# General Operation
Sawsge makes all links on the site point to directories, so
there is no `index.html` at the end of any URL
(example.com/thing/index.html vs example.com/thing/). Sawsge
will build your website to `out_dirname` in your config;
make sure there are no files in there, as they will be
deleted!

## Blog Mode
Blog mode creates a special homepage with the title and a
summary of each post, with latest posts at the top. In blog
mode, sawsge will look for posts under `posts_dirname` in
the config. In `posts_dirname`, each post should be in a
directory specifying its date in YYYY/MM/DD format, e.g.
`/[posts_dirname]/2021/03/09/index.md`. In its source, the
post should include at least one `<h1></h1>` and one
`<summary></summary>`HTML block. Both will be used to
generate the summary on the front page.

