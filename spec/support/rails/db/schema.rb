ActiveRecord::Schema.define do
  create_table :campaign_with_nulls do |t|
    t.integer :company_id
    t.integer :medium, :allow_zero, :misc, :Legacy
    t.integer :different_per_class
    t.string :type # STI
  end
  create_table :company_with_nulls do |t|
    t.string :name
  end
  create_table :campaign_without_nulls do |t|
    t.integer :company_id
    t.integer :medium, :allow_zero, :misc, :Legacy, :null => false, :default => 0
    t.integer :different_per_class
    t.string :type # STI
  end
  create_table :company_without_nulls do |t|
    t.string :name
  end
  create_table :default_values do |t|
    t.integer :default_sym, :default_array
  end
end
