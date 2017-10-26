require 'highline'

module RepoModule
  def self.get_trainable_params(repos, would_star = nil)
    result = []
    repos.each do |repo|
      description = if repo['description']
                      repo['description'].split(/\s+/).reject do |d|
                        d.length == 1
                      end
                    else
                      repo['description']
                    end

      result.push(
        description: description,
        language: repo['language'],
        would_star: would_star,
        html_url: repo['html_url']
      )
    end

    result
  end

  def self.create_training_set(starred_repos, random_repos)
    random_repos.each do |repo|
      user_response_on(repo)
    end

    training_repos = starred_repos + random_repos
    training_repos
  end

  def self.user_response_on(repo)
    cli = HighLine.new
    puts "----#{repo[:language]}----"
    puts "Description of the repo: #{repo[:description].join(' ')}"
    puts "Check the whole repo here: #{repo[:html_url]}"
    answer = cli.agree('Would star this repo?') { |q| q.default = 'no' }
    repo[:would_star] = answer
    puts "You have answered: #{answer}"
  end
end
