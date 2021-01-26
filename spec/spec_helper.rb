# frozen_string_literal: true

require "rspec"
require "pry"
require "pry-byebug"
require "active_record"
require "proto_record"
require "support/support"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.after(:suite) do
    FileUtils.rm(DB_FILE)
    ActiveRecord::Base.connection.close
  end

  config.filter_run_when_matching :focus

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
