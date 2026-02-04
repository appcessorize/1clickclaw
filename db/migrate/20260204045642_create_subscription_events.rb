class CreateSubscriptionEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :stripe_event_id, null: false
      t.jsonb :payload, null: false, default: {}
      t.datetime :processed_at

      t.timestamps
    end

    add_index :subscription_events, :stripe_event_id, unique: true
    add_index :subscription_events, :event_type
    add_index :subscription_events, :processed_at
  end
end
