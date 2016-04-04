defmodule XmlParsingTransactionsTest do
use ExUnit.Case

  defp waitup() do
    receive do 
      state  ->
        IO.puts "waitup - state #{inspect state}" ; state
      after
        4000 ->
        IO.puts "waitup - no message in 4 seconds" ; {:error, :timeout}
    end
  end

  @sample_transactions Path.expand("test/transactions.xml")
  @sample_2_transactions Path.expand("test/transactions2.xml")

  test "parsing the title out" do

  p = self()
    #task = Task.async(fn -> SaxTransactionSearch.run(@sample_2_transactions,p,:unlimited) end)
#    SaxTransactionSearch.run(@sample_2_transactions,p,2)
	SaxTransactionSearch.run(@sample_transactions,p,2)
    #task=Task.async(fn -> SaxTransactionSearch.run(@sample_2_transactions,p,1) end )

  
  IO.inspect(waitup())
  # IO.inspect(waitup())
  #IO.inspect(waitup())

  #IO.puts "result task_result - #{Task.await(task)}"

  assert 1 == 1
  end

end
