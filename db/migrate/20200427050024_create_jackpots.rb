class CreateJackpots < ActiveRecord::Migration[5.1]
  def change
    create_table :jackpots do |t|
      t.string :color
      t.string :totalinold
      t.string :totalinnow
      t.string :cantidad
      t.string :trigger

      t.timestamps
    end
  end
end
