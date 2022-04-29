require_relative "./human_player"
require_relative "./ai_player"
require_relative "./module/displayable"
require_relative "./deck"
require_relative "./dealer"

class Game
  include Displayable

  attr_reader :human_player, :dealer, :players

  def initialize(name, number_of_ai_players)
    @deck = Deck.new
    @dealer = Dealer.new
    @human_player = HumanPlayer.new(name)
    @players = [@human_player] + initialize_ai_players(number_of_ai_players.to_i)
  end

  # def start
  #   prepare_round
  #   dealer_turn unless everyone_busted?
  #   finish_round
  #   # break if human_player.broke? || !play_again?
  #   # reset
  # end

  attr_reader :deck

  def initialize_ai_players(number)
    players = []
    return players if number == 0
    number.times { players << AIPlayer.new }
    players
  end

  def hit_player
    hit(@human_player)
  end

  def prepare_round
    reset
    collect_ai_bets
    deal_cards
  end

  def collect_ai_bets
    1.upto (players.size - 1) do |i|
      players[i].make_bet
    end
  end

  def deal_cards
    2.times { deck.deal(dealer) }
    players.each do |player|
      2.times { deck.deal(player) }
    end
  end

  def ai_turns
    @players.each do |player|
      next if player == human_player
      play_cards(player)
    end
  end

  def start_turn(player)
    name = player == human_player ? 'you' : player.name
    puts "The dealer turns to #{name}."
    press_enter_and_clear
  end

  def play_cards(player)
    loop do
      break unless player.hit?(dealer.first_card_total)
      hit(player)
      break if player.busted?
    end
  end

  def dealer_turn
    @player_turns = false
    while dealer.hit?
      hit(dealer)
    end
  end

  def reveal_hidden_card
    display_game_state_and_clear
    puts "Dealer reveals the hidden card. It's the #{dealer.hand.last}!"
    press_enter_and_clear
  end

  def hit(participant)
    deck.deal(participant)
  end

  def finish_round
    process_results
    remove_broke_players
  end

  def process_results
    players.each do |player|
      if player.busted? || dealer.busted?
        process_busted_results(player)
      elsif player.total != dealer.total
        process_point_results(player)
      end
    end
  end

  def process_busted_results(player)
    if player.busted?
      player.give_up_losses
    elsif dealer.busted?
      player.collect_winnings
    end
  end

  def process_point_results(player)
    case player.total <=> dealer.total
    when 1
      player.collect_winnings
    when -1
      player.give_up_losses
    end
  end

  def everyone_busted?
    players.all?(&:busted?)
  end

  # def play_again?
  #   choice = nil
  #   loop do
  #     puts ""
  #     puts "Would you like to play again? (y/n)"
  #     choice = gets.chomp.downcase
  #     break if %w(y yes n no).include?(choice)
  #     puts "Sorry, invalid choice."
  #   end
  #   choice == 'y'
  # end

  def remove_broke_players
    broke_players = identify_broke_players
    broke_players.each do |broke_player|
      puts ""
      puts "All out of money, #{broke_player.name} leaves the table "\
           "and sadly walks away."
    end
    players.reject! { |player| broke_players.include?(player) }
  end

  def identify_broke_players
    players.each_with_object([]) do |player, broke_players|
      if (player.broke?) && player != @human_player
        broke_players << player
      end
    end
  end

  def reset
    deck.new_deck
    dealer.discard_hand
    players.each(&:discard_hand)
  end
end