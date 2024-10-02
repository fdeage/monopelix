defmodule Monopelix.App do
  use Application

  def start(_type, game) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Monopelix.TUI, [game]),
    ]

    opts = [strategy: :one_for_one, name: Monopelix.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Monopelix.Escript do
  alias Monopelix.Game

  defp parse_args(args) do
    options = [switches: [turn: :number, debug: :boolean], aliases: [t: :turn, d: :debug]]

    {opts, word, _} =
      args
      |> OptionParser.parse(options)

    {opts, List.to_string(word)}
  end

  def main(args) do
    {player, board} = init(name: "Féfé")

    {opts, _word} = parse_args(args)

    turn =
      if opts[:turn] do
        opts[:turn]
        |> String.to_integer()
      else
        Application.get_env(:monopoly, :default_turn)
      end

    Monopelix.App.start(:normal, [player, board])
    # {:ok, :game_over} = repeat(turn, player, board)
    # Board.compute_percentages(board)
    # Board.to_string(board) |> Logger.print()
    # Player.to_string(player) |> Logger.print()
    # :erlang.hibernate(Kernel, :exit, [:killed])
  end
end
