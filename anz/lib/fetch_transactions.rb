require_relative 'clean_transactions'
require_relative 'fetch_raw_transactions'

module ANZ
  class FetchTransactions
    def initialize(customer_id:, password:, account_name:)
      @customer_id = customer_id
      @password = password
      @account_name = account_name
    end

    def fetch(working_directory:)
      raw_transactions_path = ANZ::FetchRawTransactions.new(
        customer_id: customer_id,
        password: password,
        account_name: account_name,
        download_dir: working_directory
      ).call

      clean_csv_path = ANZ::CleanTransactions.new(
        clean_export_directory: working_directory,
        transaction_file_path: raw_transactions_path
      ).call

      clean_csv_path
    end

    private

    attr_reader :customer_id, :password, :account_name
  end
end