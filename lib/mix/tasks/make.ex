defmodule Mix.Tasks.Make do
  use Mix.Task

  @wx_header_path "wx/include/wx.hrl"

  @src_path "./src"

  @erl_name "wx_elixir_helper"
  @wx_elixir_helper_atom ":#{@erl_name}"
  @wx_elixir_helper_path "./src/#{@erl_name}.erl"
  @wx_elixir_helper_heading ["-module(#{@erl_name}).\n",
                             "-compile(export_all).\n\n",
                             "-include_lib(\"#{@wx_header_path}\").\n"]

  @wx_helper_path "./lib/wx_helper.ex"
  @wx_helper_heading ["defmodule WxHelper do\n",
                      "  require Record\n\n"]
  @wx_helper_ending ["end\n"]

  @record_regex ~r/-record\((?<record>[^,]+),.*/
  @define_regex ~r/-define\((?<define>[^,]+),.*/

#  @external_resource wx_header_absolute_path = from_lib_file(@wx_header_path)

  def run(_args) do
    make_src_folder()
    clean_file(@wx_elixir_helper_path)
    clean_file(@wx_helper_path)

    {records, defines} =  @wx_header_path
                          |> from_lib_file()
                          |> File.read!()
                          |> String.split("\n")
                          |> parse({[], []})

    wx_helper_records = records |> Enum.map(&make_elixir_record/1)
    wx_helper_functions = defines |> Enum.map(&make_elixir_function/1)
    wx_helper_contents = @wx_helper_heading ++ wx_helper_records ++ ["\n"] ++ wx_helper_functions ++ @wx_helper_ending

    wx_elixir_helper_functions = defines |> Enum.map(&make_erlang_function/1)
    wx_elixir_helper_contents = @wx_elixir_helper_heading ++ wx_elixir_helper_functions

    wx_helper = File.stream!(@wx_helper_path)
    wx_elixir_helper = File.stream!(@wx_elixir_helper_path)

    Enum.into(wx_helper_contents, wx_helper)
    Enum.into(wx_elixir_helper_contents, wx_elixir_helper)
  end

  defp make_src_folder() do
    unless File.exists?(@src_path) do
      File.mkdir!(@src_path)
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
    "  Record.defrecordp :#{record}, Record.extract(:#{record}, from_lib: \"#{@wx_header_path}\")\n"
  end

  defp make_elixir_function({function, _macro}) do
    "  def #{function}, do: #{@wx_elixir_helper_atom}.#{function}()\n"
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
