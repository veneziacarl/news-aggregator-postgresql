require 'net/http'
# require 'pry'
require_relative '../../server'

class Article
  attr_reader :title, :url, :description
  @all_articles = []

  def initialize(title, url, description)
    @title = title
    @url = url
    @description = description
  end

  def self.all
    all_articles = []
    db_connection do |conn|
      @article_info = conn.exec("SELECT title, url, description FROM articles").to_a
    end
    @article_info.each do |article|
      all_articles << Article.new(article['title'], article['url'], article['description'])
    end
    all_articles
    # binding.pry
  end

  def self.save(title, url, description)
    db_connection do |conn|
      conn.exec_params('INSERT INTO articles(title, url, description) VALUES ($1, $2, $3)', [title, url, description])
    end
  end

  def self.validate_url(url)
    url =~ /\w+[:\/\/].*[.]\w+/
  end
end

# binding.pry
