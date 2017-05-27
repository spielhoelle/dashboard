require 'uri'
require 'net/http'
require 'json'
require 'pry'

# url = URI("https://api.heroku.com/apps/sleepy-stream-53648/builds")

url = URI("https://api.heroku.com/apps/sleepy-stream-53648/builds")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["accept"] = 'Accept: application/vnd.heroku+json; version=3'
request["authorization"] = 'Basic dG9tbXlzLnNwaWVsaG9lbGxlQGdtYWlsLmNvbTpIbW5pdHM7LDMx'
request["cache-control"] = 'no-cache'
request["postman-token"] = '8a288f84-6382-0fd3-910f-8872e66d3ffe'

response = http.request(request)

# status = JSON.parse(response.body)

SCHEDULER.every '5s', :first_in => '5s' do |job|

  # send_event("welcome", {text: response.read_body})
end
