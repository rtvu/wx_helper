defmodule Unmake do
  @erl_path "./src/wx_elixir_helper.erl"
  @ex_path "./lib/wx_helper.ex"

  def run() do
    remove_file(@erl_path)
    remove_file(@ex_path)
  end

  defp remove_file(path) do
    if File.exists?(path) do
      File.rm!(path)
    end
  end
end

Unmake.run()
