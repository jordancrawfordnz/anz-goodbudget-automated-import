require_relative("anz_transaction_fetcher")
require_relative("goodbudget_csv_uploader")
require("anz_bank_csv_cleaner")

class ANZGoodbudgetAutomatedImporter
  def initialize(anz_customer_id:, anz_password:, account_name:, goodbudget_username:, goodbudget_password:)
    @anz_customer_id = anz_customer_id
    @anz_password = anz_password
    @account_name = account_name
    @goodbudget_username = goodbudget_username
    @goodbudget_password = goodbudget_password
  end

  def run
    Dir.mktmpdir do |dir|
      transaction_fetcher = ANZTransactionFetcher.new(
        customer_id: @anz_customer_id,
        password: @anz_password,
        account_name: @account_name,
        download_dir: dir
      )
      downloaded_csv_path = transaction_fetcher.run

      clean_csv_path = dir + "/clean.csv"
      ANZBankCSVCleaner.new(import_path: downloaded_csv_path, export_path: clean_csv_path).run

      csv_uploader = GoodbudgetCSVUploader.new(
        username: @goodbudget_username,
        password: @goodbudget_password,
        account_name: @account_name,
        file_path: clean_csv_path
      )
      csv_uploader.run
    end
  end
end
