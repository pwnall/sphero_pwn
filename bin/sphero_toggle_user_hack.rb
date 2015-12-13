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

session.send_command SpheroPwn::Commands::GetDeviceMode.new
response = session.recv_until_response
unless response.code == :ok
  puts "Failed to retrieve device mode. Code: #{response.code}\n"
  exit 1
end
puts "Current device mode: #{response.mode}\n"

new_mode = (response.mode == :normal) ? :user_hack : :normal
puts "Switching device to mode: #{new_mode}\n"

session.send_command SpheroPwn::Commands::SetDeviceMode.new(new_mode)
response = session.recv_until_response
unless response.code == :ok
  puts "Failed to set device mode. Code: #{response.code}\n"
  exit 1
end

puts "New mode set successfully\n"
session.close
exit 0
