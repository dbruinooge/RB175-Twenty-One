require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require_relative './lib/game'

# rubocop: disable Style/HashSyntax
configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
  also_reload "lib/game.rb"
end
# rubocop: enable Style/HashSyntax

get "/" do
  # if session[:game]
  #   redirect "/play"
  # else
  redirect "/newgame"
end

# Show rules and prompt for number of players
get "/newgame" do
  session[:game] = nil
  session[:display_board] = false
  erb :newgame, layout: :layout
end

# Select number of players
post "/players" do
  session[:game] = Game.new(params[:name], params[:players])
  redirect "/bet"
end

# Betting screen
get "/bet" do
  session[:display_board] = false
  @bankroll = session[:game].human_player.bankroll
  erb :bet
end

# Process bet
post "/bet" do
  session[:game].human_player.make_bet(params[:bet])
  session[:game].prepare_round
  redirect "/play"
end

# Hit or stand
post "/play" do
  if params[:choice] == "Hit"
    session[:game].hit_player
    redirect "/play"
  else
    redirect "/endround"
  end
end

# show round results
get "/endround" do
  session[:game].ai_turns
  session[:game].dealer_turn unless session[:game].everyone_busted?
  @dealer = session[:game].dealer
  @dealer_total = session[:game].dealer.total
  @player_total = session[:game].human_player.total
  session[:game].finish_round
  @results_strings = session[:game].results_strings
  erb :endround
end

# Main game screen
get "/play" do
  redirect "/endround" if session[:game].human_player.busted?
  session[:display_board] = true
  @dealer = session[:game].dealer
  @player_total = session[:game].human_player.total
  erb :play
end
