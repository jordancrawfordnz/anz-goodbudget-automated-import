require "selenium-webdriver"

class ANZTransactionFetcher
  LOGIN_URL = "https://digital.anz.co.nz/preauth/web/service/login"
  USERNAME_FIELD_NAME = "userId"
  PASSWORD_FIELD_NAME = "password"
  LOGIN_BUTTON_ID = "submit"
  EXPORT_BUTTON_TEXT = "Export"
  EXPORT_DOWNLOAD_BUTTON_NAME = "_eventId_exportTransactions"
  LOGOUT_BUTTON_TEXT = "Log off"

  def initialize(customer_id:, password:, account_name:)
    @customer_id = customer_id
    @password = password
    @account_name = account_name
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
  end

  def run
    driver = Selenium::WebDriver.for :chrome
    driver.navigate.to(LOGIN_URL)

    driver.find_element(:name, USERNAME_FIELD_NAME).send_keys(@customer_id)
    driver.find_element(:name, PASSWORD_FIELD_NAME).send_keys(@password)
    driver.find_element(:id, LOGIN_BUTTON_ID).submit
    begin
      account_link = @wait.until { driver.find_element(:link_text, @account_name) }
      account_link.click

      export_button = @wait.until { driver.find_element(:link_text, EXPORT_BUTTON_TEXT) }
      export_button.click

      export_download_button = @wait.until { driver.find_element(:name, EXPORT_DOWNLOAD_BUTTON_NAME) }
      export_download_button.click
    ensure
      driver.find_element(:link_text, LOGOUT_BUTTON_TEXT).click
      driver.quit
    end
  end
end
