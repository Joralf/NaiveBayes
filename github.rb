require 'net/http'
require 'pry'
require 'json'
require 'nbayes'
require 'stopwords'

require_relative 'helpermodule'
require_relative 'repomodule'

# rubocop:disable LineLength
STOP_WORDS = ['a', 'able', 'about', 'across', 'after', 'all', 'almost', 'also', 'am', 'among', 'an', 'and', 'any', 'are', 'as', 'at', 'be', 'because', 'been', 'but', 'by', 'can', 'cannot', 'could', 'dear', 'did', 'do', 'does', 'either', 'else', 'ever', 'every', 'for', 'from', 'get', 'got', 'had', 'has', 'have', 'he', 'her', 'hers', 'him', 'his', 'how', 'however', 'i', 'if', 'in', 'into', 'is', 'it', 'its', 'just', 'least', 'let', 'like', 'likely', 'may', 'me', 'might', 'most', 'must', 'my', 'neither', 'no', 'nor', 'not', 'of', 'off', 'often', 'on', 'only', 'or', 'other', 'our', 'own', 'rather', 'said', 'say', 'says', 'she', 'should', 'since', 'so', 'some', 'than', 'that', 'the', 'their', 'them', 'then', 'there', 'these', 'they', 'this', 'tis', 'to', 'too', 'twas', 'us', 'wants', 'was', 'we', 'were', 'what', 'when', 'where', 'which', 'while', 'who', 'whom', 'why', 'will', 'with', 'would', 'yet', 'you', 'your']
print 'Enter a username: '
username = gets.strip

my_starred_repos_response = HelperModule.get_repos("https://api.github.com/users/#{username}/starred")
my_starred_repos = RepoModule.get_trainable_params(my_starred_repos_response, true)

random_repos_response = HelperModule.get_repos('https://api.github.com/search/repositories?q=created:>2017-01-01 stars:>=10000')
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

