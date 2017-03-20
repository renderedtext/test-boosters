# Test Boosters

[![Gem Version](https://badge.fury.io/rb/semaphore_test_boosters.svg)](https://badge.fury.io/rb/semaphore_test_boosters)

Auto Parallelization &mdash; runs test files in multiple threads.

## Installation

``` bash
gem install semaphore_test_boosters
````

## Usage

### RSpec Booster

The RSpec booster command allows you to run one out of several parallel RSpec
threads.

``` bash
rspec_booster --thread 3
```

#### RSpec Split Configuration

The `rspec_split_configuration.json` located in your home directory is used to
pass test files to the booster. On Semaphore, this file contains a list of
specs files distributed across threads based on their estimated durations.

For example, if you have a `rspec_split_configuration.json` located in your home
directory with the following content:

``` json
[
  { "files": ["spec/a_spec.rb", "spec/b_spec.rb"] },
  { "files": ["spec/c_spec.rb", "spec/d_spec.rb"] },
  { "files": ["spec/e_spec.rb"] }
]
```

The `rspec_booster` command will deduce that you have 3 threads in total and
that you want to run `spec/a_spec.rb` and `spec/b_spec.rb` on the first thread,
`spec/c_spec.rb` and `spec/d_spec.rb` on the second thread, and `spec/e_spec.rb`
on the third thread.

#### Leftover files

The RSpec Split Configuration contains only those spec files that have an
estimated duration recorded on Semaphore. New files, whose estimated duration
is not yet stored on Semaphore will be distributed across threads in based on
their file size in a round robin fashion.

For example, if you have the following split configuration:

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

When you run the `rspec_booster --thread 1` command, the files from the
configuration's first thread and some leftover files will be executed.

``` bash
rspec_booster --thread 1

# => runs: bundle exec rspec spec/a_spec.rb spec/d_spec.rb
```

#### Custom RSpec options

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

rspec_booster --thread 2

# => runs: bundle exec rspec --fail-fast --format documentation --format json --out ~/rspec_report.json <file_list>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/renderedtext/test-boosters.


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
