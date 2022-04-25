require_relative "./card"

class Deck
  attr_accessor :deck

  SUITS = %w(Hearts Diamonds Spades Clubs)
  VALUES = %w(2 3 4 5 6 7 8 9 10 J Q K A)

  def initialize
    new_deck
  end

  def new_deck
    self.deck = []
    SUITS.each do |suit|
      VALUES.each do |value|
        deck << Card.new(value, suit)
      end
    end
    deck.shuffle!
  end

  def deal(participant)
    participant.hit(deck.pop)
  end
end