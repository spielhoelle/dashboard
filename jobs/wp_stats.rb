#!/usr/bin/env ruby
require 'net/http'
require 'openssl'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'pry'


# Created by Jonas Rosland, https://github.com/jonasrosland, https://twitter.com/jonasrosland
# Template used from https://github.com/foobugs/foobugs-dashboard/blob/master/jobs/github_user_repos.rb

# This job tracks stats for your Wordpress blog
#
# This job should use the `Numbers` and `List` widgets
# One for the total of the blog and one for a list of the most popular posts

# Config
# ------

config = YAML::load_file('config.yml')

# wp_host = config["WORDPRESS_HOST"]
# wp_site = config["WORDPRESS_SITE"]


# The following line is only needed if you're deploying to Cloud Foundry
# wp_bearer = JSON.parse(ENV['VCAP_SERVICES'], :symbolize_names => true)[:'user-provided'][0][:credentials][:wp_api]

# If you're deploying Dashing locally you can uncomment the following line
wp_bearer = config["WORDPRESS_KEY"]

# number of posts to display in the list
# max_length = 8

# order the list by the numbers
# ordered = true
# wp_period = 'year'
# number_of_periods = 5

SCHEDULER.every '1m', :first_in => 0 do |job|
  config["WORDPRESS_SITES"].each do |name|
    posts = Nokogiri::XML(open("https://stats.wordpress.com/csv.php?api_key=#{wp_bearer}&blog_uri=www.#{name}&days=1&summarize&format=xml&table=postviews"))
    views = Nokogiri::XML(open("https://stats.wordpress.com/csv.php?api_key=#{wp_bearer}&blog_uri=www.#{name}&days=1&summarize&format=xml"))
    views_week = Nokogiri::XML(open("https://stats.wordpress.com/csv.php?api_key=#{wp_bearer}&blog_uri=www.#{name}&days=7&summarize&format=xml"))
    # puts xml
    items = []

    posts.xpath("//post").each do |post|
      items.push({ label: post.attributes["title"].value, value: post.children.to_s })
    end


    send_event("wp_stats_#{name}", { items: items, today: views.xpath("//total").children[0].to_s, week: views_week.xpath("//total").children[0].to_s })
    # send_event("wp_total_views_#{name}", { current: views_week.xpath("//total").children[0].to_s })
    # send_event("wp_total_views_today_#{name}", { current: views.xpath("//total").children[0].to_s })
  end
end # SCHEDULER
