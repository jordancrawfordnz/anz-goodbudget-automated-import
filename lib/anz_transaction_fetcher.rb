require "selenium-webdriver"

class ANZTransactionFetcher
  LOGIN_URL = "https://digital.anz.co.nz/preauth/web/service/login"
  USERNAME_FIELD_NAME = "userId"
  PASSWORD_FIELD_NAME = "password"
  LOGIN_BUTTON_ID = "submit"
  EXPORT_BUTTON_TEXT = "Export"
  EXPORT_DOWNLOAD_BUTTON_NAME = "_eventId_exportTransactions"
  LOGOUT_BUTTON_TEXT = "Log off"

  def initialize(customer_id:, password:, account_name:, download_dir:)
    @customer_id = customer_id
    @password = password
    @account_name = account_name
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
    @download_dir = download_dir
  end

  def run
    profile = Selenium::WebDriver::Chrome::Profile.new
    profile['download.prompt_for_download'] = false
    profile['download.default_directory'] = @download_dir
    initial_download_dir_contents = Dir.entries(@download_dir)

    driver = Selenium::WebDriver.for :chrome, :profile => profile
    driver.navigate.to(LOGIN_URL)

    driver.find_element(:name, USERNAME_FIELD_NAME).send_keys(@customer_id)
    driver.find_element(:name, PASSWORD_FIELD_NAME).send_keys(@password)
    driver.find_element(:id, LOGIN_BUTTON_ID).submit

    account_link = @wait.until { driver.find_element(:link_text, @account_name) }
    account_link.click

    export_button = @wait.until { driver.find_element(:link_text, EXPORT_BUTTON_TEXT) }
    export_button.click

    export_download_button = @wait.until { driver.find_element(:name, EXPORT_DOWNLOAD_BUTTON_NAME) }
    export_download_button.click

    driver.find_element(:link_text, LOGOUT_BUTTON_TEXT).click
    driver.quit
    changed_files = Dir.entries(@download_dir) - initial_download_dir_contents
    @download_dir + "/" + changed_files.first
  end
end
