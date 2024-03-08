class CreateRondats < ActiveRecord::Migration[5.1]
  def change
    create_table :rondats do |t|
      t.string :jugador
      t.string :credito
      t.string :cartucho
      t.string :posiciondisparo
      t.string :resultado

      t.timestamps
    end
  end
end
