require 'echowrap'
require 'sinatra'
require 'rack-flash'
require 'json'
require 'yaml'

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


  if params[:tc] != '1' then
  	flash[:notice] = "Give me a good artist!"
  elsif params[:artist].length <= 1
  	flash[:notice] = "Give me aan artist to work with!"
  else

	  rating = Echowrap.artist_hotttnesss(:name => params[:artist])

	  if rating.name
	    flash[:notice] = "Hmm... I'd say #{rating.name} was about a #{(rating.hotttnesss*10).round(0)}. "
	    if params[:name].length > 1
	    	flash[:notice] += "What do you think, #{params[:name]}"
	    end
	  else
	  	flash[:notice] = "Really? Give me someone I've heard of."
	  end
	end

  redirect '/'
end