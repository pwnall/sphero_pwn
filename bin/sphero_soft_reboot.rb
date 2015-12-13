#!/usr/bin/env ruby

require_relative '../lib/sphero_pwn.rb'

unless ARGV.length == 1
  puts <<END_USAGE
Usage: #{$PROGRAM_NAME} /dev/bluetooth-device
END_USAGE
  exit 1
end

rfconn_path = ARGV[0]
channel = SpheroPwn::Channel.new rfconn_path
session = SpheroPwn::Session.new channel

session.send_command SpheroPwn::Commands::EnterBootloader.new
response = session.recv_until_response
unless response.code == :ok
  puts "Failed to enter bootloader. Code: #{response.code}\n"
  exit 1
end
puts "Entered bootloader\n"

session.send_command SpheroPwn::Commands::BootMainApp.new
response = session.recv_until_response
unless response.code == :ok
  puts "Failed to boot main application. Code: #{response.code}\n"
  exit 1
end
puts "Entered main app\n"

session.close
exit 0
