class CompanyWithoutNull < ActiveRecord::Base
  has_many :campaigns,:class_name => 'CampaignWithoutNull',:foreign_key => 'company_id'
end
