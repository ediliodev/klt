class CreateSinglepostransaccionests < ActiveRecord::Migration[5.1]
  def change
    create_table :singlepostransaccionests do |t|
      t.string :creditin
      t.string :cashout

      t.timestamps
    end
  end
end
