defmodule Mix.Tasks.Build do
  use Mix.Task

  def run(_) do
    IO.puts("building agcp executable:")
    IO.puts("")
    :os.cmd('MIX_ENV=agcp mix escript.build') |> IO.puts

    IO.puts("building agg executable:")
    IO.puts("")
    :os.cmd('MIX_ENV=agg mix escript.build') |> IO.puts
  end
end
