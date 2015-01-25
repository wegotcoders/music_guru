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
  set :arch, 'Darwin'
end

get '/' do
  erb :index
end

post '/tracks' do
  #binding.pry
  if params[:tc] != '1'
    flash[:notice] = "If your music is not good the guru can't think clearly! Please tick the checkbox!"
  elsif params[:artist] == ''
    flash[:notice] = "I can't see anything! Please give me a name!"
  else
    songs = Echowrap.song_search(:artist => params[:artist])
    #not_songs = Echowrap.song_search(:artist => '')
    if songs
      flash[:notice] = "They sang #{songs.map {|s| s.title}.join("<br />")} <br /> Thanks for trying this app. Tell us your name please!"
    end
  end

    redirect '/'
end

#flash[:notice] = "I can't see anything! Please give me a name!"