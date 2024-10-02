defmodule Monopelix.Board do
  defstruct [:cases, :free_park, :chance_deck, :community_deck]

  alias Monopelix.{Case, Decks}
  alias __MODULE__

  # %Board{free_park: pidxx1, cases: %{c0: pidxx2, c1: pidxx3}}
  def start_link do
    board = %Board{
      free_park: init_free_park(),
      cases: init_cases(),
      chance_deck: init_chance_deck(),
      community_deck: init_community_deck()
    }

    Decks.shuffle(board.chance_deck)
    Decks.shuffle(board.community_deck)

    Agent.start_link(fn -> board end)
  end

  defp init_cases do
    Enum.reduce(cases_map(), %{}, fn {name, index}, board ->
      {:ok, c} = Case.start_link(name: name)
      Map.put_new(board, String.to_atom("c#{index}"), c)
    end)
  end

  defp init_free_park do
    {:ok, free_park} = Agent.start_link(fn -> 0 end)
    free_park
  end

  defp init_chance_deck do
    {:ok, chance_deck} = Decks.chance_start_link()
    chance_deck
  end

  defp init_community_deck do
    {:ok, community_deck} = Decks.community_start_link()
    community_deck
  end

  def roll_dice do
    :rand.uniform(6)
  end

  def draw_community(board) do
    get(board, :community_deck)
    |> Decks.draw()
  end

  def draw_chance(board) do
    get(board, :chance_deck)
    |> Decks.draw()
  end

  def increase_case_count(board, case_at) do
    get_cases(board)
    |> Map.get("c#{case_at}" |> String.to_atom())
    |> Case.increment_count()
  end

  # returns a map of pids
  def get_cases(board) do
    get(board, :cases)
  end

  def get_free_park_bounty(board) do
    get(board, :free_park)
    |> Agent.get(& &1)
  end

  def empty_free_park_bounty(board) do
    get(board, :free_park)
    |> Agent.update(fn _ -> 0 end)
  end

  def increase_free_park_bounty_by(board, amount) do
    get(board, :free_park)
    |> Agent.update(fn initial -> initial + amount end)
  end

  def compute_percentages(board) do
    cases = get_cases(board)

    total =
      cases
      |> Enum.reduce(0, fn {_key, val}, acc -> acc + Case.count(val) end)

    cases
    |> Enum.map(fn {_, x} ->
      Case.set(x, :percent, Float.round(100 * Case.count(x) / total, 2))
    end)
  end

  def to_string(board) do
    cases_str =
      get_cases(board)
      |> Enum.sort(fn {_, x}, {_, y} -> Case.count(x) > Case.count(y) end)
      |> Enum.map(fn {_, c} -> %{name: Case.name(c), percent: Case.percent(c)} end)
      |> Enum.reduce("", fn c, acc ->
        "#{acc}, \n name: #{c.name}, percent: #{c.percent}"
      end)

    "free_park: #{get_free_park_bounty(board)}" <> "\n" <> "cases: #{cases_str}"
  end

  defp get(board, key) do
    Agent.get(board, fn state -> Map.get(state, key) end)
  end

  # [["Case départ": 0, "Belleville": 1, ...]]
  defp cases_map do
    [
      "Case départ",
      "Boulevard de Belleville",
      "Communauté",
      "Rue Lecourbe",
      "Impôts sur le revenu",
      "Gare Montparnasse",
      "Rue de Vaugirard",
      "Chance",
      "Rue de Courcelles",
      "Avenue de la République",
      "Simple visite",
      "Boulevard de la Villette",
      "Compagnie d'Électricité",
      "Avenue de Neuilly",
      "Rue de Paradis",
      "Gare de Lyon",
      "Avenue Mozart",
      "Caisse de communauté",
      "Boulevard Saint-Michel",
      "Place Pigalle",
      "Parc gratuit",
      "Avenue Matignon",
      "Chance",
      "Boulevard Malesherbes",
      "Avenue Henri-Martin",
      "Gare du Nord",
      "Faubourg Saint-Honoré",
      "Place de la Bourse",
      "Compagnie des Eaux",
      "Rue La Fayette",
      "Allez en prison",
      "Avenue de Breteuil",
      "Avenue Foch",
      "Caisse de communauté",
      "Boulevard des Capucines",
      "Gare Saint-Lazare",
      "Chance",
      "Avenue des Champs-Élysées",
      "Taxe de luxe",
      "Rue de la Paix"
    ]
    |> Enum.with_index()
  end
end
