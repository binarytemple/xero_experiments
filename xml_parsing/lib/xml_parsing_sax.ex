# code take from - 
# http://benjamintan.io/blog/2014/10/01/parsing-wikipedia-xml-dump-in-elixir-using-erlsom/ 

defmodule SaxTransactionSearch  do

    defmodule Contact do
      defstruct contact_id: "", name: ""
    end

    defmodule BankAccount do 
      defstruct account_id: "", name: ""
    end

    defmodule BankTransaction do
      defstruct contact: %Contact{} , date: "",status: "",line_amount_types: "",sub_total: "",total_tax: "",total: "",updated_date_utc: "",currency_code: "",bank_transaction_id: "",bank_account: "",is_reconciled: "",has_attachments: "" 
    end

    @chunk 10000 

  #@spec add(string, pid):: any()
  def run(path,output_pid, max \\ :unlimited) do

    {:ok, handle} = File.open(path, [:binary])
    try do
      position           = 0
      c_state            = {handle, position, @chunk}
      :erlsom.parse_sax("", 
                        {output_pid, 0, nil, max},
                        &sax_event_handler/2, 
                        [{:continuation_function, &continue_file/2, c_state}])
    catch
      :max_count_reached -> {:ok}
      other -> {:error, other}
    after 
      :ok = File.close(handle); {:ok}
    end
  end

  def continue_file(tail, {handle, offset, chunk}) do
    case :file.pread(handle, offset, chunk) do
      {:ok, data} ->
        {<<tail :: binary, data::binary>>, {handle, offset + chunk, chunk}}
      :oef ->
        {tail, {handle, offset, chunk}}
    end
  end

      #{[C,Cs], Acc};

# More events that need to be acted upon.  
# {characters, string()}
#     Receive notification of character data. 
# startCDATA
#      Report the start of a CDATA section. The contents of the CDATA section will be reported through the regular characters event. 
#      endCDATA
#          Report the end of a CDATA section
  
  
  def sax_event_handler({:startElement, _, 'BankTransaction', _, _}, {callback_pid,count,transaction,max_results} = state) do
    IO.puts "Hit BankTransaction #{inspect state } "
    #%SaxState{}
    #%{state| :transaction => bankTransaction() }
    #Application.start(:iex)
    #require IEx
    #IEx.CLI.start
    #IEx.pry
    #v1=Map.put(state, :transaction, %BankTransaction{})
    #IO.puts "v1: #{inspect v1}" 
 
    #v1=Map.update(state, :count, 0, &(&1 + 1))
    nc=count + 1  
    {callback_pid,nc,transaction,max_results}  
    #IO.puts "v1: #{inspect v1}" 
    #v1 
    #$v1
    #
    #
    #
  end

  def sax_event_handler({:endElement, _, 'BankTransaction', _}, state ) do
    IO.puts("hit :endElement BankTransaction #{inspect state}")
    #{output_pid,data} = state
    #IO.puts "end BankTransaction "
    #
    ##%{state | element_acc: ""}
    ##inspect(output_pid)
    #send(output_pid, ":endElement, 'BankTransaction' #{data} ")
    #{output_pid}
    case state do 
      {callback_pid,count,transaction,:unlimited} -> send(callback_pid,transaction); {callback_pid,count,transaction,:unlimited} 
      {callback_pid,count,transaction,max_results} when count < max_results -> send(callback_pid,transaction);{callback_pid,count,transaction,:unlimited} 
      {callback_pid,count,transaction,max_results} when count >= max_results -> throw(:max_count_reached)
    end
  end

  #catchall..
#  def sax_event_handler({:startElement, _, attribute, _, _}, state) do
  #IO.inspect attribute
#   state 
  #  %SaxState{}
  #  #IO.inspect foo
    #%{state | element_acc: ""}
#  end

  #def sax_event_handler({:startElement, _, name , _, _}, _state) do
  #  %SaxState{}
  #end

  #def sax_event_handler({:characters, value}, %SaxState{element_acc: element_acc} = state) do
  #  %{state | element_acc: element_acc <> to_string(value)}
  #end

#  def sax_event_handler({:endElement, _, 'title', _}, state) do
#    %{state | title: state.element_acc}
#  end
#
#  def sax_event_handler({:endElement, _, 'text', _}, state) do
#    state = %{state | text: state.element_acc}
#    IO.puts "Title: #{state.title}"
#    IO.puts "Text:  #{state.text}"
#    state
#  end

  def sax_event_handler(:endDocument, state) do 
    IO.puts "END DOCUMENT"
  end
  
  def sax_event_handler(event, state) do 
#    IO.puts "reached catch-all sax_event_handler #{inspect state}"
#    IO.puts "reached catch-all sax_event_handler #{inspect event}"
    state
  end
end


