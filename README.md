delta_test
==========

delta_test analyzes your tests and runs only related tests for your file changes.


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


Usage
-----

First you'll need to run full tests to create **Dependencies table**:

```bash
$ git checkout master
$ delta_test exec bundle exec rspec
```

Then, on other branch:

```bash
$ git checkout -b feature/something_awesome
$ # Make changes & create commits...
$ delta_test exec bundle exec rspec  # runs only related tests for changes from master
```


Advanced usage
--------------

### Command

```
usage: delta_test [--base=<base>] [--head=<head>] [--verbose] <command> [<args>]
                  [-v]

options:
    --base=<base>  A branch or a commit id to diff from.
                   <head> is default to master.

    --head=<head>  A branch or a commit id to diff to.
                   <head> is default to HEAD. (current branch you're on)

    --verbose      Print more output.

    -v             Show version.

commands:
    list           List related spec files for changes between base and head.
                   head is default to master; base is to the current branch.

    table          Show dependencies table.

    exec <script>  Rxecute test script using delta_test.
                   Run command something like `delta_test list | xargs script'.
```

### Configurations

```yaml
table_file: tmp/.delta_test_dt

patterns:
  - lib/**/*.rb
  - app/**/*.rb

exclude_patterns:
  - lib/batch/*.rb

custom_mappings:
  spec/features/i18n_spec.rb:
    - config/locales/**/*.yml
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
