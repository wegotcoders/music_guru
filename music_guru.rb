require 'echowrap'
require 'sinatra'
require 'rack-flash'
require 'json'
require 'yaml'
require 'pry'

enable :sessions
set :session_secret, 'super secret'
use Rack::Flash

configure do
  api_info = YAML.load_file('api.key')

  Echowrap.configure do |config|
    config.api_key = ENV['API_KEY'] || api_info[:api_key]
    config.consumer_key = ENV['CONSUMER_KEY'] || api_info[:consumer_key]
    config.shared_secret = ENV['SHARED_SECRET'] || api_info[:shared_secret]
  end

  set :arch, 'Linux-x86_64'
end

configure :development do
  # Uncomment the line below if you are using Mac OSX
  # set :arch, 'Darwin'
end

get '/' do
  erb :index
end

post '/tracks' do
  if params[:artist] == "" then
    flash[:notice] = "You need to type in the artist(s): I'm not psychic."
  elsif params[:tc] != '1' then
    flash[:notice] = "You need to verify that the musical act is from Earth."
  elsif params[:user_name] == "" then
    flash[:notice] = "Please enter your name."
  else
    result = Echowrap.artist_search(:name => params[:artist],
      :results => 1,
      :bucket => ['artist_location'])
    flash[:notice] = "Hi, #{params[:user_name]}. #{params[:artist]} heils from
    #{result[0].location.city}, #{result[0].location.country}."
  end

  redirect '/'
end