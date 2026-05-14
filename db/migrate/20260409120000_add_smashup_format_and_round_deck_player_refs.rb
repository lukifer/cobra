# frozen_string_literal: true

class AddSmashupFormatAndRoundDeckPlayerRefs < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      INSERT INTO formats (name, position, created_at, updated_at)
      VALUES ('Smashup', 98, NOW(), NOW())
      ON CONFLICT (name) DO NOTHING;
    SQL

    add_reference :rounds, :player1_deck1_player, foreign_key: { to_table: :players }, null: true
    add_reference :rounds, :player1_deck2_player, foreign_key: { to_table: :players }, null: true
    add_reference :rounds, :player2_deck1_player, foreign_key: { to_table: :players }, null: true
    add_reference :rounds, :player2_deck2_player, foreign_key: { to_table: :players }, null: true
  end

  def down
    remove_reference :rounds, :player1_deck1_player, foreign_key: { to_table: :players }
    remove_reference :rounds, :player1_deck2_player, foreign_key: { to_table: :players }
    remove_reference :rounds, :player2_deck1_player, foreign_key: { to_table: :players }
    remove_reference :rounds, :player2_deck2_player, foreign_key: { to_table: :players }

    execute <<~SQL
      DELETE FROM formats
      WHERE name = 'Smashup' AND position = 98;
    SQL
  end
end
