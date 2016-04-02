defmodule XmlParsingTransactionsTest do
use ExUnit.Case

@sample_transactions Path.expand("~/Google Drive/xero-api/transactions/april-2016.xml")

  test "parsing the title out" do

  SaxTransactionSearch.run(@sample_transactions)

  assert 1 == 1
  end

end
