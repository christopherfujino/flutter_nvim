#!/usr/bin/env ruby

STDERR.print "[stub.rb] Awaiting data from STDIN...\n"

while true
  input = STDIN.readpartial(1024)
  # TODO check if input.length == 1024
  STDERR.print "[stub.rb] Received #{input.length} bytes\n\n"
  input.bytes.each_with_index do |byte, i|
    if i % 10 == 0
      STDERR.print "\n"
    end
    STDERR.print "#{byte.to_s(16).rjust(2, '0')} "
  end
  STDERR.print "\n\n"
  STDOUT.write "flooboo\n"
  STDOUT.flush
  STDERR.print "Sent message back...\n"
end

