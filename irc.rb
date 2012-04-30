#!/usr/bin/env ruby
# Copyright (C) 2012
#
# This file is part of Modulo
#
# This program is free software; you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA


require 'socket'

host = ''
port = 6667
chan = ''
nick = ''
cmdPrefix = ''


plugin = []

eval File.open('config.rb').read

conn = TCPSocket.open(host, port)
conn.puts("NICK #{nick}\r\n")
conn.puts("USER #{nick} #{nick} #{nick}: #{nick} Ruby IRC Bot <http://affix.me>")
conn.puts("JOIN #{chan}")

while line = conn.gets 
	data = line.split
	#puts "[<<] " + line
	ircSplit = line.split(":")
	cmd = ircSplit[2]
	cmd = cmd.to_s.split
	case data[0]
		when "PING"
			sendData = "PONG " + data[1] + "\r\n"
			conn.puts(sendData)
			puts "[>>] " + sendData
	end
	sendChan = data[2]
	begin
		if cmd[0].chop == "#{cmdPrefix}version"
                        sendData = "PRIVMSG #{sendChan} :I am modulo, A modular Ruby IRC bot by Affix Smith <http://affix.me> Version 0.1\r\n"
                        conn.puts sendData
                        puts "[>>] " + sendData
                        sendData = "PRIVMSG #{sendChan} :I am running on " + RUBY_PLATFORM + " With Ruby Version " + RUBY_VERSION
                        conn.puts sendData
                        puts "[>>] " + sendData
                end
                plugin.each do |plugin|
                	require "./plugins/#{plugin}/#{plugin}.rb"
                	if cmd[0].chomp == cmdPrefix + plugin
                		sendData = send(plugin, cmd, sendChan, conn)
                		conn.puts sendData
                		puts sendData
                	end
                end
	rescue NoMethodError
	end
end

