require 'net/http'
require 'pry'
require 'json'
require 'nbayes'
# ask for username and use in request

url = URI.parse('https://api.github.com/users/robpando/starred')
req = Net::HTTP::Get.new(url.to_s)
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = (url.scheme == "https")
response = http.request(req)

starred = JSON.parse(response.body)

# if response[Link] rel=\next\ keep going to fetch data
if response['Link']
  url = URI.parse(response['Link'].split(';').first.tr('<>', ''))
  req = Net::HTTP::Get.new(url.to_s)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == "https")
  response = http.request(req)
  starred += JSON.parse(response.body)
end

repos = []
starred.each do |repo|
  repos.push({
    description: repo['description'],
    language: repo['language']
  })
end
puts repos
binding.pry
# puts response
