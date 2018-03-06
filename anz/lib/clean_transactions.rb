require "anz_bank_csv_cleaner"

module ANZ
  class CleanTransactions
    def initialize(clean_export_directory:, transaction_file_path:)
      @clean_export_directory = clean_export_directory
      @transaction_file_path = transaction_file_path
    end

    def call
      ANZBankCSVCleaner.new(
        import_path: transaction_file_path,
        export_path: clean_csv_path
      ).run

      clean_csv_path
    end

    private

    def clean_csv_path
      clean_export_directory + '/clean.csv'
    end

    attr_reader :clean_export_directory, :transaction_file_path
  end
end