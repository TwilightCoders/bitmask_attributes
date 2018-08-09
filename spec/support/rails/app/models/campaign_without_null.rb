class CampaignWithoutNull < ActiveRecord::Base
  belongs_to :company,:class_name => 'CompanyWithoutNull'
  bitmask :medium, :as => [:web, :print, :email, :phone], :null => false
  bitmask :allow_zero, :as => [:one, :two, :three], :zero_value => :none, :null => false
  bitmask :misc, :as => %w(some useless values), :null => false do
    def worked?
      true
    end
  end
  bitmask :Legacy, :as => [:upper, :case], :null => false
end
