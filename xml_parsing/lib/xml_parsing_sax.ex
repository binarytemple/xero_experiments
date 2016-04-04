# code adapted from - 
# http://benjamintan.io/blog/2014/10/01/parsing-wikipedia-xml-dump-in-elixir-using-erlsom/ 

defmodule SaxTransactionSearch  do

    defmodule Contact do
      defstruct contact_id: "", name: ""
    end

    defmodule BankAccount do 
      defstruct account_id: "", name: ""
    end

    defmodule BankTransaction do
      defstruct contact: %Contact{}, 
	  date: "", status: "",line_amount_types: "",sub_total: "",total_tax: "",
	  total: "",updated_date_utc: "",currency_code: "",bank_transaction_id: "",
	  bank_account: %BankAccount{}, 
	  is_reconciled: "",has_attachments: "" 
    end

    @chunk 10000 

    #@spec add(string, pid):: any()
    def run(path,output_pid, max \\ :unlimited) do

      {:ok, handle} = File.open(path, [:binary])
      try do
        position           = 0
        c_state            = {handle, position, @chunk}

        # state is output_pid, current_record, transaction|nil, max_records|:unlimited , tag_stack},
        :erlsom.parse_sax("", 
                          {output_pid, 0, nil, max, [], "" },
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
  
  def sax_event_handler({:startElement, _, 'BankTransaction', _, _}, state) do
    {callback_pid,count,transaction,max_results,tag_stack,text} = state
    # IO.puts "Hit BankTransaction #{inspect state } "
    {callback_pid, 1 + count , Map.from_struct(%BankTransaction{}) ,max_results, [:bank_transaction],text}  
  end

  def sax_event_handler({:startElement, _, 'BankAccount', _,_}, state) do
    {callback_pid,count,transaction,max_results,tag_stack,text} = state
    # IO.puts "Hit BankAccount #{inspect state } "
    {callback_pid, count  , transaction ,max_results, [:bank_account| tag_stack],text}  
  end
  
  def sax_event_handler({:endElement, _, 'BankAccount', _}, state) do
    {callback_pid,count,transaction,max_results,[top_tag|rest_tags],text} = state
    # IO.puts "Hit BankAccount #{inspect state } "
    {callback_pid, count  , transaction ,max_results, rest_tags,text}  
  end
  
  def sax_event_handler({:startElement, _, 'Contact', _, _}, state) do
    {callback_pid,count,transaction,max_results,tag_stack,text} = state
    # IO.puts "Hit Contact #{inspect state } "
    {callback_pid, count  , transaction ,max_results, [:contact| tag_stack],text}  
  end
  
  def sax_event_handler({:endElement, _, 'Contact', _}, state) do
    {callback_pid,count,transaction,max_results,[top_tag|rest_tags],text} = state

    {callback_pid, count  , transaction ,max_results, rest_tags,text}  
  end
  
  def sax_event_handler({:startElement, _, element, _, _}, state) do
    IO.puts "sax_event_handler - hit - #{inspect element} - #{inspect state}"
    {callback_pid,count,transaction,max_results,tag_stack,text} = state
    state
  end

  def sax_event_handler({:endElement, _, 'BankTransaction', _}, state ) do
    {callback_pid,count,transaction,max_results,tag_stack,text} = state
    IO.puts("------------------------------------------------")
    IO.puts("hit :endElement BankTransaction #{inspect state}")
    IO.puts("------------------------------------------------")
    
    case {count,max_results} do 
      {_,:unlimited} -> 
        send(callback_pid,{transaction,state}) ; state 
      {count,max_results} when count <= max_results -> 
        send(callback_pid,state) ; state 
      {count,max_results} when count > max_results -> 
        send(callback_pid,state) ; throw(:max_count_reached)
      _ -> 
            IO.puts "NO-MATCH"; state

 
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
  
  
  def sax_event_handler({:endElement, [], tag, []}, state) do 
	  
	  IO.puts "sax_event_handler endElement tag"
	  {callback_pid,count, transaction, max_results, tag_stack, text} = state

	  trans2 = case tag_stack do 
		   [:bank_transaction] -> transaction
		   [:contact, :bank_transaction] -> transaction
		   [:bank_account, :bank_transaction] -> transaction
		  _ -> transaction
	  end
	  
	  state2 = {callback_pid,count, trans2, max_results, tag_stack, text}
	  
	  IO.puts("#{inspect state2}")
	  
	  state2
#    # IO.puts "reached catch-all sax_event_handler #{inspect state}"
 #    IO.puts "reached catch-all sax_event_handler #{inspect event} #{inspect state}  "

  end
  
  def sax_event_handler({:characters, value},  state ) do
    {callback_pid,count, transaction, max_results, tag_stack, text} = state

	
	
	
    state
  end
  
  
  def sax_event_handler(event, state) do 
#    IO.puts "reached catch-all sax_event_handler #{inspect state}"
    # IO.puts "reached catch-all sax_event_handler #{inspect event} #{inspect state}  "
    state
  end
  
  
end


