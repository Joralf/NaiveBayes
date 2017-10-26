require 'net/http'
require 'pry'
require 'json'
require 'nbayes'
require 'stopwords'

STOP_WORDS = ['a', 'able', 'about', 'across', 'after', 'all', 'almost', 'also', 'am', 'among', 'an', 'and', 'any', 'are', 'as', 'at', 'be', 'because', 'been', 'but', 'by', 'can', 'cannot', 'could', 'dear', 'did', 'do', 'does', 'either', 'else', 'ever', 'every', 'for', 'from', 'get', 'got', 'had', 'has', 'have', 'he', 'her', 'hers', 'him', 'his', 'how', 'however', 'i', 'if', 'in', 'into', 'is', 'it', 'its', 'just', 'least', 'let', 'like', 'likely', 'may', 'me', 'might', 'most', 'must', 'my', 'neither', 'no', 'nor', 'not', 'of', 'off', 'often', 'on', 'only', 'or', 'other', 'our', 'own', 'rather', 'said', 'say', 'says', 'she', 'should', 'since', 'so', 'some', 'than', 'that', 'the', 'their', 'them', 'then', 'there', 'these', 'they', 'this', 'tis', 'to', 'too', 'twas', 'us', 'wants', 'was', 'we', 'were', 'what', 'when', 'where', 'which', 'while', 'who', 'whom', 'why', 'will', 'with', 'would', 'yet', 'you', 'your']
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
  description = if !repo['description'].nil?
                  repo['description'].split(' ').reject do |d|
                    d.length == 1
                  end
                else
                  repo['description']
                end
  repos.push(
    description: description,
    language: repo['language'],
  )
end

nbayes = NBayes::Base.new

repos.each do |repo|
  stop_words_filter = Stopwords::Filter.new STOP_WORDS
  text_array = stop_words_filter.filter(repo[:description]) unless repo[:description].nil?
  text_array.push(repo[:language]) unless text_array.nil? && repo[:language].nil?

  nbayes.train(text_array, 'y') unless text_array.nil?
end

binding.pry

puts repos


