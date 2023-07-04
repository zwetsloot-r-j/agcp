defmodule Agcp.Cp do
  @type search_result :: Agcp.Ag.search_result
  @type reason :: term

  @spec copy_line(search_result, number) :: {:ok, String.t} | {:error, reason}
  def copy_line(search_result, line_number) do
    line = Enum.at(search_result, line_number - 1)
    case find_file_and_line(line) do
      :none ->
        copy(line)
      {file, line} ->
        copy("vim #{file} -c :#{line}")
      file ->
        copy("vim #{file}")
    end
  end

  @spec copy_pattern(search_result, String.t) :: {:ok, String.t} | {:error, reason}
  def copy_pattern(search_result, pattern) do
    content = Enum.join(search_result, "\n")
    with {:ok, regex} <- Regex.compile(pattern),
         [head | _] <- Regex.run(regex, content)
    do
      copy(head)
    else
      {:error, error} ->
        {:error, error}
      [] ->
        {:error, :no_match}
      nil ->
        {:error, :no_match}
      _ ->
        {:error, :unknown_error}
    end
  end

  defp copy(nil) do
    {:error, :index_out_of_range}
  end

  defp copy(line) do
    Clipboard.copy(line)
    |> (& {:ok, &1}).()
  end

  defp find_file_and_line(line) do
    case {Regex.run(~r/.+\.[^\s]+$/, line), Regex.run(~r/^[^:]+:\d+(?=:)/, line)} do
      {nil, nil} ->
        :none
      {[file | _], nil} ->
        file
      {_, [file_and_line | _]} ->
        [file, line] = String.split(file_and_line, ":")
        {file, line}
    end
  end

end
