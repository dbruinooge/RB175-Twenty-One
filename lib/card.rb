class Card
  SUIT_SYMBOLS = { 'Hearts' => "\u2665", 'Diamonds' => "\u2666",
                   'Spades' => "\u2660", 'Clubs' => "\u2663" }

  attr_reader :value

  def initialize(value, suit)
    @value = value
    @suit = suit
  end

  def to_s
    "#{value}#{SUIT_SYMBOLS[suit]}"
  end

  private

  attr_reader :suit
end