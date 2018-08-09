class CompanyWithNull < ActiveRecord::Base
  has_many :campaigns,:class_name => 'CampaignWithNull',:foreign_key => 'company_id'
end
