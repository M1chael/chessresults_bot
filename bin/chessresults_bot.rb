#!/usr/bin/env ruby
begin
  require_relative '../lib/bootstrap.rb'

  case ARGV[0]
  when '--listen'
    @bot.listen
  when '--post'
    @bot.post
  else
    @logger.fatal("Wrong argument: \"#{ARGV[0].to_s}\"")
  end
rescue => error
  @logger.fatal(error)
end
