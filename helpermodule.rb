require 'net/http'

module HelperModule
  def self.get_repos(url_str)
    url = URI(url_str)
    req = Net::HTTP::Get.new(url.to_s)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    response = http.request(req)

    result = JSON.parse(response.body)

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
end
