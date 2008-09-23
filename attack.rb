#!/usr/bin/env ruby

# Attack 0.2 - A threaded (D)DoS-Deflate alternative written in Ruby
# Copyright (C) 2008 JR
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'logger'

class Attack
	
	# Connection checks and bans are logged here.
	LOG_FILE = "attack.log"
	
	# You can overwrite any of the instance variables in the configuration file.
	CONFIG_FILE = "attack.conf"
	
	# IP Whitelist.
	WHITELIST = %w{ 127.0.0.1 }
	 
	def initialize
		# The number of concurent connections per IP.
		@connection_limit = 30
		
		# The frequency (in seconds) that Attack checks the current connections.
		@frequency = 30
		
		# The firewall. Available options: csf, apf or any other firewall that takes a -d IP argument.
		@firewall = "csf"

		load_from_config?
		
		@log = Logger.new(LOG_FILE)
		
#		daemonize	
	
		loop do
			run
			sleep(@frequency)
		end
		
	end
	
	def stop
		Thread.main.kill
		puts "Bye bye"
	end
	
	def check(connections)
		connections.each { |connection|
			conn, ip = connection.split
			if conn.to_i > @connection_limit and not WHITELIST.include? ip
				`#{@firewall} -d #{ip}`
				@log.info "Blocked #{ip} with #{conn} connections."
			end
		}
	end
	
	def run
		Thread.new {
			check `netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n`
			@log.info "Checked connections at #{Time.now}"
		}.join
	end
	
	protected
	
	def daemonize
	  exit if fork 
	  Process.setsid 
	  exit if fork 
	  Dir.chdir "/"
	  File.umask 0000
	  STDIN.reopen "/dev/null"   
	  STDOUT.reopen "/dev/null", "a" 
	  STDERR.reopen STDOUT
	  trap("TERM") { exit }
	end
	
	def load_from_config?
		config  = File.open(CONFIG_FILE)
		if config && File.size(CONFIG_FILE) != 0
			config.each { |line|
				option, value = line.split "=" 
 					eval %{
						@#{option.strip} = #{value.strip}
					}
			}
		else
			puts "Using default configuration. I can't read the configuration file. Does it exist?"
		end
		
	end
	
end

Attack.new