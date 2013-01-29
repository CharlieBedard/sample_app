class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end
    # Add the cross index so we can associate all microposts for the same user ID
    add_index :microposts, [:user_id, :created_at]
  end
end
