:warning: **currently in development**

delta_test
==========

[![Circle CI](https://circleci.com/gh/creasty/delta_test.svg?style=shield)](https://circleci.com/gh/creasty/delta_test)
[![Code Climate](https://codeclimate.com/github/creasty/delta_test/badges/gpa.svg)](https://codeclimate.com/github/creasty/delta_test)
[![Test Coverage](https://codeclimate.com/github/creasty/delta_test/badges/coverage.svg)](https://codeclimate.com/github/creasty/delta_test/coverage)

**It's kinda "[delta update](http://en.wikipedia.org/wiki/Delta_update)" for RSpec.**

It basically do two things:

1. Analyzes your tests and creates a dependencies table
2. Based on the dependencies table and git diff,  
   only runs partial specs that are considered to be related to the file changes.


Setup
-----

### Installation

Add this line to your Gemfile:

```ruby
gem 'delta_test', group: :test
```

### Configuration

Create configuration file at your project root directory.

```bash
$ vi delta_test.yml
```

```yaml
patterns:
  - lib/**/*.rb
  - app/**/*.rb
```

### Rspec

Include delta_test in your `spec/spec_helper.rb`.

```ruby
require 'delta_test'
require 'delta_test/spec_helpers'

RSpec.configure do |config|

  config.include DeltaTest::SpecHelpers

end
```


Usage
-----

For the first time and whenever on master, it'll run full test cases to create **dependencies table**:

```bash
$ git checkout master
$ delta_test exec rspec
```

And on other branch, it'll run only related tests for your changes from master:

```bash
$ git checkout -b feature/something_awesome
$ # Make changes & create commits...
$ delta_test exec rspec
```


Advanced usage
--------------

### Command

```
usage: delta_test <command> [--base=<base>] [--head=<head>] [--verbose] [<args>]
                  [-v|--version]

options:
    --base=<base>  A branch or a commit id to diff from.
                   <head> is default to master.

    --head=<head>  A branch or a commit id to diff to.
                   <head> is default to HEAD. (current branch you're on)

    --verbose      Print more output.

    -v, --version  Show version.

commands:
    list           List related spec files for changes between base and head.
                   head is default to master; base is to the current branch.

    table          Show dependencies table.

    exec <script> [-- <files>]
                   Execute test script using delta_test.
                   Run command something like `delta_test list | xargs script'.
```

#### `exec` example

RSpec command is rewritten to:

```bash
$ bundle exec rspec
↓
$ bundle exec delta_test exec rspec
```

With file lists:

```bash
$ bundle exec rspec spec/{models,controllers}
↓
$ bundle exec delta_test exec rspec -- spec/{models,controllers}
```

And to colorize RSpec outputs, use `--tty` option of `rspec` command:

```bash
$ bundle exec delta_test exec rspec --tty
```

Also delta_test supports [parallel_tests](https://github.com/grosser/parallel_tests):

```bash
$ bundle exec parallel_test -t rspec -n 4 spec/features
↓
$ bundle exec delta_test exec parallel_test -t rspec -n 4 -- spec/features
```

### Configurations

```yaml
table_file: tmp/.delta_test_dt

patterns:
  - lib/**/*.rb
  - app/**/*.rb

exclude_patterns:
  - lib/batch/*.rb

full_test_patterns:
  - Gemfile.lock

custom_mappings:
  spec/features/i18n_spec.rb:
    - config/locales/**/*.yml
```


Testing
-------

Run units tests:

```bash
$ rake test  # or you can use `rspec`
```

Run integration tests:

```bash
$ (cd spec/rails && bundle install)
$ rake rails:test
```


Contributing
------------

Contributions are always welcome!

### Bug reports

1. Ensure the bug can be reproduced on the latest master
1. Check it's not a duplicate
1. Raise an issue

### Pull requests

1. Fork the repository
1. Create a branch
1. Write test-driven code
1. Update the documentation if necessary
1. Create a new pull request


License
-------

This project is released under the MIT license. See `LICENSE.txt` file for details.


Maintainer
----------

[@creasty](http://github.com/creasty)
