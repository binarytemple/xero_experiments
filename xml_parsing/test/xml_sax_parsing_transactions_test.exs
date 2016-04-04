defmodule XmlParsingTransactionsTest do
use ExUnit.Case


  @sample_transactions Path.expand("test/transactions.xml")
  @sample_2_transactions Path.expand("test/transactions2.xml")

  test "parsing the title out" do

  p = self()
    #task = Task.async(fn -> SaxTransactionSearch.run(@sample_2_transactions,p,:unlimited) end)
    #SaxTransactionSearch.run(@sample_2_transactions,p,1)
      task=Task.async(fn -> SaxTransactionSearch.run(@sample_2_transactions,p,1) end )

  res = receive do 
      state  ->
      IO.puts :stderr, "got state #{inspect state}" ; {:ok, state}
    after
    4000 ->
    IO.puts :stderr, "No message in 4 seconds" ; {:error, :timeout}
  end

  res2 = receive do 
    x -> x
  after 4000 -> nil
  end

  task_result = Task.await(task)
  IO.puts "result res - #{inspect res}"
  IO.puts "result res2 - #{inspect res2}"
  IO.puts "result task_result - #{inspect task_result}"

  assert 1 == 1
  end

end
