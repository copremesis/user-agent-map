class CreateIpcaches < ActiveRecord::Migration
  def change
    create_table :ipcaches do |t|
      t.string :ip
      t.float :lat
      t.float :lon

      t.timestamps
    end
  end
end
