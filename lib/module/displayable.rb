module Displayable
  private

  def display_dealer_details
    dealer_total = @player_turns ? dealer.first_card_total : dealer.total
    dealer_cards = @player_turns ? "#{dealer.hand.first}, ?" : dealer.list_cards
    puts dealer.name.ljust(40) + "#{dealer_cards} (#{dealer_total})"
  end

  def display_player_details(player)
    print "#{player.name} (#{player.bankroll}, #{player.bet})".ljust(40)
    puts "#{player.list_cards} (#{player.total})"
  end

  def display_hit(participant)
    puts "#{participant.name} takes a card. It's the #{participant.hand.last}!"
    press_enter_and_clear
  end

  def display_turn_result(player)
    if player.busted?
      puts "#{player.name} busted!"
    else
      puts "#{player.name} stands on #{player.total}!"
    end
    press_enter_and_clear
  end

  def press_enter_and_clear
    puts "Press ENTER to continue..."
    gets.chomp
    display_game_state_and_clear
  end

  def display_goodbye_message
    puts ""
    if human_player.broke?
      puts "All out of money, you leave the table and sadly walk away."
    else
      puts "You calmly collect your remaining chips worth "\
           "$#{human_player.bankroll} and leave the table."
    end
    puts ""
    puts "Goodbye!"
  end
end