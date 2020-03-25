defmodule Monopoly.Board do
  defstruct [:cases, :players, :free_park]

  alias Monopoly.{Case, Logger}
  alias __MODULE__

  def increase_case_count(%Board{} = board, case_at) do
    new_case = Case.increment_count(board.cases |> Enum.at(case_at))

    %Board{board | cases: board.cases |> List.replace_at(case_at, new_case)}
  end

  def empty_free_park_bounty(%Board{} = board) do
    %Board{board | free_park: 0}
  end

  def increase_free_park_bounty_by(%Board{} = board, amount) do
    %Board{board | free_park: board.free_park + amount}
  end

  def print_cases(%Board{} = board) do
    total = board.cases |> Enum.reduce(0, fn x, acc -> x.count + acc end)

    board.cases
    |> Enum.sort(fn x, y -> x.count < y.count end)
    |> Enum.map(fn x -> %{x | percent: Float.round(100 * x.count / total, 2)} end)
    |> Logger.print()
  end

  def init_cases do
    [
      %Case{id: 0, name: "Case départ", count: 0, percent: 0},
      %Case{id: 1, name: "Boulevard de Belleville", count: 0, percent: 0},
      %Case{id: 2, name: "Communauté", count: 0, percent: 0},
      %Case{id: 3, name: "Rue Lecourbe", count: 0, percent: 0},
      %Case{id: 4, name: "Impôts sur le revenu", count: 0, percent: 0},
      %Case{id: 5, name: "Gare Montparnasse", count: 0, percent: 0},
      %Case{id: 6, name: "Rue de Vaugirard", count: 0, percent: 0},
      %Case{id: 7, name: "Chance", count: 0, percent: 0},
      %Case{id: 8, name: "Rue de Courcelles", count: 0, percent: 0},
      %Case{id: 9, name: "Avenue de la République", count: 0, percent: 0},
      %Case{id: 10, name: "Simple visite", count: 0, percent: 0},
      %Case{id: 11, name: "Boulevard de la Villette", count: 0, percent: 0},
      %Case{id: 12, name: "Compagnie d'Électricité", count: 0, percent: 0},
      %Case{id: 13, name: "Avenue de Neuilly", count: 0, percent: 0},
      %Case{id: 14, name: "Rue de Paradis", count: 0, percent: 0},
      %Case{id: 15, name: "Gare de Lyon", count: 0, percent: 0},
      %Case{id: 16, name: "Avenue Mozart", count: 0, percent: 0},
      %Case{id: 17, name: "Caisse de communauté", count: 0, percent: 0},
      %Case{id: 18, name: "Boulevard Saint-Michel", count: 0, percent: 0},
      %Case{id: 19, name: "Place Pigalle", count: 0, percent: 0},
      %Case{id: 20, name: "Parc gratuit", count: 0, percent: 0},
      %Case{id: 21, name: "Avenue Matignon", count: 0, percent: 0},
      %Case{id: 22, name: "Chance", count: 0, percent: 0},
      %Case{id: 23, name: "Boulevard Malesherbes", count: 0, percent: 0},
      %Case{id: 24, name: "Avenue Henri-Martin", count: 0, percent: 0},
      %Case{id: 25, name: "Gare du Nord", count: 0, percent: 0},
      %Case{id: 26, name: "Faubourg Saint-Honoré", count: 0, percent: 0},
      %Case{id: 27, name: "Place de la Bourse", count: 0, percent: 0},
      %Case{id: 28, name: "Compagnie des Eaux", count: 0, percent: 0},
      %Case{id: 29, name: "Rue La Fayette", count: 0, percent: 0},
      %Case{id: 30, name: "Allez en prison", count: 0, percent: 0},
      %Case{id: 31, name: "Avenue de Breteuil", count: 0, percent: 0},
      %Case{id: 32, name: "Avenue Foch", count: 0, percent: 0},
      %Case{id: 33, name: "Caisse de communauté", count: 0, percent: 0},
      %Case{id: 34, name: "Boulevard des Capucines", count: 0, percent: 0},
      %Case{id: 35, name: "Gare Saint-Lazare", count: 0, percent: 0},
      %Case{id: 36, name: "Chance", count: 0, percent: 0},
      %Case{id: 37, name: "Avenue des Champs-Élysées", count: 0, percent: 0},
      %Case{id: 38, name: "Taxe de luxe", count: 0, percent: 0},
      %Case{id: 39, name: "Rue de la Paix", count: 0, percent: 0}
    ]
  end
end
