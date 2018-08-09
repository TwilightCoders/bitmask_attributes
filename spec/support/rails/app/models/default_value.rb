class DefaultValue < ActiveRecord::Base
  bitmask :default_sym, :as => [:x, :y, :z], :default => :y
  bitmask :default_array, :as => [:x, :y, :z], :default => [:y, :z]
end
