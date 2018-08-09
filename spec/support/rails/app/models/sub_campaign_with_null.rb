class SubCampaignWithNull < CampaignWithNull
  bitmask :different_per_class, :as => [:set_for_sub]
end
