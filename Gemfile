# frozen_string_literal: true

source "https://rubygems.org"

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
#
# To upgrade, run `bundle update`.

# Dependeny hell, let "minimal-mistakes-jekyll" decide and add missing ones one-by one
#gem "jekyll", "~> 4.2"

gem "minimal-mistakes-jekyll"

gem "rake"
gem "csv"
gem "base64"
gem "bigdecimal"
gem "faraday-retry"
# take care, the default dependency of minimal-mistakes-jekyll.4.24.0 is mercenary-0.3.6
# that could lead to build error:
# /opt/homebrew/Cellar/ruby/3.3.0/lib/ruby/3.3.0/logger.rb:384:in `level': undefined method `[]' for nil (NoMethodError)
#    @level_override[Fiber.current] || @level
gem "mercenary", "~> 0.4"

# The following plugins are automatically loaded by the theme-gem:
# ???
#   gem "jekyll-remote-theme"
#   gem "jekyll-paginate"
#   gem "jekyll-sitemap"
#   gem "jekyll-gist"
#   gem "jekyll-feed"
#   gem "jekyll-include-cache"
#
# Gems loaded irrespective of site configuration.
# If you have any other plugins, put them here!
# Cf. https://jekyllrb.com/docs/plugins/installation/
group :jekyll_plugins do

    gem "jekyll-remote-theme"
    gem "jekyll-paginate"
    gem "jekyll-sitemap"
    gem "jekyll-gist"
    gem "jekyll-feed"

    # Doc mentiones only these are needed if using remote
    # https://github.com/HofiOne/minimal-mistakes
    #
    gem "jekyll-include-cache"
    #gem "github-pages"
end
