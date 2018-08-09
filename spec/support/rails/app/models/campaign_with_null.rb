class CampaignWithNull < ActiveRecord::Base
  belongs_to :company,:class_name => 'CompanyWithNull'
  bitmask :medium, :as => [:web, :print, :email, :phone]
  bitmask :allow_zero, :as => [:one, :two, :three], :zero_value => :none
  bitmask :different_per_class, :as => [:set_for_parent]
  bitmask :misc, :as => %w(some useless values) do
    def worked?
      true
    end
  end
  bitmask :Legacy, :as => [:upper, :case]
end
