#!/usr/bin/env ruby

# Attack 0.1 - A threaded (D)DoS-Deflate alternative written in Ruby
# Copyright (C) 2008 James Rose
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

	# The number of concurent connections per IP.
	CONNECTION_LIMIT = 30
	
	# The frequency (in seconds) that Attack checks the current connections.
	FREQUENCY = 30
	
	# The firewall. Available options: csf, apf or any other firewall that takes a -d IP argument.
	FIREWALL = "csf" 
	
	# Connection checks and bans are logged here.
	LOG_FILE = "attack.log"
	
	# IP Whitelist.
	WHITELIST = %w{ 127.0.0.1 }
	 
	def initialize
		@connections = `netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n`
		@log = Logger.new(LOG_FILE)
		
		daemonize
		
		loop do
			run
			sleep(FREQUENCY)
		end			
	end
	
	def check(connections)
		connections.each { |connection|
			conn, ip = connection.split
			if conn.to_i > CONNECTION_LIMIT and not WHITELIST.include? ip
				`#{FIREWALL} -d #{ip}`
				@log.info "Blocked #{ip} with #{conn} connections."
			end
		}
	end
	
	def run
		Thread.new {
			check @connections
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
	
end

Attack.new