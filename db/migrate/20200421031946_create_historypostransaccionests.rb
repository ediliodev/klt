class CreateHistorypostransaccionests < ActiveRecord::Migration[5.1]
  def change
    create_table :historypostransaccionests do |t|
      t.string :creditin
      t.string :cashout

      t.timestamps
    end
  end
end
