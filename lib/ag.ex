defmodule Agcp.Ag do
  @moduledoc """
  TODO
  """

  @type search_result :: [String.t]
  @type reason :: atom

  @build Mix.env()

  @doc """
  TODO
  """
  @spec run_ag_command(String.t) :: {:ok, search_result} | {:error, reason}
  def run_ag_command(command) when not is_binary(command) do
    run_ag_command("")
  end

  def run_ag_command("") do
    {:error, :invalid_ag_command}
  end

  def run_ag_command(command) do
    run_ag_command(System.find_executable("ag"), command)
  end

  @spec run_ag_command(String.t | nil, String.t) :: {:ok, search_result} | {:error, reason}
  def run_ag_command(nil, _command) do
    {:error, :ag_not_installed}
  end

  def run_ag_command(_executable, command) do
    (if @build == :agcp, do: "ag #{command}", else: "ag -g #{command}")
    |> to_charlist
    |> :os.cmd
    |> to_string
    |> String.replace(command, "#{IO.ANSI.color_background(0, 0, 2)}#{IO.ANSI.cyan}#{IO.ANSI.bright}#{command}#{IO.ANSI.reset}")
    |> String.split("\n")
    |> Enum.filter(& &1 != "")
    |> (& {:ok, &1}).()
  end
end
