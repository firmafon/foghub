require_relative '../lib/foghub/foghub'
require_relative '../lib/foghub/parser'
require_relative '../lib/foghub/fogbugz/fogbugz'

require 'rubygems'
gem 'minitest' # ensures you're using the gem, and not the built in MT
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/mock'
require 'rack/test'
require 'rr'

ENV['RACK_ENV'] = 'test'

class MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include RR::Adapters::TestUnit

  def self.test(description, &block)
    define_method("test_" + description.split.join('_').gsub(/\W/, ''), block)
  end
end
