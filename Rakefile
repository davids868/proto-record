# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

PROTOS_PATH = "spec/support/protos"

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new

task :delete_protos do
  FileUtils.rm(Dir.glob("#{PROTOS_PATH}/*.rb"))
  puts "Generated protobuf classes have been deleted"
end

task :compile_protos, [] => :delete_protos do
  protos = Dir.glob("spec/support/protos/*.proto").join(" ")
  sh "grpc_tools_ruby_protoc -I #{PROTOS_PATH} --ruby_out=#{PROTOS_PATH} --grpc_out=#{PROTOS_PATH} #{protos}"
  puts "Generated new protobuf classes"
end

task default: %i[delete_protos compile_protos spec rubocop]
