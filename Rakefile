$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "bundler/version"
require "shoulda/tasks"
require 'lib/gowalla'

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.ruby_opts = ["-rubygems"] if defined? Gem
  test.libs << "lib" << "test"
  test.pattern = "test/**/*_test.rb"
end
 
desc "Build the gem"
task :build do
  system "gem build gowalla.gemspec"
end
 
desc "Build and release the gem"
task :release => :build do
  system "gem push gowalla-#{Gowalla::VERSION}.gem"
end

task :default => :test