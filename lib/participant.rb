require_relative "./module/handable"

class Participant
  include Handable

  attr_reader :name

  def initialize
    @hand = []
  end
end