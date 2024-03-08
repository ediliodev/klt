class CreateContadorests < ActiveRecord::Migration[5.1]
  def change
    create_table :contadorests do |t|
      t.string :totalin
      t.string :totalout
      t.string :totalnet

      t.timestamps
    end
  end
end
