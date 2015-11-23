require "sinatra"
require "pg"
require_relative "./app/models/article"
require 'pry'
require 'net/http'

set :views, File.join(File.dirname(__FILE__), "app/views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

previous_params = {}
# error = false
error_message = []
missing_fields_message = "Please completely fill out form"
invalid_url_message = "Invalid URL"
url_already_exists_message = "Article with same url already submitted"
description_too_short_message = "Description must be at least 20 characters long"



    # conn.exec('DROP TABLE articles')
    # conn.exec('CREATE TABLE articles (title varchar(100), url varchar(100), description varchar(225))')
    # conn.exec_params('INSERT INTO articles (title, url, description) VALUES ($1, $2, $3)', ['t','u','d'])

get "/articles" do
  @article_data = Article.all
  erb :index
end


get "/articles/new" do
  @previous_title = previous_params[:title]
  @previous_url = previous_params[:url]
  @previous_description = previous_params[:description]
  @error_message = []
  error_message = []
  previous_params = {}
  erb :articles_new
end

post "/articles/new" do
  error_message = []
  @error_message = []
  article_list = Article.all
  url_exists = article_list.any? { |article| article.url == params[:url] }
  empty_input = params[:title] == "" || params[:url] == "" || params[:description] == ""

  # binding.pry
  if empty_input
    error_message << missing_fields_message
  else
    error_message << invalid_url_message if !Article.validate_url(params[:url])
    error_message << description_too_short_message if params[:description].length < 20
    error_message << url_already_exists_message if url_exists
    # binding.pry
  end

  # if empty_input
  #   error_message << missing_fields_message
  # elsif !Article.validate_url(params[:url])
  #   error_message << invalid_url_message
  # elsif params[:description].length < 20
  #   error_message << description_too_short_message
  # else
  #   error_message << url_already_exists_message if article_exists
  # end

  if error_message.empty?
    Article.save(params[:title], params[:url], params[:description])
    # @error_message = error_message
    redirect "/articles"
  else
    @error_message = error_message
    erb :articles_new
  end
end
  #
  # if empty_input || params[:description].length < 20 || article_exists
  #   previous_params = params
  #   @error = true
  #   erb :new
  # else
  #   db_connection do |conn|
  #     conn.exec_params('INSERT INTO articles(title, url, description) VALUES ($1, $2, $3)', [params[:title], params[:url], params[:description]])
  #   end
  #   redirect "/articles"
  # end
