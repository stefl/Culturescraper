$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..","gem","lib"))) # for local development

require 'rubygems'
require 'sinatra'
require "sinatra/jsonp"
require "json"
require "imagescraper"
require 'cgi'

set :public, File.dirname(__FILE__) + '/public'

get '/' do
  haml :home
end

get '/image' do
  response.headers['Cache-Control'] = "public, max-age=#{60 * 60 * 24}"
  content_type :json
  url = params[:url]
  jsonp({:image=>ImageScraper.get_the_biggest_image(url), :url=>url})
end