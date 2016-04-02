defmodule SaxTransactionSearch  do
  defmodule SaxState do
    defstruct title: "", text: "", element_acc: ""
  end

  @chunk 10000 

  def run(path) do
    {:ok, handle} = File.open(path, [:binary])

    position           = 0
    c_state            = {handle, position, @chunk}

    :erlsom.parse_sax("", 
                      nil, 
                      &sax_event_handler/2, 
                      [{:continuation_function, &continue_file/2, c_state}])

    :ok = File.close(handle)
  end

  def continue_file(tail, {handle, offset, chunk}) do
    case :file.pread(handle, offset, chunk) do
      {:ok, data} ->
        {<<tail :: binary, data::binary>>, {handle, offset + chunk, chunk}}
      :oef ->
        {tail, {handle, offset, chunk}}
    end
  end

  def sax_event_handler({:startElement, _, 'title', _, _}, _state) do
    %SaxState{}
  end

  def sax_event_handler({:startElement, _, 'BankTransaction', _, _}, state) do
    IO.puts "hit BankTransaction"
    %SaxState{}
    #%{state | element_acc: ""}
  end

  #catchall..
  def sax_event_handler({:startElement, _, attribute, _, _}, state) do
  #IO.inspect attribute
    
    %SaxState{}
  #  #IO.inspect foo
    #%{state | element_acc: ""}
  end


  def sax_event_handler({:characters, value}, %SaxState{element_acc: element_acc} = state) do
    %{state | element_acc: element_acc <> to_string(value)}
  end

  def sax_event_handler({:endElement, _, 'title', _}, state) do
    %{state | title: state.element_acc}
  end

  def sax_event_handler({:endElement, _, 'text', _}, state) do
    state = %{state | text: state.element_acc}
    IO.puts "Title: #{state.title}"
    IO.puts "Text:  #{state.text}"
    state
  end

  def sax_event_handler(:endDocument, state) do 
    IO.puts "END DOCUMENT"

    state
  end
  def sax_event_handler(_, state), do: state

end


