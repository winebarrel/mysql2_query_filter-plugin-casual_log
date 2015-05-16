require 'mysql2_query_filter/plugin/casual_log'
require 'stringio'
require "time"
require "timecop"

ENV["TZ"] = "UTC"
include Term::ANSIColor

RSpec.configure do |config|
  config.before(:all) do
    Mysql2QueryFilter.enable!
  end

  config.before(:each) do
    Mysql2QueryFilter.clear!
  end
end
