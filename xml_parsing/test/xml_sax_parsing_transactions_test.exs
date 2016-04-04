defmodule XmlParsingTransactionsTest do
use ExUnit.Case


  @sample_transactions Path.expand("test/transactions.xml")
  @sample_2_transactions Path.expand("test/transactions2.xml")

  test "parsing the title out" do

  p = self()
    task = Task.async(fn -> SaxTransactionSearch.run(@sample_2_transactions,p,:unlimited) end)

  receive do 
  x ->
    IO.puts :stderr, (inspect x)
  after
  4000 ->
      IO.puts :stderr, "No message in 4 seconds"
  end
  Task.await(task)
  assert 1 == 1
  end

end
