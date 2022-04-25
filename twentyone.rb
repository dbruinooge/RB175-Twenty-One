require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require_relative './lib/game'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

helpers do
  def cards(player)
  end
end

before do

end

get "/" do
  # if session[:game]
  #   redirect "/play"
  # else
  redirect "/newgame"
end

# Show rules and prompt for number of players
get "/newgame" do
  session[:game] = nil
  erb :newgame, layout: :layout
end

# Select number of players
post "/players" do
  session[:game] = Game.new(params[:name], params[:players])
  session[:game].start
  redirect "/play"
end

# Main game screen
get "/play" do
 erb :play
end
