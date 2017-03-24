defmodule Make do
  @wx_header_path "wx/include/wx.hrl"

  @src_path "./src"

  @erl_name "wx_elixir_helper"
  @erl_atom ":#{@erl_name}"
  @erl_path "./src/#{@erl_name}.erl"
  @erl_heading ["-module(#{@erl_name}).\n",
                "-compile(export_all).\n\n",
                "-include_lib(\"#{@wx_header_path}\").\n"]

  @ex_path "./lib/wx_helper.ex"
  @ex_heading ["defmodule WxHelper do\n",
               "@moduledoc false\n\n",
               "  require Record\n\n"]
  @ex_ending ["end\n"]

  @record_regex ~r/-record\((?<record>[^,]+),.*/
  @define_regex ~r/-define\((?<define>[^,]+),.*/

  def run() do
    unless File.exists?(@erl_path) and File.exists?(@ex_path) do
      make()
    end
  end

  defp make() do
    make_folder(@src_path)
    clean_file(@erl_path)
    clean_file(@ex_path)

    {records, defines} =  @wx_header_path
                          |> from_lib_file()
                          |> File.read!()
                          |> String.split("\n")
                          |> parse({[], []})

    erl_functions = defines |> Enum.map(&make_erlang_function/1)
    erl_contents = @erl_heading ++ erl_functions

    ex_records = records |> Enum.map(&make_elixir_record/1)
    ex_functions = defines |> Enum.map(&make_elixir_function/1)
    ex_contents = @ex_heading ++ ex_records ++ ["\n"] ++ ex_functions ++ @ex_ending

    erl_file_handle = File.stream!(@erl_path)
    ex_file_handle = File.stream!(@ex_path)

    Enum.into(erl_contents, erl_file_handle)
    Enum.into(ex_contents, ex_file_handle)
  end

  defp make_folder(path) do
    unless File.exists?(path) do
      File.mkdir!(path)
    end
  end

  defp clean_file(path) do
    if File.exists?(path) do
      File.rm!(path)
    end
    File.touch!(path)
  end

  defp parse(lines, values)

  defp parse([], {records, defines}) do
    {Enum.reverse(records), Enum.reverse(defines)}
  end

  defp parse([line | lines], values = {records, defines}) do
    record = Regex.named_captures(@record_regex, line)
    define = Regex.named_captures(@define_regex, line)
    values =  case {record, define} do
                {match = %{}, nil} ->
                  record = match["record"]
                  {[record | records], defines}
                {nil, match = %{}} ->
                  define = match["define"]
                  defines = case define do
                              "wxEMPTY_PARAMETER_VALUE" ->
                                defines
                              "WXK" <> rest ->
                                [{"wxk" <> rest, "WXK" <> rest} | defines]
                              "WX" <> rest ->
                                [{"wx" <> rest, "WX" <> rest} | defines]
                              rest ->
                                [{rest, rest} | defines]
                            end
                  {records, defines}
                _ ->
                  values
              end
    parse(lines, values)
  end

  defp make_elixir_record(record) do
    "  Record.defrecord :#{record}, Record.extract(:#{record}, from_lib: \"#{@wx_header_path}\")\n"
  end

  defp make_elixir_function({function, _macro}) do
    "  def #{function}(), do: #{@erl_atom}.#{function}()\n"
  end

  defp make_erlang_function({function, macro}) do
    "\n#{function}() ->\n  ?#{macro}.\n"
  end

  defp from_lib_file(file) do
    [app | path] = :filename.split(String.to_charlist(file))
    case :code.lib_dir(List.to_atom(app)) do
      {:error, _} ->
        raise ArgumentError, "lib file #{file} could not be found"
      libpath ->
        :filename.join([libpath | path])
    end
  end
end

Make.run()
