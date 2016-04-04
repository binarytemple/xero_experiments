defmodule XmlParsingTransactionsTest do
use ExUnit.Case


  @sample_transactions Path.expand("test/transactions.xml")
  @sample_2_transactions Path.expand("test/transactions2.xml")

  test "parsing the title out" do

  p = self()
    #task = Task.async(fn -> SaxTransactionSearch.run(@sample_2_transactions,p,:unlimited) end)
    SaxTransactionSearch.run(@sample_2_transactions,p,1)

  res = receive do 
      state  ->
      IO.puts :stderr, "got state #{inspect state}" ; {:ok, state}
    after
    4000 ->
    IO.puts :stderr, "No message in 4 seconds" ; {:error, :timeout}
  end

  #Task.await(task)
  IO.puts "result - #{inspect res}"
  assert 1 == 1
  end

end
