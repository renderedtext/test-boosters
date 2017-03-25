# Test Boosters

[![Gem Version](https://badge.fury.io/rb/semaphore_test_boosters.svg)](https://badge.fury.io/rb/semaphore_test_boosters)
[![Build Status](https://semaphoreci.com/api/v1/renderedtext/test-boosters/branches/master/badge.svg)](https://semaphoreci.com/renderedtext/test-boosters)

Auto Parallelization &mdash; runs test files in multiple jobs

- [Installation](#installation)

- RSpec Booster
  - [Running RSpec jobs](#rspec-booster)
  - [RSpec Split Configuration](#rspec-split-configuration)
  - [Leftover RSpec specs](#leftover-rspec-specs)
  - [Passing custom options to RSpec](#custom-rspec-options)

- Cucumber Booster
  - [Running Cucumber jobs](#cucumber-booster)
  - [Cucumber Split Configuration](#cucumber-split-configuration)
  - [Leftover Cucumber specs](#leftover-rspec-specs)
  - [Passing custom options to Cucumber](#custom-cucumber-options)

## Installation

``` bash
gem install semaphore_test_boosters
````

## RSpec Booster

The RSpec Booster splits your RSpec test suite to multiple jobs.

For example, if you want to split your RSpec test suite into 21 jobs, and run
then executed the 3rd job, use the following command:

``` bash
rspec_booster --thread 3/21
```

By default, RSpec Booster will distribute your spec files based on their size
into multiple jobs. This is OK for your first run, but the distribution is
usually suboptimal.

If you want to achieve better build times, and split your test files more
evenly, you need to provide a split configuration file for RSpec Booster.

On Semaphore, this file is generated before every build based on the duration's
of your previous builds.

### RSpec Split Configuration

The `rspec_split_configuration.json` should be placed in your home directory and
should contain the list of files for each RSpec Booster job.

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

### Leftover RSpec specs

Files that are part of your RSpec test suite, but are not in the split
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

### Custom RSpec options

By default, `rspec_booster` passes the following options to RSpec:

``` bash
--format documentation --format json --out ~/rspec_report.json
```

If you want to pass additional parameters to RSpec, you can do that by setting
the `TB_RSPEC_OPTIONS` environment variable.

For example, if you want to pass a `--fail-fast` option to RSpec, you can do it
like this:

``` bash
export TB_RSPEC_OPTIONS = '--fail-fast'

rspec_booster --job 2/3

# => runs: bundle exec rspec --fail-fast --format documentation --format json --out ~/rspec_report.json <file_list>
```

## Cucumber Booster

The Cucumber Booster splits your Cucumber test suite to multiple jobs.

For example, if you want to split your Cucumber test suite into 21 jobs, and run
then executed the 3rd job, use the following command:

``` bash
cucumber_booster --thread 3/21
```

By default, Cucumber Booster will distribute your spec files based on their size
into multiple jobs. This is OK for your first run, but the distribution is
usually suboptimal.

If you want to achieve better build times, and split your test files more
evenly, you need to provide a split configuration file for Cucumber Booster.

On Semaphore, this file is generated before every build based on the duration's
of your previous builds.

### Cucumber Split Configuration

The `cucumber_split_configuration.json` should be placed in your home directory
and should contain the list of files for each Cucumber Booster job.

For example, if you have 3 Cucumber Booster jobs, and you want to run:

- `features/a.feature` and `spec/b.feature` in the first job
- `features/c.feature` and `spec/d.feature` in the second job
- `features/e.feature` in the third job

you should put the following in your split configuration file:

``` json
[
  { "files": ["features/a.feature", "features/b.feature"] },
  { "files": ["features/c.feature", "features/d.feature"] },
  { "files": ["features/e.feature"] }
]
```

### Leftover files

Files that are part of your Cucumber test suite, but are not in the split
configuration file, are called "leftover files". These files will be distributed
based on their file size in a round robin fashion across your jobs.

For example, if you have the following in your split configuration:

``` json
[
  { "files": ["features/a.feature"] }
  { "files": ["features/b.feature"] }
  { "files": ["features/c.feature"] }
]
```

and the following files in your spec directory:

``` bash
features/a.feature
features/b.feature
features/c.feature
features/d.feature
features/e.feature
```

When you run the `cucumber_booster --job 1/3` command, the files from the
configuration's first job and some leftover files will be executed.

``` bash
cucumber_booster --job 1/3

# => runs: bundle exec cucumber features/a.feature features/d.feature
```

### Custom Cucumber options

Currently, you can't pass custom options to Cucumber.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/renderedtext/test-boosters.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
