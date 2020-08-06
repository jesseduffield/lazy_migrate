# LazyMigrate

Easily manage rails migrations with a mini UI that can be invoked in your console or on the command line.

![](/github/demo.gif)

I am sick and tired of having to manually copy and paste version numbers from my migration filenames whenever I have to do anything more complicated than `rails db:migrate`! So I made a gem that easily plugs into a rails app and makes it all a little easier.

Although most of this just forwards the commands directly to rails, one feature goes a step beyond. If you have ever pulled the latest changes on master only to find that somebody managed to merge a migration before you merged yours, you may be familiar with the dance of:
1) `down`'ing your migration
2) obtaining a new version timestamp
3) replacing the version in your migration's filename
4) up'ing the migration again

This gem lets you do all that with the press of a button (via the `bring to top` option), so you don't need to break a sweat trying to merge your migration before somebody else beats you to the punch.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lazy_migrate'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lazy_migrate

## Usage

From within a rails console, go

```ruby
LazyMigrate.run
```

You can also invoke lazy_migrate as a rake task either by adding the following to your Rails app Rakefile:

```ruby
spec = Gem::Specification.find_by_name('lazy_migrate')
load "#{spec.gem_dir}/lib/tasks/lazy_migrate.rake"
```

Or by creating a rake task yourself like so:

```ruby
# in lib/tasks/lazy_migrate.rake
# frozen_string_literal: true

require 'lazy_migrate'

namespace :lazy_migrate do
  desc 'runs lazy_migrate'
  task run: :environment do
    LazyMigrate.run
  end
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies.


To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

We use [Appraisal](https://github.com/thoughtbot/appraisal) to test the gem against different rails version like so:

```
bundle exec appraisal

bundle exec appraisal rails-5-1-5 rspec
bundle exec appraisal rails-5-2-4-3 install
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jesseduffield/lazy_migrate.
If anybody wants this to work with the [Data Migrate](https://rubygems.org/gems/data_migrate/versions/1.2.0) gem let me know, currently it's only for schema migrations.
Hope you like types! Cos this gem uses [Sorbet](https://sorbet.org/).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
