require_relative "./participant"
require_relative "./module/betable"
require_relative "./module/fileload"

class AIPlayer < Participant
  include Betable

  INITIAL_BANKROLL = 1000

  @@name_list = FileLoad.file_lines_to_array('./public/data/ai_names.txt')

  def initialize
    super
    @name = @@name_list.shuffle!.pop
    @bankroll = INITIAL_BANKROLL
  end

  def make_bet
    @bet = rand(@bankroll + 1).ceil(-2)
  end

  def hit?(dealer_first_card_total)
    if total <= 11
      true
    elsif total.between?(12, 16) && dealer_first_card_total.between?(7, 11)
      true
    elsif ace_and_six?
      true
    else
      false
    end
  end

  private

  def hand_values
    hand.map(&:value)
  end

  def ace_and_six?
    hand_values.include?('A') &&
      hand_values.include?('6') &&
      hand.size == 2
  end
end
