require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/spec'
require 'mocha/mini_test'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sphero_pwn'

class MiniTest::Test
  # Creates a test channel that records to a file inside the data directory.
  #
  # The caller is responsible for closing the channel at the end of the test.
  #
  # @param {Symbol} test_case_name used to derive the path to the recording
  #   file
  # @return {SpheroPwn::Session} a session whose backing channel records to /
  #   replays from the recording file for the given test case
  def new_test_session(test_case_name)
    rfconn_path = ENV['SPHERO_DEV']
    recording_path = File.join File.dirname(__FILE__), 'data',
        "#{test_case_name}.txt"
    channel = SpheroPwn.new_test_channel rfconn_path, recording_path
    SpheroPwn::Session.new channel
  end
end

MiniTest.autorun
