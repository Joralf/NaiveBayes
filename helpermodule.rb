require 'net/http'

module HelperModule
  def self.get_repos(url_str, all = true)
    url = URI(url_str)
    req = Net::HTTP::Get.new(url.to_s)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    response = http.request(req)

    result = JSON.parse(response.body)
    return result unless all
    # if response[Link] rel=\next\ keep going to fetch data

    response_has_next = response['Link'] =~ /next/

    while response_has_next
      url = URI.parse(response['Link'].split(';').first.tr('<>', ''))
      req = Net::HTTP::Get.new(url.to_s)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      response = http.request(req)
      result += JSON.parse(response.body)

      response_has_next = response['Link'] =~ /next/
    end

    return result
  end

  def self.questionnaire
    cli = HighLine.new
    username = cli.ask("What's your GitHub handle?") { |q| q.default = "RobPando" }
    year = cli.ask("From what year would you like to include repos?") { |q| q.default = 2017 }
    stars = cli.ask("How many stars should a repo have?") { |q| q.default = 500 }

    return [username, year, stars]
  end
end
