#!/usr/bin/env ruby

require_relative '../lib/sphero_pwn.rb'

unless ARGV.length == 3
  puts <<END_USAGE
Usage: #{$PROGRAM_NAME} /dev/bluetooth-device flag_name {true|false}

Known flags: #{SpheroPwn::Commands::SetPermanentFlags::FLAGS.keys.join(' ')}
END_USAGE
  exit 1
end

rfconn_path = ARGV[0]
channel = SpheroPwn::Channel.new rfconn_path
session = SpheroPwn::Session.new channel

session.send_command SpheroPwn::Commands::GetPermanentFlags.new
response = session.recv_until_response
unless response.code == :ok
  puts "Failed to retrieve current flags. Code: #{response.code}\n"
  exit 1
end
puts "Current flags: #{response.flags.inspect}\n"

new_flags = response.flags.merge({ ARGV[1].to_sym => (ARGV[2] == 'true') })
puts "New flags: #{new_flags}\n"

session.send_command SpheroPwn::Commands::SetPermanentFlags.new(new_flags)
response = session.recv_until_response
unless response.code == :ok
  puts "Failed to set new flags. Code: #{response.code}\n"
  exit 1
end

puts "New flags set successfully\n"
session.close
exit 0
