class AddJugadorToPostransaccionest < ActiveRecord::Migration[5.1]
  def change
    add_column :postransaccionests, :jugador, :integer
  end
end
