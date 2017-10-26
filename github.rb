require 'net/http'
require 'pry'
require 'json'
require 'nbayes'
require 'stopwords'

require_relative 'helpermodule'
require_relative 'repomodule'
require 'highline'
# rubocop:disable all
STOP_WORDS = ['a', 'able', 'about', 'across', 'after', 'all', 'almost', 'also', 'am', 'among', 'an', 'and', 'any', 'are', 'as', 'at', 'be', 'because', 'been', 'but', 'by', 'can', 'cannot', 'could', 'dear', 'did', 'do', 'does', 'either', 'else', 'ever', 'every', 'for', 'from', 'get', 'got', 'had', 'has', 'have', 'he', 'her', 'hers', 'him', 'his', 'how', 'however', 'i', 'if', 'in', 'into', 'is', 'it', 'its', 'just', 'least', 'let', 'like', 'likely', 'may', 'me', 'might', 'most', 'must', 'my', 'neither', 'no', 'nor', 'not', 'of', 'off', 'often', 'on', 'only', 'or', 'other', 'our', 'own', 'rather', 'said', 'say', 'says', 'she', 'should', 'since', 'so', 'some', 'than', 'that', 'the', 'their', 'them', 'then', 'there', 'these', 'they', 'this', 'tis', 'to', 'too', 'twas', 'us', 'wants', 'was', 'we', 'were', 'what', 'when', 'where', 'which', 'while', 'who', 'whom', 'why', 'will', 'with', 'would', 'yet', 'you', 'your']

username, year, stars = HelperModule.questionnaire

my_starred_repos_response = HelperModule.get_repos("https://api.github.com/users/#{username}/starred")
my_starred_repos = RepoModule.get_trainable_params(my_starred_repos_response, true)

random_repos_response = HelperModule.get_repos("https://api.github.com/search/repositories?q=created:>#{year}-01-01 stars:>=#{stars}", false)
random_repos = RepoModule.get_trainable_params(random_repos_response['items'])

training_set = RepoModule.create_training_set(my_starred_repos, random_repos)

nbayes = NBayes::Base.new

training_set.each do |repo|
  stop_words_filter = Stopwords::Filter.new STOP_WORDS
  next if repo[:description].nil?
  text_array = stop_words_filter.filter(repo[:description])
  text_array.push(repo[:language]) unless repo[:language].nil?

  nbayes.train(text_array, repo[:would_star]) unless text_array.nil?
end

include RepoModule

suggestions = 'y'
next_page = true
current_url = "https://api.github.com/search/repositories?q=created:>#{year}-01-01 stars:>=#{stars}"

while suggestions == 'y' && next_page
  repos_response = HelperModule.get_repos(current_url, false)
  repos = RepoModule.get_trainable_params(repos_response['items'])

  repos.reject do |repo|
    true if repo[:description].nil?

    stop_words_filter = Stopwords::Filter.new STOP_WORDS
    token = stop_words_filter.filter(repo[:description])
    token.push(repo[:language]) unless repo[:language].nil?
    would_star = nbayes.classify(token) unless token.empty?
    would_star[false] >= 0.51 
  end
  puts repos
  # puts 'More suggestions?'
  suggestions = 'n'
  # suggestions = gets.strip
  # next_page = repos_response['Link'] =~ /next/
  # current_url = repos_response['Link'].split(';').first.tr('<>', '') if next_page
end

