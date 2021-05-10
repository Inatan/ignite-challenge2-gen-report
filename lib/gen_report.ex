defmodule GenReport do
  alias GenReport.Parser
  require Task

  @available_names [
    "Cleiton",
    "Daniele",
    "Danilo",
    "Diego",
    "Giuliano",
    "Jakeliny",
    "Joseph",
    "Mayk",
    "Rafael",
    "Vinicius"
  ]

  @available_months %{
    1 => "janeiro",
    2 => "fevereiro",
    3 => "março",
    4 => "abril",
    5 => "maio",
    6 => "junho",
    7 => "julho",
    8 => "agosto",
    9 => "setembro",
    10 => "outubro",
    11 => "novembro",
    12 => "dezembro"
  }

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn list, report -> sum_value(list, report) end)
  end

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please provide a list of strings"}
  end

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

    {:ok, result}
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)

    hours_per_month = merge_maps_of_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_maps_of_maps(hours_per_year1, hours_per_year2)
    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_maps_of_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> merge_maps(value1, value2) end)
  end

  defp sum_value([nome, quantidadeHoras, _dia, mes, ano], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = Map.put(all_hours, nome, all_hours[nome] + quantidadeHoras)

    hours_per_month =
      Map.put(
        hours_per_month,
        nome,
        Map.put(
          hours_per_month[nome],
          @available_months[mes],
          hours_per_month[nome][@available_months[mes]] + quantidadeHoras
        )
      )

    hours_per_year =
      Map.put(
        hours_per_year,
        nome,
        Map.put(
          hours_per_year[nome],
          ano,
          hours_per_year[nome][ano] + quantidadeHoras
        )
      )

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp report_acc do
    all_hours = Enum.into(@available_names, %{}, &{&1, 0})
    all_years_per_user = Enum.into(2016..2020, %{}, &{&1, 0})
    hours_per_year = Enum.into(@available_names, %{}, &{&1, all_years_per_user})

    all_month_per_user = Enum.into(1..12, %{}, &{@available_months[&1], 0})
    hours_per_month = Enum.into(@available_names, %{}, &{&1, all_month_per_user})

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
