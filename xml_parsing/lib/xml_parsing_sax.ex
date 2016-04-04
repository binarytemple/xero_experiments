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
      defstruct contact: %Contact{} , date: "",status: "",line_amount_types: "",sub_total: "",total_tax: "",total: "",updated_date_utc: "",currency_code: "",bank_transaction_id: "",bank_account: %BankAccount{}, is_reconciled: "",has_attachments: "" 
    end

    @chunk 10000 

  #@spec add(string, pid):: any()
  def run(path,output_pid, max \\ :unlimited) do

    {:ok, handle} = File.open(path, [:binary])
    try do
      position           = 0
      c_state            = {handle, position, @chunk}

      # state is output_pid, current_record, transaction|nil, max_records|:unlimited , current_tag|nil},
      :erlsom.parse_sax("", 
                        {output_pid, 0, nil, max, nil },
                        &sax_event_handler/2, 
                        [{:continuation_function, &continue_file/2, c_state}])
    catch
      :max_count_reached -> {:max_count_reached}
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
  
  def sax_event_handler({:startElement, _, 'BankTransaction', _, _}, {callback_pid,count,transaction,max_results,_} = state) do
    #IO.puts "Hit BankTransaction #{inspect state } "
    {callback_pid, 1 + count  , Map.from_struct(%BankTransaction{}) ,max_results, nil}  
  end

  def sax_event_handler({:startElement, _, element, _, _}, {callback_pid,count,transaction,max_results,_} = state) do
    IO.puts "sax_event_handler - hit - #{element}"
    {callback_pid,count,transaction,max_results,element}
  end

  def sax_event_handler({:endElement, _, 'BankTransaction', _}, {callback_pid,count,transaction,max_results,_} = state ) do
    #IO.puts("hit :endElement BankTransaction #{inspect state}")
    case state do 
      {callback_pid,count,transaction,:unlimited,_} -> 
        send(callback_pid,{transaction,count}); {callback_pid,count,nil,max_results,nil} 
      {callback_pid,count,transaction,max_results,_} when count <= max_results -> 
        send(callback_pid,{transaction,count}); {callback_pid,count,nil,max_results,nil} 
      {callback_pid,count,transaction,max_results,_} when count > max_results -> 
        send(callback_pid,{:max_count_reached, state}); throw(:max_count_reached)
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
  
  def sax_event_handler({:characters, value},  state = {callback_pid,count, transaction, max_results, lastTag} ) do
    
    newstate = case lastTag do 


    "Response" -> put_in transaction[:contact].contact_id, 2 
    "Id" ->  put_in transaction[:contact].contact_id, 2 
    _ -> transaction
    #"Status" ->
    #"ProviderName" ->
    #"DateTimeUTC" ->
    #"BankTransactions" ->
    #"Contact" ->
    #"ContactID" ->
    #"Name" ->
    #"Date" ->
    #"Status" ->
    #"LineAmountTypes" ->
    #"SubTotal" ->
    #"TotalTax" ->
    #"Total" ->
    #"UpdatedDateUTC" ->
    #"CurrencyCode" ->
    #"BankTransactionID" ->
    #"BankAccount" ->
    #"AccountID" ->
    #"Name" ->
    #"Type" ->
    #"IsReconciled" ->
    #"HasAttachments" ->
    #"Contact" ->
    #"ContactID" ->
    #"Name" ->
    #"Date" ->
    #"Status" ->
    #"LineAmountTypes" ->
    #"SubTotal" ->
    #"TotalTax" ->
    #"Total" ->
    #"UpdatedDateUTC" ->
    #"CurrencyCode" ->
    #"BankTransactionID" ->
    #"BankAccount" ->
    #"AccountID" ->
    #"Name" ->
    #"Type" ->
    #"IsReconciled" ->
    #"HasAttachments" ->








    end
    
    #%{state | element_acc: element_acc <> to_string(value)}
    IO.puts "lasttag - #{lastTag} - characters - #{value}"
    state
  end

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


