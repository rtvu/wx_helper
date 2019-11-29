defmodule Unmake do
  @gl_erl_relative_path       "./src/gl_elixir_helper.erl"
  @glu_erl_relative_path      "./src/glu_elixir_helper.erl"
  @wx_erl_relative_path       "./src/wx_elixir_helper.erl"
  @wx_helper_ex_relative_path "./lib/wx_helper.ex"

  @relative_paths [
                    @gl_erl_relative_path,
                    @glu_erl_relative_path,
                    @wx_erl_relative_path,
                    @wx_helper_ex_relative_path
                  ]

  def run() do
    for relative_path <- @relative_paths do
      remove_file(relative_path)
    end
  end

  defp remove_file(relative_path) do
    path = Path.expand(relative_path, __DIR__)

    if File.exists?(path) do
      File.rm!(path)
    end
  end
end

Unmake.run()
