# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyCustomRegistrationField do
      subject { described_class.new(key, organization) }

      let(:organization) { create(:organization) }
      let(:custom_fields) do
        {
          foo: '[{"type":"text","required":true,"label":"Age","name":"age"}]',
          bar: '[{"type":"textarea","required":true,"label":"Bio","name":"bio"}]'
        }
      end
      let(:key) { "foo" }
      let!(:config) { create :awesome_config, organization: organization, var: :custom_registration_form, value: custom_fields }

      describe "when valid" do
        it "broadcasts :ok and removes the item" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value.keys.count).to eq(1)
          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value.keys).to include("bar")
          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value.keys).not_to include("foo")
          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value.values).to include('[{"type":"textarea","required":true,"label":"Bio","name":"bio"}]')
          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value.values).not_to include('[{"type":"text","required":true,"label":"Age","name":"age"}]')
        end
      end

      describe "when invalid" do
        let(:key) { "nonsense" }

        it "broadcasts :invalid and does not modifiy the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value.keys.count).to eq(2)
        end
      end
    end
  end
end
