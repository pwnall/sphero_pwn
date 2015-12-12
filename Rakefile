# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "sphero_pwn"
  gem.homepage = "http://github.com/pwnall/sphero_pwn"
  gem.license = "MIT"
  gem.summary = %Q{Wrapper for Sphero's bluetooth protocol}
  gem.description = %Q{This library is currently focused on reverse-engineering
      the undocumented parts of Sphero}
  gem.email = "victor@costan.us"
  gem.authors = ["Victor Costan"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
