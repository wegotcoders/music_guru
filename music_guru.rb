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
    flash[:notice] = "If the artist is not talented the guru can't think clearly!
     Please tick the checkbox!"
  elsif params[:artist] == ''
    flash[:notice] = "I can't see anything! Please give me a name!"
  elsif params[:user_name] == ''
    flash[:notice] = "Tell us your name please to see the results!"
  else
    artist = params[:artist]
    similar = Echowrap.artist_similar(:name => params[:artist])
    name = params[:user_name]
    if similar
      flash[:notice] = "Similar artists with #{artist.downcase.capitalize} are 
      <br/> #{similar.map {|s| s.name}.join("<br />")}
      <br/> Thanks for trying this app #{name.downcase.capitalize}!"
    end
  end
    redirect '/'
end