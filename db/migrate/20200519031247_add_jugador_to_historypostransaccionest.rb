class AddJugadorToHistorypostransaccionest < ActiveRecord::Migration[5.1]
  def change
    add_column :historypostransaccionests, :jugador, :string
  end
end
