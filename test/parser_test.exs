defmodule GenReport.ParserTest do
  use ExUnit.Case
  alias GenReport.Parser

  describe "parse_file/1" do
    test "parses the file" do
      file_name = "gen_report_test.csv"

      response =
        file_name
        |> Parser.parse_file()
        |> Enum.map(& &1)

      expected_response = [
        ["Daniele", 7, 29, 4, 2018],
        ["Mayk", 4, 9, 12, 2019],
        ["Daniele", 5, 27, 12, 2016],
        ["Mayk", 1, 2, 12, 2017],
        ["Giuliano", 3, 13, 2, 2017],
        ["Cleiton", 1, 22, 6, 2020],
        ["Giuliano", 6, 18, 2, 2019],
        ["Jakeliny", 8, 18, 7, 2017],
        ["Joseph", 3, 17, 3, 2017],
        ["Jakeliny", 6, 23, 3, 2019]
      ]

      assert response == expected_response
    end
  end
end
