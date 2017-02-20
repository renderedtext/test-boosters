$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'test_boosters'

module Setup
  def self.a() "test_data/a_spec.rb" end
  def self.b() "test_data/b_spec.rb" end
  def self.c() "test_data/c_spec.rb" end

  def self.input_specs()     [a, b, c]  end

  def self.expected_specs()  [a, c, b]  end
end
