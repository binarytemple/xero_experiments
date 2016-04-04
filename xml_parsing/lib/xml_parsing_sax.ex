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
      defstruct contact: %Contact{}, date: "", status: "",line_amount_types: "",sub_total: "",total_tax: "", total: "",updated_date_utc: "",currency_code: "",bank_transaction_id: "", bank_account: %BankAccount{}, is_reconciled: "",has_attachments: ""
    end

    @chunk 10000

    def init_state(output_pid,max) do
      {output_pid, 0, nil, max, [], "" }
    end

    def run(path,output_pid, max \\ :unlimited) do
      {:ok, handle} = File.open(path, [:binary])
      try do
        position           = 0
        c_state            = {handle, position, @chunk}
        # state is output_pid, current_record, transaction|nil, max_records|:unlimited , tag_stack},
        :erlsom.parse_sax("",
                          init_state(output_pid,max),
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

    def sax_event_handler({:startElement, _, 'BankTransaction', _, _}, state) do
        {callback_pid,count,_,max_results,_,text} = state
        {callback_pid, 1 + count , Map.from_struct(%BankTransaction{}) ,max_results, [:bank_transaction],text}
    end

    def sax_event_handler({:startElement, _, 'BankAccount', _,_}, state) do
        {callback_pid,count,transaction,max_results,tag_stack,text} = state
        {callback_pid, count  , transaction ,max_results, [:bank_account| tag_stack],text}
    end

    def sax_event_handler({:endElement, _, 'BankAccount', _}, state) do
        {callback_pid,count,transaction,max_results,[_|rest_tags],text} = state
        {callback_pid, count  , transaction ,max_results, rest_tags,text}
    end

    def sax_event_handler({:startElement, _, 'Contact', _, _}, state) do
        {callback_pid,count,transaction,max_results,tag_stack,text} = state
        {callback_pid, count  , transaction ,max_results, [:contact| tag_stack],text}
    end

    def sax_event_handler({:endElement, _, 'Contact', _}, state) do
        {callback_pid,count,transaction,max_results,[_|rest_tags],text} = state
        {callback_pid, count  , transaction ,max_results, rest_tags,text}
    end

    def sax_event_handler({:endElement, _, 'BankTransaction', _}, state ) do
        {callback_pid,count,transaction,max_results,_,_} = state
            case {count,max_results} do
              {_,:unlimited} ->
                send(callback_pid,{transaction,state}) ; state
              {count,max_results} when count <= max_results ->
                send(callback_pid,state) ; state
              {count,max_results} when count > max_results ->
                send(callback_pid,state) ; throw(:max_count_reached)
              _ -> state
        end
    end

      def sax_event_handler({:endElement, [], tag, []}, state) do
          {callback_pid,count, transaction, max_results, tag_stack, text} = state
          trans2 = case tag_stack do
               [:bank_transaction] -> transform_bank_transaction(tag,transaction,text)
               [:contact, :bank_transaction] -> transform_bank_transaction_contact(tag,transaction,text)
               [:bank_account, :bank_transaction] -> transform_bank_transaction_bank_account(tag,transaction,text)
              _ -> transaction
          end

          # notice we clear the text
          state2 = {callback_pid,count, trans2, max_results, tag_stack, ""}
          #IO.puts("state 2 #{inspect state2}")
          state2
      end

      def sax_event_handler({:characters, value},  state ) do
        {callback_pid,count, transaction, max_results, tag_stack, text } = state
        {callback_pid,count, transaction, max_results, tag_stack, text <> to_string(value) }
      end

      # - catch-all handler
      def sax_event_handler(_event, state) do
        state
      end
 
  # - functions for binding data to the transaction data
	def transform_bank_transaction(tag,transaction,text) do 
		# IO.puts("transform_bank_transaction #{inspect {tag,transaction,text} }")
		case tag do 
			'Date' -> put_in transaction[:date], text
			'Status' -> put_in transaction[:status], text
			'LineAmountTypes' -> put_in transaction[:line_amount_types], text
			'SubTotal' -> put_in transaction[:sub_total], text
			'TotalTax' -> put_in transaction[:total_tax], text
			'Total' -> put_in transaction[:total], text
			'UpdatedDateUTC' -> put_in transaction[:updated_date_utc], text
			'CurrencyCode' -> put_in transaction[:currency_code], text
			'BankTransactionID' -> put_in transaction[:bank_transaction_id], text
			'Type' -> put_in transaction[:type], text
			'IsReconciled' -> put_in transaction[:is_reconciled], text
			'HasAttachments' -> put_in transaction[:has_attachments], text
			_ -> transaction			
		end
	end

	def transform_bank_transaction_contact(tag,transaction,text) do
		case tag do 
			'ContactID' -> put_in transaction[:contact].contact_id, text
			'Name' -> put_in transaction[:contact].name, text
			_ -> transaction			
		end
	end

	def transform_bank_transaction_bank_account(tag,transaction,text) do 
		case tag do 
			'AccountID' -> put_in transaction[:bank_account].account_id, text
			'Name' ->  put_in transaction[:bank_account].name, text
			_ -> transaction			
		end
	end
end