# LazyMigrate

Easily manage rails migrations with a mini UI that can be invoked in your console or on the command line.

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jesseduffield/lazy_migrate.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
