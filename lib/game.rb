require_relative "./human_player"
require_relative "./ai_player"
require_relative "./deck"
require_relative "./dealer"

class Game
  attr_reader :human_player, :dealer, :players, :deck, :results_strings

  def initialize(name, number_of_ai_players)
    @deck = Deck.new
    @dealer = Dealer.new
    @human_player = HumanPlayer.new(name)
    @players = [@human_player] +
               initialize_ai_players(number_of_ai_players.to_i)
    @results_strings = { player_wins_losses: [], broke_players: [] }
  end

  def hit_player
    hit(@human_player)
  end

  def prepare_round
    reset
    collect_ai_bets
    deal_cards
  end

  def ai_turns
    @players.each do |player|
      next if player == human_player
      play_cards(player)
    end
  end

  def dealer_turn
    @player_turns = false
    while dealer.hit?
      hit(dealer)
    end
  end

  def hit(participant)
    deck.deal(participant)
  end

  def finish_round
    process_results
    remove_broke_players
  end

  def everyone_busted?
    players.all?(&:busted?)
  end

  private

  def initialize_ai_players(number)
    players = []
    return players if number == 0
    number.times { players << AIPlayer.new }
    players
  end

  def play_cards(player)
    loop do
      break unless player.hit?(dealer.first_card_total)
      hit(player)
      break if player.busted?
    end
  end

  def collect_ai_bets
    1.upto players.size - 1 do |i|
      players[i].make_bet
    end
  end

  def deal_cards
    2.times { deck.deal(dealer) }
    players.each do |player|
      2.times { deck.deal(player) }
    end
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
      @results_strings[:player_wins_losses] << "#{player.name} busted."
    elsif dealer.busted?
      player.collect_winnings
      @results_strings[:player_wins_losses] << "#{player.name} wins "\
                                               "because the dealer busted."
    end
  end

  # rubocop: disable Metrics/MethodLength
  def process_point_results(player)
    case player.total <=> dealer.total
    when 1
      player.collect_winnings
      @results_strings[:player_wins_losses] << "#{player.name} "\
                                               "beats the dealer on points."
    when -1
      player.give_up_losses
      @results_strings[:player_wins_losses] << "#{player.name} "\
                                               "loses to the dealer on points."
    else
      @results_strings[:player_wins_losses] << "#{player.name} "\
                                               "ties the dealer."
    end
  end
  # rubocop: enable Metrics/MethodLength

  def remove_broke_players
    broke_players = identify_broke_players
    players.reject! { |player| broke_players.include?(player) }
  end

  def identify_broke_players
    players.each_with_object([]) do |player, broke_players|
      if (player.broke?) && player != @human_player
        broke_players << player
        @results_strings[:broke_players] << "#{player.name} is "\
                                            "broke and leaves the table."
      end
    end
  end

  def reset
    deck.new_deck
    dealer.discard_hand
    players.each(&:discard_hand)
    @results_strings = { player_wins_losses: [], broke_players: [] }
  end
end
