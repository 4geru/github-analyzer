require 'octokit'
require 'date'
require 'pry'
require './script/pull_requests'
require './script/comment'
require 'csv'

# ==== pull requests 

pull_requests = PullRequestsLoader.new.load
mm = pull_requests.map(&:created_at).minmax
puts "pull_requests oldest: #{mm.first} latest: #{mm.last}"
# pull_requests.each do |pr|
#   puts pr
# end

# ==== commente
comments = CommentsLoader.new.load

mm = comments.map(&:created_at).minmax
puts "coments oldest: #{mm.first} latest: #{mm.last}"