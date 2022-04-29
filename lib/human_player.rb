require_relative "./participant"
require_relative "./module/betable"

class HumanPlayer < Participant
  include Betable

  INITIAL_BANKROLL = 1000

  def initialize(name)
    super()
    @name = name
    @bankroll = INITIAL_BANKROLL
  end

  def make_bet(chosen_bet)
    @bet = chosen_bet.to_i
  end
end
