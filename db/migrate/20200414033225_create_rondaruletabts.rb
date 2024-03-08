class CreateRondaruletabts < ActiveRecord::Migration[5.1]
  def change
    create_table :rondaruletabts do |t|
      t.string :jugador
      t.string :win
      t.string :credit
      t.string :jugadas
      t.string :totalbet
      t.string :winnernumberspin
      t.string :status

      t.timestamps
    end
  end
end
