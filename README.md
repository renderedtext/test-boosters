# Test Boosters

[![Gem Version](https://badge.fury.io/rb/semaphore_test_boosters.svg)](https://badge.fury.io/rb/semaphore_test_boosters)
[![Build Status](https://semaphoreci.com/api/v1/renderedtext/test-boosters/branches/master/badge.svg)](https://semaphoreci.com/renderedtext/test-boosters)

Auto Parallelization &mdash; runs test files in multiple jobs

- [Installation](#installation)

Test Booster basics:

  - [What are Test Boosters](#what-are-test-boosters)
  - [Split Configuration](#split-configuration)
  - [Leftover Files](#split-configuration)

Test Boosters:

  - [RSpec Booster](#rspec-booster)
  - [Cucumber Booster](#cucumber-booster)
  - [Minitest Booster](#minitest-booster)
  - [ExUnit Booster](#ex-unit-booster)
  - [GoTest Booster](#go-test-booster)

## Installation

``` bash
gem install semaphore_test_boosters
````

## What are Test Boosters

Test Boosters take your test suite and split the test files into multiple jobs.
This allows you to quickly parallelize your test suite across multiple build
machines.

As an example, let's take a look at the `rspec_booster --job 1/10` command. It
lists all the files that match the `spec/**/*_spec.rb` glob in your project,
distributes them into 10 jobs, and execute the first job.

### Split Configuration

Every test booster can load a split configuration file that helps the test
booster to make a better distribution.

For example, if you have 3 RSpec Booster jobs, and you want to run:

- `spec/a_spec.rb` and `spec/b_spec.rb` in the first job
- `spec/c_spec.rb` and `spec/d_spec.rb` in the second job
- `spec/e_spec.rb` in the third job

you should put the following in your split configuration file:

``` json
[
  { "files": ["spec/a_spec.rb", "spec/b_spec.rb"] },
  { "files": ["spec/c_spec.rb", "spec/d_spec.rb"] },
  { "files": ["spec/e_spec.rb"] }
]
```

Semaphore uses Split configurations to split your test files based on their
durations in the previous builds.

### Leftover Files

Files that are part of your test suite, but are not in the split
configuration file, are called "leftover files". These files will be distributed
based on their file size in a round robin fashion across your jobs.

For example, if you have the following in your split configuration:

``` json
[
  { "files": ["spec/a_spec.rb"] }
  { "files": ["spec/b_spec.rb"] }
  { "files": ["spec/c_spec.rb"] }
]
```

and the following files in your spec directory:

``` bash
# Files from split configuration ↓

spec/a_spec.rb
spec/b_spec.rb
spec/c_spec.rb

# Leftover files ↓

spec/d_spec.rb
spec/e_spec.rb
```

When you run the `rspec_booster --job 1/3` command, the files from the
configuration's first job and some leftover files will be executed.

``` bash
rspec_booster --job 1/3

# => runs: bundle exec rspec spec/a_spec.rb spec/d_spec.rb
```

Booster will distribute your leftover files uniformly across jobs.

## RSpec Booster

The `rspec_booster` loads all the files that match the `spec/**/*_spec.rb`
pattern and uses the `~/rspec_split_configuration.json` file to parallelize your
test suite.

Example of running job 4 out of 32 jobs:

``` bash
rspec_booster --job 4/32
```

Under the hood, the RSpec Booster uses the following command:

``` bash
bundle exec rspec --format documentation --format json --out /home/<user>/rspec_report.json <file_list>
```

Optionally, you can pass additional RSpec flags with the `TB_RSPEC_OPTIONS`
environment variable. You can also set a RSpec formatter with the `TB_RSPEC_FORMATTER` environment variable.
Default formatter is `documentation`.


Example:
``` bash
TB_RSPEC_OPTIONS='--fail-fast=3' TB_RSPEC_FORMATTER=Fivemat rspec_booster --job 4/32

# will execute:
bundle exec rspec --fail-fast=3 --format Fivemat --format json --out /home/<user>/rspec_report.json <file_list>
```

## Cucumber Booster

The `cucumber_booster` loads all the files that match the `features/**/*.feature`
pattern and uses the `~/cucumber_split_configuration.json` file to parallelize
your test suite.

Example of running job 4 out of 32 jobs:

``` bash
cucumber_booster --job 4/32
```

Under the hood, the Cucumber Booster uses the following command:

``` bash
bundle exec cucumber <file_list>
```

## Minitest Booster

The `minitest_booster` loads all the files that match the `test/**/*_test.rb`
pattern and uses the `~/minitest_split_configuration.json` file to parallelize
your test suite.

Example of running job 4 out of 32 jobs:

``` bash
minitest_booster --job 4/32
```

If minitest booster is executed in a scope of a Rails project, the following is
executed:

``` bash
bundle exec rails test <file_list>
```

If minitest booster is running outside of a Rails project, the following is
executed:

``` bash
ruby -e 'ARGV.each { |f| require ".#{f}" }' <file_list>
```

If you want to run a custom command for minitest, use the
`MINITEST_BOOSTER_COMMAND` environment variable:

``` bash
export MINITEST_BOOSTER_COMMAND="bundle exec rake test"

minitest_booster --job 1/42
```

## ExUnit Booster

The `ex_unit_booster` loads all the files that match the `test/**/*_test.exs`
pattern and uses the `~/ex_unit_split_configuration.json` file to parallelize
your test suite.

Example of running job 4 out of 32 jobs:

``` bash
ex_unit_booster --job 4/32
```

Under the hood, the ExUnit Booster uses the following command:

``` bash
mix test <file_list>
```

## Go Test Booster

The `go_test_booster` loads all the files that match the `**/*_test.go`
pattern and uses the `~/go_test_split_configuration.json` file to parallelize
your test suite.

Example of running job 4 out of 32 jobs:

``` bash
go_test_booster --job 4/32
```

Under the hood, the Go Test Booster uses the following command:

``` bash
go test <file_list>
```

## Development

### Integration testing

For integration tests we use test repositories that are located in
<https://github.com/renderedtext/test-boosters-tests.git>.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/renderedtext/test-boosters.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
