defmodule XmlParsingTransactionsTest do
use ExUnit.Case




@sample_transactions Path.expand("~/Google Drive/xero-api/transactions/april-2016.xml")

  test "parsing the title out" do

  SaxTransactionSearch.run(@sample_transactions,self(),1)

  receive do 

  x ->
    IO.puts :stderr, (inspect x)
after
  1000 ->
      IO.puts :stderr, "No message in 1 seconds"
  end
  
  assert 1 == 1
  end

end
