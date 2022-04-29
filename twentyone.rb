require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require_relative './lib/game'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
  also_reload "lib/game.rb"
end

helpers do
  def display_winner
    if session[:game].human_player.busted?
      "You busted!"
    elsif session[:game].human_player.total < session[:game].dealer.total
      "You lose!"
    elsif session[:game].human_player.total > session[:game].dealer.total
      "You win!"
    else
      "It's a tie!"
    end
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
  @display_winner = display_winner
  session[:game].finish_round
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
