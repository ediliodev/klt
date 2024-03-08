class AddConfirmationToPostransaccionests < ActiveRecord::Migration[5.1]
  def change
    add_column :postransaccionests, :confirmation, :string
  end
end
