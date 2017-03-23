defmodule Mix.Tasks.Unmake do
  use Mix.Task

  @wx_elixir_helper_path "./src/wx_elixir_helper.erl"
  @wx_helper_path "./lib/wx_helper.ex"

  def run(_args) do
    remove_file(@wx_elixir_helper_path)
    remove_file(@wx_helper_path)
  end

  defp remove_file(path) do
    if File.exists?(path) do
      File.rm!(path)
    end
  end
end
