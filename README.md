# ANZ Goodbudget Automated import

## What does this do?
- Fetches your bank transactions from the ANZ Bank website (ANZ New Zealand)
- Cleans the CSV using [jordancrawfordnz/anz-csv-export-cleaner](https://github.com/jordancrawfordnz/anz-csv-export-cleaner). This makes transactions easy to identify in Goodbudget.
- Sets up the import in Goodbudget, leaving you to classify transactions.

## How do I use this?
- Ensure you have Chrome, ChromeDriver (at least version 2.33), Ruby and Bundler installed.
- Clone the repository.
- Run ``bundler install`` in the repository.
- Run from the ``bin`` folder with ``anz-goodbudget-automated-import [ANZ customer ID] [Goodbudget Username] [Account names] [...]``

You will be asked for your ANZ and Goodbudget password. This is not a command line argument for security reasons. This allows automation of some of the arguments but without storing your passwords in plain text on the system.

After an account import, press enter to continue to the next account, or press Control+C if finished.