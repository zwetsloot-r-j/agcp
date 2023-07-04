defmodule Agcp.CLI do
  alias Agcp.Ag
  alias Agcp.Cp

  @type arguments :: [String.t]
  @type command :: String.t
  @type options :: %{
    optional(:line) => number,
    optional(:pattern) => String.t
  }
  @type parameters :: :help
    | {command, options}
  @type search_result :: Agcp.Ag.search_result

  @spec main(arguments) :: :ok
  def main(args) do
    parse_args(args)
    |> process
  end

  @spec parse_args(arguments) :: parameters
  defp parse_args(args) do
    parsed = OptionParser.parse(
      args,
      switches: [
        help: :boolean,
        line: :integer,
        pattern: :string,
        filename_pattern: :string
      ],
      aliases: [
        h: :help,
        l: :line,
        p: :pattern,
        g: :filename_pattern
      ]
    )

    case parsed do
      {[help: true], _, _} ->
        :help
      {options, [], _} ->
        parse_options(options, {"", %{}})
      {options, [line_or_command], _} ->
        if is_line(line_or_command) do
          {line, _} = Integer.parse(line_or_command)
          parse_options(options, {"", %{line: line}})
        else
          parse_options(options, {line_or_command, %{}})
        end
      {options, [command, line], _} ->
        {line, _} = Integer.parse(line)
        parse_options(options, {command, %{line: line}})
      _ ->
        :help
    end
  end

  @spec is_line(String.t) :: boolean
  defp is_line(line) do
    Regex.match?(~r/^\d+$/, line)
  end

  @spec parse_options([term], {command, options}) :: {command, options}
  defp parse_options(option_arguments, {command, options}) do
    options = case Keyword.fetch(option_arguments, :line) do
      {:ok, line} -> Map.put(options, :line, line)
      _ -> options
    end

    options = case Keyword.fetch(option_arguments, :pattern) do
      {:ok, pattern} -> Map.put(options, :pattern, pattern)
      _ -> options
    end

    command = case Keyword.fetch(option_arguments, :filename_pattern) do
      {:ok, filename_pattern} -> "-g #{filename_pattern}"
      _ -> command
    end

    {command, options}
  end

  defp process({command, %{line: line, pattern: pattern}}) do
    with {:ok, search_result} <- Ag.run_ag_command(command),
         {:ok, match} <- Cp.copy_pattern([Enum.at(search_result, line - 1) || ""], pattern)
    do
      Ag.color_line_output(match, command)
      |> IO.puts
    else
      {:error, error} -> IO.puts("Error: #{error}")
      _ -> IO.puts("Operation failed unexpectedly")
    end
  end

  @spec process(parameters) :: :ok
  defp process({command, %{line: line}}) do
    with {:ok, search_result} <- Ag.run_ag_command(command),
         {:ok, line} = Cp.copy_line(search_result, line)
    do
      Ag.color_line_output(line, command)
      |> IO.puts
    else
      {:error, error} -> IO.puts("Error: #{error}")
      _ -> IO.puts("Operation failed unexpectedly")
    end
  end

  defp process({command, %{pattern: pattern}}) do
    with {:ok, search_result} <- Ag.run_ag_command(command),
         {:ok, match} <- Cp.copy_pattern(search_result, pattern)
    do
      Ag.color_line_output(match, command)
      |> IO.puts

      process_with_line_from_user(fn line ->
        copy_search_result(command, search_result, line)
      end)
    else
      {:error, error} -> IO.puts("Error: #{error}")
      _ -> IO.puts("Operation failed unexpectedly")
    end
  end

  defp process(:help) do
    IO.puts """
    usage: agcp <ag command> <options>
    or: agcp <ag command> <line number>

    options:
    -h [--help] Display this help.
    -l [--line] The line number of the output to copy to the clipboard.
    -p [--pattern] A pattern to search the output with. The first match will be copied to the clipboard.
    -g [--filename-pattern] Ag option to search for filenames

    example:
    agcp -g mix.exs -l 1
    agcp -g cp.ex 1
    agcp -g ag.ex -p .+x$
    """
  end

  defp process({command, %{}}) do
    case Ag.run_ag_command(command) do
      {:ok, search_result} ->
        search_result
        |> Ag.color_output(command)
        |> output_search_result

        process_with_line_from_user(fn line ->
          copy_search_result(command, search_result, line)
        end)
      {:error, error} ->
        IO.puts("Error: #{error}")
    end
  end

  @spec output_search_result(search_result) :: :ok
  defp output_search_result(search_result) do
    Enum.with_index(search_result)
    |> Enum.map(fn {line, index} -> "  #{IO.ANSI.light_blue}#{index + 1}.#{IO.ANSI.reset} #{line}" end)
    |> Enum.join("\n")
    |> IO.puts
  end

  defp process_with_line_from_user(process) do
    line = IO.gets("> ")
    case Integer.parse(line) do
      {line, _} ->
        process.(line)
      :error ->
        :ok
    end
  end

  defp copy_search_result(command, search_result, line) do
    with {:ok, line} = Cp.copy_line(search_result, line)
    do
      Ag.color_line_output(line, command)
      |> IO.puts
    else
      {:error, error} -> IO.puts("Error: #{error}")
      _ -> IO.puts("Operation failed unexpectedly")
    end
  end

end
