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

page_map = []
first_good = 0
first_bad = 0

begin
  loop do
    print "Probing page #{first_good}... "
    session.send_command SpheroPwn::Commands::IsPageBlank.new(first_good)
    response = session.recv_until_response
    case response.code
    when :ok
      page_map[first_good] = response.is_blank? ? '.' : '*'
      puts(response.is_blank? ? 'blank' : 'used')
      break
    when :bad_page
      page_map[first_good] = 'X'
      puts 'bad'
      first_good += 1
      next
    else
      puts "Failed to get page status. Code: #{response.code}\n"
      exit 1
    end
  end

  first_bad = first_good + 1
  loop do
    print "Probing page #{first_bad}... "
    session.send_command SpheroPwn::Commands::IsPageBlank.new(first_bad)
    response = session.recv_until_response
    case response.code
    when :ok
      page_map[first_bad] = response.is_blank? ? '.' : '*'
      puts(response.is_blank? ? 'blank' : 'used')
      first_bad += 1
      next
    when :bad_page
      page_map[first_bad] = 'X'
      puts 'bad'
      break
    else
      puts "Failed to get page status. Code: #{response.code}\n"
      exit 1
    end
  end
ensure
  puts "First valid page: #{first_good}\n"
  puts "Last valid page: #{first_bad - 1}\n"
  puts "Page map:\n#{page_map.join('')}\n"

  session.send_command SpheroPwn::Commands::BootMainApp.new
  response = session.recv_until_response
  unless response.code == :ok
    puts "Failed to boot main application. Code: #{response.code}\n"
    exit 1
  end
end

session.close
exit 0
