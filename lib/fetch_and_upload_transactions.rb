class FetchAndUploadTransactions
  def initialize(fetcher:, uploader:)
    @fetcher = fetcher
    @uploader = uploader
  end

  def call
    Dir.mktmpdir do |working_directory|
      transactions_path = fetcher.fetch(working_directory: working_directory)
      uploader.upload(transactions_path: transactions_path)

      yield if block_given?

      uploader.done
    end
  end

  private

  attr_reader :fetcher, :uploader
end