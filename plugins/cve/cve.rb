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
#

require 'net/http'
 
def cve(cmd, sendChan, conn)
    site = "web.nvd.nist.gov"
    url = "/view/vuln/detail?vulnId="
    cve = cmd[1]
    params = {'User-Agent' => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"}
    port = 80
 
    http = Net::HTTP.new(site, port)
    request = Net::HTTP::Get.new(url + cve, params)
    response = http.request(request)
    next_overview = false
    next_impact_score = false
    next_exploitable_score = false
    overview = nil
    impact_score = nil
    exploitable_score = nil
    access_vector = nil
    response.body.each_line do |line|
        if next_exploitable_score
            exploitable_score = line.gsub(/<\/?[^>]*>/, "").strip
            next_exploitable_score = false
        end
        if next_impact_score
            impact_score = line.gsub(/<\/?[^>]*>/, "").strip
            next_impact_score = false
        end
        if next_overview
            overview = line.gsub(/<\/?[^>]*>/, "").strip
            next_overview = false
        end
        if line =~ /<h4>Overview<\/h4>/
            next_overview = true
        end
        if line =~ /Exploitability Subscore:/
            next_exploitable_score = true
        end
        if line =~ /Impact Subscore:/
            next_impact_score = true
        end
        if /Access Vector:<\/span>\s*(Network exploitable)/.match(line)
            access_vector = $1
        end
    end
    conn.puts "PRIVMSG #{sendChan} :[#{cmd[1]}] #{overview}"
    conn.puts "PRIVMSG #{sendChan} :[#{cmd[1]}] Impact Score : #{impact_score}"
    conn.puts "PRIVMSG #{sendChan} :[#{cmd[1]}] Exploitable Score : #{exploitable_score}"
    conn.puts "PRIVMSG #{sendChan} :[#{cmd[1]}] Access Vector : #{access_vector}"
end
