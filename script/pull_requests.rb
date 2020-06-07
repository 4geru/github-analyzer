require './script/csv_builder'
require 'dotenv/load'

PULL_REQUEST_ROW_NAMES = %w[user user_id url html_url updated_at created_at title comments]

class PullRequest
  attr_accessor :user, :user_id, :url, :html_url, :updated_at, :created_at, :title, :comments

  def to_s
    values = PULL_REQUEST_ROW_NAMES.map { |key| " #{key}: #{self.send(key)}\n" }
    "#{self.class.name}:#{self.object_id}\n" + values.join
  end

  def initialize(attributes)
    @user = attributes["user"]
    @user_id = attributes["user_id"]
    @url = attributes["url"]
    @html_url = attributes["html_url"]
    @updated_at = attributes["updated_at"]
    @created_at = attributes["created_at"]
    @title = attributes["title"]
    @comments = []    
  end

  def self.new_by_api_response(pull_request)
    attributes = {}
    attributes["user"] = pull_request[:user][:login]
    attributes["user_id"] = pull_request[:user][:id]
    attributes["url"] = pull_request[:url]
    attributes["html_url"] = pull_request[:html_url]
    attributes["updated_at"] = pull_request[:updated_at]
    attributes["created_at"] = pull_request[:created_at]
    attributes["title"] = pull_request[:title]
    attributes["comments"] = []

    PullRequest.new(attributes)
  end

  def self.new_by_csv(items)
    PULL_REQUEST_ROW_NAMES
  end
end 

class PullRequestsLoader
  FILE_NAME = 'server/csv/pull_requests.csv'

  def load
    unless File.exist?(FILE_NAME)
      create_pull_request_csv(Date.today.prev_month)
    end

    load_pull_request_csv
  end
  
  def create_pull_request_csv(date)
    csv = CsvBuilder.new(FILE_NAME)
    csv.create_title(PULL_REQUEST_ROW_NAMES)
    pages = 1

    while true
      puts pages
      sleep 1
      response_pull_requests = client.pull_requests(ENV['TARGET_REPOSITORY'], :state => 'all', :page => pages)
      break if response_pull_requests.empty?
      break if !date.nil? && response_pull_requests.last[:created_at].to_date < date

      response_pull_requests.each do |response_pull_request|
        pr = PullRequest.new_by_api_response(response_pull_request)
        row = PULL_REQUEST_ROW_NAMES.map{ |name| pr.send name }
        csv.insert_item(row)
      end

      pages += 1
    end
  end

  def load_pull_request_csv
    file = CSV.read(FILE_NAME, headers: true)

    file.map do |line|
      PullRequest.new(line.to_hash)
    end
  end

  private 

  def client
    @client ||= Octokit::Client.new(access_token: ENV['GITHUB_API_KEY'])
  end
end
