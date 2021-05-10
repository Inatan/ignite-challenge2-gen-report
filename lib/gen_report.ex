defmodule GenReport do
  alias GenReport.Parser

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
