# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe ConfigForm do
      subject { described_class.from_params(attributes) }

      let(:attributes) do
        {
          allow_images_in_full_editor: true,
          allow_images_in_small_editor: true
        }
      end

      let(:custom_styles) do
        {
          foo: valid_css
        }
      end
      let(:valid_css) { ".valid_css {background: red;}" }
      let(:invalid_css) { "invalid_css {background: ;}" }
      let(:custom_fields) do
        {
          foo: valid_fields
        }
      end
      let(:valid_fields) { '[{"foo":"bar"}]' }
      let(:invalid_fields) { '[{"foo":"bar"}]{"baz":"zet"}' }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when custom styles" do
        let(:attributes) do
          {
            scoped_styles: custom_styles
          }
        end

        it { is_expected.to be_valid }

        context "and invalid CSS" do
          let(:custom_styles) do
            {
              foo: invalid_css
            }
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when proposal custom fields" do
        let(:attributes) do
          {
            proposal_custom_fields: custom_fields
          }
        end

        it { is_expected.to be_valid }

        context "and invalid JSON" do
          let(:custom_fields) do
            {
              foo: invalid_fields
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "and sending labels with html" do
          let(:valid_fields) { '[{"label":"<p>Santana</p>"}]' }

          it "sanitize labels from html" do
            expect(subject.proposal_custom_fields[:foo]).to include("Santana")
            expect(subject.proposal_custom_fields[:foo]).not_to include("<p>Santana</p>")
          end
        end
      end

      context "when custom registration form" do
        let(:attributes) do
          {
            custom_registration_form: custom_fields
          }
        end

        it { is_expected.to be_valid }

        context "and invalid JSON" do
          let(:custom_fields) do
            {
              foo: invalid_fields
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "and sending labels with html" do
          let(:valid_fields) { '[{"label":"<p>Santana</p>"}]' }

          it "sanitize labels from html" do
            expect(subject.custom_registration_form[:foo]).to include("Santana")
            expect(subject.custom_registration_form[:foo]).not_to include("<p>Santana</p>")
          end
        end
      end
    end
  end
end
