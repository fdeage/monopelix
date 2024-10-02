defmodule Monopelix.Decks do
  alias Monopelix.{Card, Logger}

  # A deck is a List of %Card{}
  def chance_start_link do
    Agent.start_link(fn -> chance_cards() |> init_deck() end)
  end

  def community_start_link do
    Agent.start_link(fn -> community_cards() |> init_deck() end)
  end

  def init_deck(cards) do
    Enum.reduce(cards, [], fn card, deck ->
      {:ok, card_pid} = Card.start_link(name: card.name, type: card.type, opt: card.opt)
      [card_pid | deck]
    end)
  end

  def draw(deck) do
    first = Agent.get(deck, fn list -> List.first(list) end)

    Agent.update(deck, fn list ->
      {head, tail} = List.pop_at(list, 0)
      tail ++ [head]
    end)

    Logger.print("Community card", Card.get(first, :name))
    first |> Card.get()
  end

  def shuffle(deck) do
    Agent.update(deck, fn deck -> Enum.shuffle(deck) end)
  end

  defp community_cards do
    [
      %Card{name: "Héritez", type: :money, opt: 10_000},
      %Card{name: "Deuxième prix de beauté", type: :money, opt: 1_000},
      %Card{name: "Allez en prison", type: :move_no_20_000, opt: 10},
      %Card{name: "Police d'Assurance", type: :money, opt: -5_000},
      %Card{name: "Note du médecin", type: :money, opt: -5_000},
      %Card{name: "Vente de votre stock", type: :money, opt: -5_000},
      %Card{name: "Libéré de prison", type: :out_of_jail, opt: nil},
      %Card{name: "Intérêt emprunt à 7%", type: :money, opt: 2_500},
      %Card{name: "Payez à l'hôpital", type: :money, opt: -10_000},
      %Card{name: "Anniversaire", type: :birthday, opt: nil},
      %Card{name: "Avancez case départ", type: :move, opt: 0},
      %Card{name: "Revenu annuel", type: :money, opt: 10_000},
      %Card{name: "Amende ou carte chance", type: :fine_or_redraw, opt: nil},
      %Card{name: "Erreur de la banque", type: :money, opt: 20_000},
      %Card{name: "Retournez à Belleville", type: :move_no_20_000, opt: 1},
      %Card{name: "Contributions vous remboursent", type: :money, opt: 2_000}
    ]
  end

  defp chance_cards do
    [
      %Card{name: "Ivresse", type: :money, opt: -2_000},
      %Card{name: "Allez à Henri-Martin", type: :move, opt: 23},
      %Card{name: "Mots croisés", type: :money, opt: 10_000},
      %Card{name: "Allez en prison", type: :move_no_20_000, opt: 10},
      %Card{name: "Allez à GDL", type: :move, opt: 15},
      %Card{name: "Dividende", type: :money, opt: 5_000},
      %Card{name: "Immeuble et prêts", type: :money, opt: 15_000},
      %Card{name: "Réparations", type: :repair, opt: %{maisons: -2_500, hotels: -10_000}},
      %Card{name: "Avancez case départ", type: :move, opt: 0},
      %Card{name: "Reculez de trois cases", type: :move_relative, opt: -3},
      %Card{name: "Amende pour excès de vitesse", type: :money, opt: -1_500},
      %Card{name: "Payez frais de scolarité", type: :money, opt: -15_000},
      %Card{name: "Allez rue de la Paix", type: :move, opt: 39},
      %Card{name: "Réparations", type: :repair, opt: %{maisons: -4_000, hotels: -11_500}},
      %Card{name: "Allez bd de la Villette", type: :move, opt: 11},
      %Card{name: "Libéré de prison", type: :out_of_jail, opt: nil}
    ]
  end
end
