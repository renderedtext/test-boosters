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

Semaphore uses Split configurations to split your test files based their
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
spec/a_spec.rb
spec/b_spec.rb
spec/c_spec.rb
spec/d_spec.rb
spec/e_spec.rb
```

When you run the `rspec_booster --job 1/3` command, the files from the
configuration's first job and some leftover files will be executed.

``` bash
rspec_booster --job 1/3

# => runs: bundle exec rspec spec/a_spec.rb spec/d_spec.rb
```

## RSpec Booster

The `rspec_booster` loads all the files that match the `spec/**/*_spec.rb`
pattern and uses the `~/rspec_split_configuration.json` file to parallelize your
test suite.

Example of running job 4 out of 32 jobs:

``` bash
rspec_booster --job 4/32
```

Under the hood, the RSpec booster uses the following command:

``` bash
bundle exec rspec --format documentation --format json --out /home/<user>/rspec_report.json <file_list>
```

Optionally, you can pass additional RSpec flags with the `TB_RSPEC_OPTIONS`
environment variable:

``` bash
TB_RSPEC_OPTIONS='--fail-fast=3' rspec_booster --job 4/32
```

The above command will execute:

``` bash
bundle exec rspec --fail-fast=3 --format documentation --format json --out /home/<user>/rspec_report.json <file_list>
```

## Cucumber Booster

The `cucumber_booster` loads all the files that match the `features/**/*.feature`
pattern and uses the `~/cucumber_split_configuration.json` file to parallelize
your test suite.

Example of running job 4 out of 32 jobs:

``` bash
cucumber_booster --job 4/32
```

Under the hood, the RSpec booster uses the following command:

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

Under the hood, the RSpec booster uses the following command:

``` bash
ruby -e 'ARGV.each { |f| require ".#{f}" }' <file_list>
```

## ExUnit Booster

## GoTest Booster


## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/renderedtext/test-boosters.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
