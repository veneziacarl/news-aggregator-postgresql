require "spec_helper"
require 'launchy'

feature "user adds article" do
  let(:title) { "Valid Title" }
  let(:url) { "https://google.com" }
  let(:description) { "Valid description text" }

  scenario "user successfully adds an article" do
    visit "/articles/new"
    fill_in "Title", with: title
    fill_in "URL", with: url
    fill_in "Description", with: description
    click_button "Submit"

    expect(page).to have_current_path("/articles")
    expect(page).to have_content(title)
    expect(page).to have_css("a[href='#{url}']")
    expect(page).to have_content(description)
  end

  context "invalid form submission" do
    # before { skip }
    let(:missing_fields_message) { "Please completely fill out form" }
    let(:invalid_url_message) { "Invalid URL" }
    let(:url_already_exists_message) { "Article with same url already submitted" }
    let(:description_too_short_message) { "Description must be at least 20 characters long" }

    scenario "form not filled out completely" do
      visit "/articles/new"
      fill_in "Title", with: title
      click_button "Submit"

      expect(page).to have_content(missing_fields_message)
      expect(page).to_not have_content(invalid_url_message)
      expect(page).to_not have_content(url_already_exists_message)
      expect(page).to_not have_content(description_too_short_message)
    end

    scenario "invalid URL submitted" do
      visit "/articles/new"
      fill_in "Title", with: title
      fill_in "URL", with: "invalid url"
      fill_in "Description", with: description
      click_button "Submit"

      expect(page).to have_content(invalid_url_message)
      expect(page).to_not have_content(missing_fields_message)
      expect(page).to_not have_content(url_already_exists_message)
      expect(page).to_not have_content(description_too_short_message)
    end

    scenario "already existing URL submitted" do
      db_connection do |conn|
        sql_query = %(
        INSERT INTO articles (title, url, description)
        VALUES ($1, $2, $3)
        )
        data = [title, url, description]
        conn.exec_params(sql_query, data)
      end

      visit "/articles/new"
      fill_in "Title", with: title
      fill_in "URL", with: url
      fill_in "Description", with: description
      click_button "Submit"

      expect(page).to have_content(url_already_exists_message)
      expect(page).to_not have_content(missing_fields_message)
      expect(page).to_not have_content(invalid_url_message)
      expect(page).to_not have_content(description_too_short_message)
    end

    scenario "too short of a description submitted" do
      visit "/articles/new"
      fill_in "Title", with: title
      fill_in "URL", with: url
      fill_in "Description", with: "hi mom"
      click_button "Submit"

      expect(page).to have_content(description_too_short_message)
      expect(page).to_not have_content(missing_fields_message)
      expect(page).to_not have_content(invalid_url_message)
      expect(page).to_not have_content(url_already_exists_message)
    end

    scenario "more than one error message may be shown" do
      visit "/articles/new"
      fill_in "URL", with: "invalid url"
      fill_in "Description", with: "hi mom"
      click_button "Submit"

      expect(page).to have_content(missing_fields_message)
      expect(page).to have_content(invalid_url_message)
      expect(page).to have_content(description_too_short_message)
    end

    scenario "form is re-rendered with previously submitted details" do
      visit "/articles/new"
      fill_in "Title", with: title
      click_button "Submit"

      expect(page).to have_css("input[value='#{title}']")
    end
  end
end
