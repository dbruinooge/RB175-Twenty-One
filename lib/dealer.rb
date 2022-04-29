require_relative "./participant"

class Dealer < Participant
  DEALER_STANDS = 17

  def initialize
    super
    @name = 'Dealer'
  end

  def first_card_total
    Participant::CARD_VALUES[hand.first.value]
  end

  def hit?
    total < DEALER_STANDS
  end
end
