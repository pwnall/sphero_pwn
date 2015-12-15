#!/usr/bin/env ruby

require_relative '../lib/sphero_pwn.rb'

require 'pp'

unless ARGV.length == 1
  puts <<END_USAGE
Usage: #{$PROGRAM_NAME} /dev/bluetooth-device

The block name can be soul|factory_config|user_config.
END_USAGE
  exit 1
end

rfconn_path = ARGV[0]
channel = SpheroPwn::Channel.new rfconn_path
session = SpheroPwn::Session.new channel

session.send_command SpheroPwn::Commands::L1Diagnostics.new
response = nil
async = nil
while response.nil? || async.nil?
  message = session.recv_message
  if message.nil?
    sleep 0.05
    next
  end

  if message.kind_of? SpheroPwn::Response
    response = message
    if response.code == :ok
      puts "Queued command to L1 diagnostics.\n"
    else
      puts "Failed to get L1 diagnostics. Code: #{response.code}\n"
      exit 1
    end
  else
    async = message
    puts "L1 diagnostics:\n"
    puts message.text
  end
end

session.send_command SpheroPwn::Commands::L2Diagnostics.new
response = nil
async = nil
while response.nil? || async.nil?
  message = session.recv_message
  if message.nil?
    sleep 0.05
    next
  end

  if message.kind_of? SpheroPwn::Response
    response = message
    if response.code == :ok
      puts "Queued command to L2 diagnostics.\n"
    else
      puts "Failed to get L2 diagnostics. Code: #{response.code}\n"
      exit 1
    end
  else
    async = message
    puts "L2 diagnostics:\n"
    pp message.counters
  end
end

session.close
exit 0
