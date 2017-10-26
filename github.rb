require 'net/http'
require 'pry'
require 'json'
require_relative 'helpermodule'
require_relative 'repomodule'

# require 'nbayes'
# ask for username and use in request
# print 'Enter a username: '
# username = gets.strip

username = 'RobPando'

my_starred_repos_response = HelperModule.get_repos("https://api.github.com/users/#{username}/starred")
my_starred_repos = RepoModule.get_trainable_params(my_starred_repos_response, true)

random_repos_response = HelperModule.get_repos("https://api.github.com/search/repositories?q=created:>2017-01-01 stars:>=10000")
random_repos = RepoModule.get_trainable_params(random_repos_response['items'])

training_set = RepoModule.create_training_set(my_starred_repos, random_repos)

binding.pry
