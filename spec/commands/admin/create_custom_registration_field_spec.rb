# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateCustomRegistrationField do
      subject { described_class.new(organization) }

      let(:organization) { create(:organization) }
      let(:context) do
        {
          current_user: create(:user, organization: organization),
          current_organization: organization
        }
      end
      let(:params) { {} }
      let(:form) do
        ConfigForm.from_params(params).with_context(context)
      end
      let(:another_config) { UpdateConfig.new(form) }

      describe "when valid" do
        it "broadcasts :ok and creates a Hash" do
          expect { subject.call }.to broadcast(:ok)

          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value).to be_a(Hash)
          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value.keys.count).to eq(1)
        end

        context "and entries already exist" do
          let!(:config) { create :awesome_config, organization: organization, var: :custom_registration_form, value: { test: '[{"type":"text","required":true,"label":"Age","name":"age"}]' } }

          shared_examples "has css boxes content" do
            it "do not removes previous entries" do
              expect { subject.call }.to broadcast(:ok)

              expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value.keys.count).to eq(2)
              expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form).value.values).to include('[{"type":"text","required":true,"label":"Age","name":"age"}]')
            end
          end

          it_behaves_like "has css boxes content"
        end
      end

      describe "when invalid" do
        subject { described_class.new("nonsense") }

        it "broadcasts :invalid and does not modify the config options" do
          expect { subject.call }.to broadcast(:invalid)

          expect(AwesomeConfig.find_by(organization: organization, var: :custom_registration_form)).to eq(nil)
        end
      end
    end
  end
end
