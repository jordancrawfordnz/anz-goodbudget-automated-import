require "selenium-webdriver"

module ANZ
  class FetchRawTransactions
    LOGIN_URL = "https://digital.anz.co.nz/preauth/web/service/login"
    USERNAME_FIELD_NAME = "userId"
    PASSWORD_FIELD_NAME = "password"
    LOGIN_BUTTON_ID = "submit"
    EXPORT_BUTTON_ID = "transactions-export-panel-toggle"
    EXPORT_DOWNLOAD_ID = "transaction-export-submit"
    LOGOUT_BUTTON_ID = "logout"

    def initialize(customer_id:, password:, account_name:, download_dir:)
      @customer_id = customer_id
      @password = password
      @account_name = account_name
      @download_dir = download_dir
    end

    def call
      initial_download_dir_contents = download_dir_contents

      login(username: customer_id, password: password)
      select_account(account_name: account_name)
      download_exported_transactions_for_current_account
      logout

      driver.quit

      downloaded_file_name = changed_files(initial_contents: initial_download_dir_contents).first
      download_path(downloaded_file_name)
    end

    private

    attr_reader :customer_id, :password, :account_name, :download_dir

    def wait
      Selenium::WebDriver::Wait.new(:timeout => 30)
    end

    def chrome_profile_with_download_directory
      profile = Selenium::WebDriver::Chrome::Profile.new
      profile['download.prompt_for_download'] = false
      profile['download.default_directory'] = download_dir

      profile
    end

    def chrome_driver
      Selenium::WebDriver.for :chrome, :profile => chrome_profile_with_download_directory
    end

    def driver
      @driver ||= chrome_driver
    end

    def download_dir_contents
      Dir.entries(download_dir)
    end

    def changed_files(initial_contents:)
      download_dir_contents - initial_contents
    end

    def download_path(file_path)
      download_dir + "/" + file_path
    end

    def login(username:, password:)
      driver.navigate.to(LOGIN_URL)
      username_field = wait.until { driver.find_element(:name, USERNAME_FIELD_NAME) }
      username_field.send_keys(username)
      driver.find_element(:name, PASSWORD_FIELD_NAME).send_keys(password)
      driver.find_element(:id, LOGIN_BUTTON_ID).submit
    end

    def logout
      driver.find_element(:id, LOGOUT_BUTTON_ID).click
    end

    def select_account(account_name:)
      account_link = wait.until { driver.find_element(:link_text, account_name) }
      account_link.click
    end

    def download_exported_transactions_for_current_account
      export_button = wait.until { driver.find_element(:id, EXPORT_BUTTON_ID) }
      export_button.click

      export_download_button = wait.until { driver.find_element(:id, EXPORT_DOWNLOAD_ID) }
      export_download_button.click
      sleep 0.2
    end
  end
end
