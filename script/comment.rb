require './script/csv_builder'
require 'dotenv/load'

COMMENT_ROW_NAMES = %w[user pull_request_url html_url updated_at created_at user_id body path]

class Comment
  attr_accessor :user, :pull_request_url, :html_url, :updated_at, :created_at, :user_id, :body, :path

  def initialize(attributes)
    @user = attributes["user"]
    @user_id = attributes["user_id"]
    @updated_at = attributes["updated_at"]
    @created_at = attributes["created_at"]
    @pull_request_url = attributes["pull_request_url"]
    @html_url = attributes["html_url"]
    @body = attributes["body"]
    @path = attributes["path"]
  end

  def self.new_by_api_response(comment)
    attributes = {}

    attributes['user'] = comment[:user][:login]
    attributes['user_id'] = comment[:user][:id]
    attributes['updated_at'] = comment[:updated_at]
    attributes['created_at'] = comment[:created_at]
    attributes['pull_request_url'] = comment[:pull_request_url]
    attributes['html_url'] = comment[:html_url]
    attributes['body'] = comment[:body]
    attributes['path'] = comment[:path]

    Comment.new(attributes)
  end
end

class CommentsLoader
    FILE_NAME = 'server/csv/comments.csv'
  
    def load
      unless File.exist?(FILE_NAME)
        create_pull_request_csv(Date.today.prev_month)
      end
  
      load_pull_request_csv
    end
    
    def create_pull_request_csv(date)
      csv = CsvBuilder.new(FILE_NAME)
      csv.create_title(COMMENT_ROW_NAMES)
      pages = 1
      while true
          puts pages
          sleep 1
          params = {
            page: pages,
            since: (date if date)
          }
          response_pull_request_comments = client.pull_requests_comments(ENV['TARGET_REPOSITORY'], *params)
          break if response_pull_request_comments.empty?
          break if !date.nil? && response_pull_request_comments.last[:created_at].to_date < date

          response_pull_request_comments.each do |comment|
          comment = Comment.new_by_api_response(comment)
          row = COMMENT_ROW_NAMES.map{ |name| comment.send name }
          csv.insert_item(row)
          end

          pages += 1
      end
    end
  
    def load_pull_request_csv
      file = CSV.read(FILE_NAME, headers: true)
  
      file.map do |line|
        Comment.new(line.to_hash)
      end
    end
  
    private 
  
    def client
      @client ||= Octokit::Client.new(access_token: ENV['GITHUB_API_KEY'])
    end
  end
  