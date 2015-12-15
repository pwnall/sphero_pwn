#!/usr/bin/env ruby

require_relative '../lib/sphero_pwn.rb'

unless ARGV.length == 3
  puts <<END_USAGE
Usage: #{$PROGRAM_NAME} /dev/bluetooth-device block_name flash_file.bin

The block name can be soul|factory_config|user_config.
END_USAGE
  exit 1
end

rfconn_path = ARGV[0]
channel = SpheroPwn::Channel.new rfconn_path
session = SpheroPwn::Session.new channel

session.send_command SpheroPwn::Commands::GetFlashBlock.new ARGV[1].to_sym

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
      puts "Queued command to get #{ARGV[1]} block.\n"
    else
      puts "Failed to get #{ARGV[1]} block. Code: #{response.code}\n"
      exit 1
    end
  else
    async = message
    File.open ARGV[2], 'wb' do |f|
      f.write async.data_bytes.pack('C*')
    end
    puts "Wrote #{ARGV[1]} block to #{ARGV[2]}\n"
  end
end

session.close
exit 0
