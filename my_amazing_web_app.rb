require 'echonest-ruby-api'
require 'sinatra'
require 'rack-flash'
require 'json'
require 'pry'

enable :sessions
set :session_secret, 'super secret'
use Rack::Flash

get '/' do
  erb :index
end

post '/tracks' do
  song = Echonest::Song.new('YOUR-API-KEY')
  fingerprint = `ENMFP_codegen/codegen.Linux-x86_64 #{params[:track][:tempfile].path} 10 20`
  code = JSON.parse(fingerprint).first["code"]
  song_info = song.identify(code)

  if song_info.empty?
    flash[:notice] = "Er.. you've got me..."
  else
    best_guess = song_info.first
    artist = best_guess[:artist_name]
    title = best_guess[:title]

    flash[:notice] = "Was your song #{title} by #{artist}?"
  end

  redirect '/'
end