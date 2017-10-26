require 'net/http'
require 'pry'
require 'json'
# require 'nbayes'
# ask for username and use in request
print 'Enter a username: '
username = gets.strip

url = URI.parse("https://api.github.com/users/#{username}/starred")
req = Net::HTTP::Get.new(url.to_s)
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = (url.scheme == 'https')
response = http.request(req)

starred = JSON.parse(response.body)

# if response[Link] rel=\next\ keep going to fetch data

response_has_next = response['Link'] =~ /next/

while response_has_next
  url = URI.parse(response['Link'].split(';').first.tr('<>', ''))
  req = Net::HTTP::Get.new(url.to_s)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == 'https')
  response = http.request(req)
  starred += JSON.parse(response.body)

  response_has_next = response['Link'] =~ /next/
end

repos = []
starred.each do |repo|
  description = if repo['description']
                  repo['description'].split(' ').reject do |d|
                    d.length == 1
                  end.join(' ')
                else
                  repo['description']
                end

  repos.push(
    description: description,
    language: repo['language']
  )
end
puts repos
# puts response
