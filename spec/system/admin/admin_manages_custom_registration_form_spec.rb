# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/box_label_editor"

describe "Admin manages custom registration form", type: :system do
  let(:organization) { create :organization }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:custom_fields) do
    {}
  end
  let!(:config) { create :awesome_config, organization: organization, var: :custom_registration_form, value: custom_fields }

  let(:data) { "[#{data1},#{data2},#{data3}]" }
  let(:data1) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
  let(:data2) { '{"type":"select","label":"Occupation","className":"form-control","name":"select-1476748006618","values":[{"label":"Street Sweeper","value":"option-1","selected":true},{"label":"Moth Man","value":"option-2"},{"label":"Chemist","value":"option-3"}]}' }
  let(:data3) { '{"type":"textarea","label":"Short Bio","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_decidim_awesome.config_path(:custom_registration_form)
  end

  context "when creating a new box" do
    it "saves the content" do
      click_link 'Add a new "custom fields" box'

      expect(page).to have_admin_callout("created successfully")

      sleep 2
      page.execute_script("$('.custom_registration_form_editor:first')[0].FormBuilder.actions.setData(#{data})")

      find("*[type=submit]").click

      sleep 2
      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
    end
  end

  context "when updating new box" do
    let(:data) { "[#{data1},#{data3}]" }
    let(:custom_fields) do
      {
        "foo" => "[#{data1},#{data2}]",
        "bar" => "[]"
      }
    end

    it "updates the content" do
      sleep 2
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).not_to have_content("Short Bio")

      page.execute_script("$('.custom_registration_form_container[data-key=\"foo\"] .custom_registration_form_editor')[0].FormBuilder.actions.setData(#{data})")
      find("*[type=submit]").click

      sleep 2
      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("Full Name")
      expect(page).not_to have_content("Occupation")
      expect(page).not_to have_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
    end

    it_behaves_like "edits box label inline", :fields, :foo

    context "when removing a box" do
      let(:custom_fields) do
        {
          "foo" => "[#{data1}]",
          "bar" => "[#{data2}]"
        }
      end

      it "updates the content" do
        sleep 2
        expect(page).to have_content("Full Name")
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Street Sweeper")
        expect(page).not_to have_content("Short Bio")

        within ".custom_registration_form_container[data-key=\"foo\"]" do
          accept_confirm { click_link 'Remove this "custom fields" box' }
        end

        sleep 2
        expect(page).to have_admin_callout("removed successfully")
        expect(page).not_to have_content("Full Name")
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Street Sweeper")
        expect(page).not_to have_content("Short Bio")

        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :custom_registration_form_foo)).not_to be_present
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :custom_registration_form_bar)).to be_present
      end
    end

    it "doesn't allow to add constraints" do
      expect(page).not_to have_selector("div.constraints-editor")
    end
  end
end
