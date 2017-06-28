require "selenium-webdriver"

module Goodbudget
  class UploadTransactions
    IMPORT_URL = "https://goodbudget.com/import/upload"
    FILE_UPLOAD_FIELD_ID = "import_upload_file"
    USERNAME_FIELD_ID = "username"
    PASSWORD_FIELD_ID = "password"
    IMPORT_FORM_ID = "import-form"
    ACCOUNT_SELECTOR_DROPDOWN_ID = "import_select_account"
    COLUMN_SELECTOR_ID_PREFIX = "import_choose_columns_columns_"
    CSV_COLUMN_VALUES = {
      0 => "date",
      1 => "amount",
      3 => "name"
    }

    def initialize(username:, password:, account_name:)
      @username = username
      @password = password
      @account_name = account_name
    end

    def upload(transactions_path:)
      driver.navigate.to(IMPORT_URL)

      login(username: username, password: password)
      upload_csv(file_path: transactions_path)
      map_csv_columns
      choose_account(account_name: account_name)
    end

    def done
      driver.quit
    end

    private

    attr_reader :username, :password, :account_name

    def chrome_driver
      Selenium::WebDriver.for :chrome
    end

    def driver
      @driver ||= chrome_driver
    end

    def login(username:, password:)
      driver.find_element(:id, USERNAME_FIELD_ID).send_keys(username)
      password_element = driver.find_element(:id, PASSWORD_FIELD_ID)
      password_element.send_keys(password)
      password_element.submit
    end

    def upload_csv(file_path:)
      driver.find_element(:id, FILE_UPLOAD_FIELD_ID).send_keys(file_path)
      driver.find_element(:id, IMPORT_FORM_ID).submit
    end

    def column_mapping_dropdown(column_index:)
      driver.find_element(:id, COLUMN_SELECTOR_ID_PREFIX + column_index.to_s)
    end

    def option_for_column_mapping(dropdown:, column_mapping:)
      dropdown.find_elements(:tag_name, "option").detect do |option|
        option.attribute('value').eql?(column_mapping)
      end
    end

    def map_csv_columns
      CSV_COLUMN_VALUES.each do |column_index, column_mapping|
        dropdown = column_mapping_dropdown(column_index: column_index)
        mapping_option = option_for_column_mapping(dropdown: dropdown, column_mapping: column_mapping)
        mapping_option.click
      end

      driver.find_element(:tag_name, "form").submit
    end

    def account_selector_dropdown
      driver.find_element(:id, ACCOUNT_SELECTOR_DROPDOWN_ID)
    end

    def option_for_account(account_name:)
      account_selector_dropdown.find_elements(:tag_name, "option").detect do |option|
        option.attribute("text").include?(account_name)
      end
    end

    def choose_account(account_name:)
      option_for_account(account_name: account_name).click
      driver.find_element(:tag_name, "form").submit
    end
  end
end
