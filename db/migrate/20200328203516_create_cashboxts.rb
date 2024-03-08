class CreateCashboxts < ActiveRecord::Migration[5.1]
  def change
    create_table :cashboxts do |t|
      t.string :cantidad

      t.timestamps
    end
  end
end
