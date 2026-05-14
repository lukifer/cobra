# frozen_string_literal: true

class MoveDeckPlayerRefsFromRoundsToPairings < ActiveRecord::Migration[7.2]
  def up
    remove_reference :rounds, :player1_deck1_player, foreign_key: { to_table: :players }
    remove_reference :rounds, :player1_deck2_player, foreign_key: { to_table: :players }
    remove_reference :rounds, :player2_deck1_player, foreign_key: { to_table: :players }
    remove_reference :rounds, :player2_deck2_player, foreign_key: { to_table: :players }

    add_reference :pairings, :player1_deck1_player, foreign_key: { to_table: :players }, null: true
    add_reference :pairings, :player1_deck2_player, foreign_key: { to_table: :players }, null: true
    add_reference :pairings, :player2_deck1_player, foreign_key: { to_table: :players }, null: true
    add_reference :pairings, :player2_deck2_player, foreign_key: { to_table: :players }, null: true
  end

  def down
    remove_reference :pairings, :player1_deck1_player, foreign_key: { to_table: :players }
    remove_reference :pairings, :player1_deck2_player, foreign_key: { to_table: :players }
    remove_reference :pairings, :player2_deck1_player, foreign_key: { to_table: :players }
    remove_reference :pairings, :player2_deck2_player, foreign_key: { to_table: :players }

    add_reference :rounds, :player1_deck1_player, foreign_key: { to_table: :players }, null: true
    add_reference :rounds, :player1_deck2_player, foreign_key: { to_table: :players }, null: true
    add_reference :rounds, :player2_deck1_player, foreign_key: { to_table: :players }, null: true
    add_reference :rounds, :player2_deck2_player, foreign_key: { to_table: :players }, null: true
  end
end
