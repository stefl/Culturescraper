$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..","gem","lib"))) # for local development

require 'rubygems'
require 'sinatra'
require "sinatra/jsonp"
require "json"
require "imagescraper"
require 'cgi'
require 'open-uri'

set :public, File.dirname(__FILE__) + '/public'

configure do
  CACHE = Dalli::Client.new
end

get '/' do
  haml :home
end

get '/image' do
  #response.headers['Cache-Control'] = "public, max-age=#{60 * 60 * 24}"
  content_type :json
  url = params[:url]
  jsonp({:image=>ImageScraper.get_the_biggest_image(url), :url=>url})
end

get '/show' do
  response.headers['Cache-Control'] = "public, max-age=#{60 * 60 * 24}"
  url = params[:url]
  to_send = ImageScraper.get_the_biggest_image(url)
  bytes = open(to_send.to_s).read
  content_type "image/jpeg"
  bytes
end