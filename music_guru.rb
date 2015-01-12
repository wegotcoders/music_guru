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

    unless params[:artist] == ""

    similar = Echowrap.artist_similar(:name => params[:artist], :results =>3)



  if similar
    output = ["Errr #{params[:name]}... I can't quite remember #{params[:artist]}? <br> <ul>"]
    similar.map {|x|
      song = Echowrap.artist_songs(:name => x.name, :results => 1)
      song.map {|y| output <<  "<li> #{y.title} ??... oh no wait that was #{x.name} </li>" }
      
    } 
    output << "Bah, I give up... I can't remember... Sorry!</ul>"  


  flash[:notice] = output.join
  end

else
flash[:notice] = "please enter an artist...or did you? I can't remember"
end
  redirect '/'
end