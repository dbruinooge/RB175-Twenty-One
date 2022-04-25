module Betable
  attr_reader :bankroll, :bet

  def give_up_losses
    @bankroll -= @bet
  end

  def collect_winnings
    @bankroll += @bet
  end

  def broke?
    @bankroll <= 0
  end
end