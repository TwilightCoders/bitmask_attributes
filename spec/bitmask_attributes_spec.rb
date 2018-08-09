require("spec_helper")
RSpec.describe(BitmaskAttributes) do
  def self.context_with_classes(label, campaign_class, company_class)
    context(label) do
      before do
        @campaign_class = campaign_class
        @company_class = company_class
      end
      after do
        @company_class.destroy_all
        @campaign_class.destroy_all
      end
      it("return all defined values of a given bitmask attribute") do
        expect([:web, :print, :email, :phone]).to eq(@campaign_class.values_for_medium)
      end
      it("can assign single value to bitmask") do
        assert_stored(@campaign_class.new(medium: :web), :web)
      end
      it("can assign multiple values to bitmask") do
        assert_stored(@campaign_class.new(medium: [:web, :print]), :web, :print)
      end
      it("can add single value to bitmask") do
        campaign = @campaign_class.new(medium: [:web, :print])
        assert_stored(campaign, :web, :print)
        (campaign.medium << :phone)
        assert_stored(campaign, :web, :print, :phone)
      end
      it("ignores duplicate values added to bitmask") do
        campaign = @campaign_class.new(medium: [:web, :print])
        assert_stored(campaign, :web, :print)
        (campaign.medium << :phone)
        assert_stored(campaign, :web, :print, :phone)
        (campaign.medium << :phone)
        assert_stored(campaign, :web, :print, :phone)
        (campaign.medium << "phone")
        assert_stored(campaign, :web, :print, :phone)
        expect(campaign.medium.select { |value| (value == :phone) }.size).to eq(1)
        expect(campaign.medium.select { |value| (value == "phone") }.size).to eq(0)
      end
      it("can assign new values at once to bitmask") do
        campaign = @campaign_class.new(medium: [:web, :print])
        assert_stored(campaign, :web, :print)
        campaign.medium = [:phone, :email]
        assert_stored(campaign, :phone, :email)
      end
      it("can assign raw bitmask values") do
        campaign = @campaign_class.new
        campaign.medium_bitmask = 3
        assert_stored(campaign, :web, :print)
        campaign.medium_bitmask = 0
        expect(campaign.medium).to be_empty
      end
      it("can save bitmask to db and retrieve values transparently") do
        campaign = @campaign_class.new(medium: [:web, :print])
        assert_stored(campaign, :web, :print)
        expect(campaign.save).to be_truthy
        assert_stored(@campaign_class.find(campaign.id), :web, :print)
      end
      it("can add custom behavor to value proxies during bitmask definition") do
        campaign = @campaign_class.new(medium: [:web, :print])
        expect { campaign.medium.worked? }.to raise_error(NoMethodError)
        expect { campaign.misc.worked? }.to_not(raise_error)
        expect(campaign.misc.worked?).to eq(true)
      end
      it("cannot use unsupported values") do
        expect_unsupported do
          @campaign_class.new(medium: [:web, :print, :this_will_fail])
        end
        campaign = @campaign_class.new(medium: :web)
        expect_unsupported { (campaign.medium << :this_will_fail_also) }
        expect_unsupported { campaign.medium = [:so_will_this] }
      end
      it("can only use Integer values for raw bitmask values") do
        campaign = @campaign_class.new(medium: :web)
        expect_unsupported { campaign.medium_bitmask = :this_will_fail }
      end
      it("cannot use unsupported values for raw bitmask values") do
        campaign = @campaign_class.new(medium: :web)
        number_of_attributes = @campaign_class.bitmasks[:medium].size
        expect_unsupported { campaign.medium_bitmask = (2 ** number_of_attributes) }
        expect_unsupported { campaign.medium_bitmask = -1 }
      end
      it("can determine bitmasks using convenience method") do
        expect(@campaign_class.bitmask_for_medium(:web, :print)).to be_truthy
        expect(@campaign_class.bitmask_for_medium(:web, :print)).to eq((@campaign_class.bitmasks[:medium][:web] | @campaign_class.bitmasks[:medium][:print]))
      end
      it("assert use of unknown value in convenience method will result in exception") do
        expect_unsupported do
          @campaign_class.bitmask_for_medium(:web, :and_this_isnt_valid)
        end
      end
      it("can determine bitmask entries using inverse convenience method") do
        expect(@campaign_class.medium_for_bitmask(3)).to be_truthy
        expect(@campaign_class.medium_for_bitmask(3)).to eq([:web, :print])
      end
      it("assert use of non Integer value in inverse convenience method will result in exception") do
        expect_unsupported { @campaign_class.medium_for_bitmask(:this_isnt_valid) }
      end
      it("hash of values is with indifferent access") do
        string_bit = nil
        expect do
          expect((string_bit = @campaign_class.bitmask_for_medium("web", "print"))).to be_truthy
        end.to_not(raise_error)
        expect(string_bit).to eq(@campaign_class.bitmask_for_medium(:web, :print))
      end
      it("save bitmask with non-standard attribute names") do
        campaign = @campaign_class.new(Legacy: [:upper, :case])
        expect(campaign.save).to be_truthy
        expect(@campaign_class.find(campaign.id).Legacy).to eq([:upper, :case])
      end
      it("ignore blanks fed as values") do
        expect(@campaign_class.bitmask_for_medium(:web, :print, "")).to eq(3)
        campaign = @campaign_class.new(medium: [:web, :print, ""])
        assert_stored(campaign, :web, :print)
      end
      it("update bitmask values currently in the database with reload") do
        instance1 = @campaign_class.create(medium: [:web, :print])
        instance2 = @campaign_class.find(instance1.id)
        expect((instance1.id == instance2.id)).to be_truthy
        expect((instance1.object_id != instance2.object_id)).to be_truthy
        expect(instance1.update_attributes(medium: [:email])).to be_truthy
        expect(instance2.medium).to eq([:web, :print])
        expect(instance2.reload.class).to eq(@campaign_class)
        expect(instance2.medium).to eq([:email])
      end
      context("checking") do
        before { @campaign = @campaign_class.new(medium: [:web, :print]) }
        context("for a single value") do
          it("be supported by an attribute_for_value convenience method") do
            expect(@campaign.medium_for_web?).to eq(true)
            expect(@campaign.medium_for_print?).to eq(true)
            expect(@campaign.medium_for_email?).to_not be_truthy
          end
          it("be supported by the simple predicate method") do
            expect(@campaign.medium?(:web)).to eq(true)
            expect(@campaign.medium?(:print)).to eq(true)
            expect(@campaign.medium?(:email)).to_not be_truthy
          end
        end
        context("for multiple values") do
          it("be supported by the simple predicate method") do
            expect(@campaign.medium?(:web, :print)).to eq(true)
            expect(@campaign.medium?(:web, :email)).to_not be_truthy
          end
        end
      end
      context("named scopes") do
        before do
          @company = @company_class.create(name: "Test Co, Intl.")
          @campaign1 = @company.campaigns.create(medium: [:web, :print])
          @campaign2 = @company.campaigns.create
          @campaign3 = @company.campaigns.create(medium: [:web, :email])
          @campaign4 = @company.campaigns.create(medium: [:web])
          @campaign5 = @company.campaigns.create(medium: [:web, :print, :email])
          @campaign6 = @company.campaigns.create(medium: [:web, :print, :email, :phone])
          @campaign7 = @company.campaigns.create(medium: [:email, :phone])
        end
        it("support retrieval by any value") do
          expect(@company.campaigns.with_medium).to eq([@campaign1, @campaign3, @campaign4, @campaign5, @campaign6, @campaign7])
        end
        it("support retrieval by one matching value") do
          expect(@company.campaigns.with_medium(:print)).to eq([@campaign1, @campaign5, @campaign6])
        end
        it("support retrieval by any matching value (OR)") do
          expect(@company.campaigns.with_any_medium(:print, :email)).to eq([@campaign1, @campaign3, @campaign5, @campaign6, @campaign7])
        end
        it("support retrieval by all matching values") do
          expect(@company.campaigns.with_medium(:web, :print)).to eq([@campaign1, @campaign5, @campaign6])
          expect(@company.campaigns.with_medium(:web, :email)).to eq([@campaign3, @campaign5, @campaign6])
        end
        it("support retrieval for no values") do
          expect(@company.campaigns.without_medium).to eq([@campaign2])
          expect(@company.campaigns.no_medium).to eq([@campaign2])
        end
        it("support retrieval without a specific value") do
          expect(@company.campaigns.without_medium(:print)).to eq([@campaign2, @campaign3, @campaign4, @campaign7])
          expect(@company.campaigns.without_medium(:web, :print)).to eq([@campaign2, @campaign7])
          expect(@company.campaigns.without_medium(:print, :phone)).to eq([@campaign2, @campaign3, @campaign4])
        end
        it("support retrieval by exact value") do
          expect(@company.campaigns.with_exact_medium(:web)).to eq([@campaign4])
          expect(@company.campaigns.with_exact_medium(:web, :print)).to eq([@campaign1])
          expect(@company.campaigns.with_exact_medium).to eq([@campaign2])
        end
        it("not retrieve retrieve a subsequent zero value for an unqualified with scope ") do
          expect(@company.campaigns.with_medium).to eq([@campaign1, @campaign3, @campaign4, @campaign5, @campaign6, @campaign7])
          @campaign4.medium = []
          @campaign4.save
          expect(@company.campaigns.with_medium).to eq([@campaign1, @campaign3, @campaign5, @campaign6, @campaign7])
          expect(@company.campaigns.with_any_medium).to eq([@campaign1, @campaign3, @campaign5, @campaign6, @campaign7])
        end
        it("not retrieve retrieve a subsequent zero value for a qualified with scope ") do
          expect(@company.campaigns.with_medium(:web)).to eq([@campaign1, @campaign3, @campaign4, @campaign5, @campaign6])
          @campaign4.medium = []
          @campaign4.save
          expect(@company.campaigns.with_medium(:web)).to eq([@campaign1, @campaign3, @campaign5, @campaign6])
          expect(@company.campaigns.with_any_medium(:web)).to eq([@campaign1, @campaign3, @campaign5, @campaign6])
        end
      end
      it("can check if at least one value is set") do
        campaign = @campaign_class.new(medium: [:web, :print])
        expect(campaign.medium?).to eq(true)
        campaign = @campaign_class.new
        expect(campaign.medium?).to_not be_truthy
      end
      it("find by bitmask values") do
        campaign = @campaign_class.new(medium: [:web, :print])
        expect(campaign.save).to be_truthy
        expect(@campaign_class.medium_for_print).to eq(@campaign_class.where("medium & ? <> 0", @campaign_class.bitmask_for_medium(:print)).to_a)
        expect(@campaign_class.medium_for_print.medium_for_web.first).to eq(@campaign_class.medium_for_print.first)
        expect(@campaign_class.medium_for_email).to eq([])
        expect(@campaign_class.medium_for_web.medium_for_email).to eq([])
      end
      it("find no values") do
        campaign = @campaign_class.create(medium: [:web, :print])
        expect(campaign.save).to be_truthy
        expect(@campaign_class.no_medium).to eq([])
        campaign.medium = []
        expect(campaign.save).to be_truthy
        expect(@campaign_class.no_medium).to eq([campaign])
      end
      it("allow zero in values without changing result") do
        expect(@campaign_class.bitmask_for_allow_zero(:none)).to eq(0)
        expect(@campaign_class.bitmask_for_allow_zero(:one, :two, :three, :none)).to eq(7)
        campaign = @campaign_class.new(allow_zero: :none)
        expect(campaign.save).to be_truthy
        expect(campaign.allow_zero).to eq([])
        campaign.allow_zero = :none
        expect(campaign.save).to be_truthy
        expect(campaign.allow_zero).to eq([])
        campaign.allow_zero = [:one, :none]
        expect(campaign.save).to be_truthy
        expect(campaign.allow_zero).to eq([:one])
      end
      private
      def expect_unsupported(&block)
        # assert_raises(ArgumentError, &block)
        expect(block).to raise_error(ArgumentError)
      end
      def assert_stored(record, *values)
        values.each do |value|
          expect(record.medium.any? { |v| (v.to_s == value.to_s) }).to be(true), "Values #{record.medium.inspect} does not include #{value.inspect}"
        end
        full_mask = values.inject(0) do |mask, value|
          (mask | @campaign_class.bitmasks[:medium][value])
        end
        expect(full_mask).to eq(record.medium.to_i)
      end
    end
  end
  it("accept a default value option") do
    expect([:y]).to eq(DefaultValue.new.default_sym)
    expect([:y, :z]).to eq(DefaultValue.new.default_array)
    expect([:x]).to eq(DefaultValue.new(default_sym: :x).default_sym)
    expect([:x]).to eq(DefaultValue.new(default_array: [:x]).default_array)
  end
  it("save empty bitmask when default defined") do
    default = DefaultValue.create
    expect(default.default_sym).to eq([:y])
    default.default_sym = []
    default.save
    expect(default.default_sym).to be_empty
    default2 = DefaultValue.find(default.id)
    expect(default2.default_sym).to be_empty
  end
  context_with_classes("Campaign with null attributes", CampaignWithNull, CompanyWithNull)
  context_with_classes("Campaign without null attributes", CampaignWithoutNull, CompanyWithoutNull)
  context_with_classes("SubCampaign with null attributes", SubCampaignWithNull, CompanyWithNull)
  context_with_classes("SubCampaign without null attributes", SubCampaignWithoutNull, CompanyWithoutNull)
  xit("allow subclasses to have different values for bitmask than parent") do
    a = CampaignWithNull.new
    b = SubCampaignWithNull.new
    a.different_per_class = [:set_for_parent]
    b.different_per_class = [:set_for_sub]
    a.save!
    b.save!
    a.reload
    b.reload
    expect([:set_for_parent]).to eq(a.different_per_class)
    expect([:set_for_sub]).to eq(b.different_per_class)
  end
end
