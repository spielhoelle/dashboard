require 'typhoeus'


# Check whether a server is responding
# you can set a server to check via http request or ping
#
# server options:
# name: how it will show up on the dashboard
# url: either a website url or an IP address (do not include https:// when usnig ping method)
# method: either 'http' or 'ping'
# if the server you're checking redirects (from http to https for example) the check will
# return false


def bool_to_i(b)
  (b) ? 1 : 0
end

def send_request(method, uri, headers={}, body={}, params={}, verbose=false)
	cookie_jar = "tmp"
	response = Typhoeus::Request.new(
	  uri.to_s,
	  :headers => headers,
	  :body => body,
	  :params => params,
	  :method => method,
	  :ssl_verifypeer =>false,
	  :ssl_verifyhost => 0,
	  :followlocation => true,
	  :timeout => 60,
	  :verbose => verbose,
	  :cookiefile => cookie_jar,
	  :cookiejar => cookie_jar,
	  :maxredirs => 10
	).run
	return response
end

servers = [
	{name: 'amnesty-polizei.de', url: 'http://amnesty-polizei.de', method: 'http'},
	{name: 'thomaskuhnert.com', url: 'http://thomaskuhnert.com', method: 'http'},
	{name: 'nil-food.de', url: 'http://www.nil-food.de', method: 'http'},
	{name: 'bundestobi.de', url: 'http://bundestobi.de', method: 'http'}
]

SCHEDULER.every '1m', :first_in => 0 do |job|
  include Typhoeus

  statuses = Array.new

  # check status for each server
  servers.each do |server|

    case server[:method]
      when "http"
        response = send_request(:get, server[:url])
        result = (response.code == 200)

      when "ping"
        ping_count = 10
        ping_req = `ping -q -c #{ping_count} #{server[:url]}`
        result = !($?.exitstatus == 0)

      else
        puts "pebcak error..."

    end

    arrow = (result) ? "icon-ok-sign" : "icon-warning-sign"
    color = (result) ? "green" : "red"

    statuses.push({:label => server[:name], :value=> bool_to_i(result), :arrow=> arrow, :color=> color})
    # puts "statuses #{statuses}"
  end

  # print statuses to dashboard
  send_event('server_status', {items: statuses})
end
