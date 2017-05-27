require 'octokit'
require 'action_view'
require 'uri'
require 'net/http'

include ActionView::Helpers::DateHelper

config = YAML::load_file('config.yml')

Octokit.configure do |c|
  c.auto_paginate = true
  c.login = config["login"]
  c.password = config["password"]
end

SCHEDULER.every '60m', :first_in => 0 do |job|
  config["repos"].each do |name|
    reponame = "#{config["login"]}/#{name}"

    r = Octokit::Client.new.repository(reponame)
    url = URI("#{r.url}/stats/participation")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    response = http.request(request)

    @result = JSON.parse(response.body)["all"]

    points = []
    @result.each_with_index do |value, i|
      points << { x: i, y: value }
    end

    send_event("commits_#{name}", points: points)
  end
end
