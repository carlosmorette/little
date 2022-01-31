defmodule Little.Board do
  require Integer

  @blank 0
  @chunk_size 4

  @first_position_in_chunk 0
  @last_position_in_chunk 3

  @first_position_in_board 0
  @last_position_in_board 3

  def generate_board_with_chunks() do
    0..15
    |> Enum.shuffle()
    |> Enum.chunk_every(@chunk_size)
    |> is_solvable()
  end

  def is_solvable(board_in_chunks) do
    inversions =
      board_in_chunks
      |> List.flatten()
      |> count_inversion()

    chunk_of_zero = chunk_of_zero(board_in_chunks)

    cond do
      Integer.is_even(inversions) and Integer.is_odd(chunk_of_zero) ->
        board_in_chunks

      Integer.is_odd(inversions) and Integer.is_even(chunk_of_zero) ->
        board_in_chunks

      true ->
        generate_board_with_chunks()
    end
  end

  def count_inversion(board), do: do_count_inversion(board, board, 0)

  defp do_count_inversion([a, b | rest], board, acc) when a > b and not (b == 0),
    do: do_count_inversion([a | rest], board, acc + 1)

  defp do_count_inversion([a, _b | rest], board, acc),
    do: do_count_inversion([a | rest], board, acc)

  defp do_count_inversion([_x], [_a | board], acc),
    do: do_count_inversion(board, board, acc)

  defp do_count_inversion([], _pass, acc), do: acc

  def chunk_of_zero(board_in_chunks) do
    board_in_chunks
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {c, index} -> {c, index + 1} end)
    |> Enum.filter(&Enum.member?(elem(&1, 0), @blank))
    |> List.first()
    |> elem(1)
  end

  def make_exchange(chunk_board, neighbor) do
    board = List.flatten(chunk_board)
    {neighbor_index, blank_index} = find_indexs(board, neighbor)
    change_parts(board, neighbor, neighbor_index, blank_index)
  end

  def find_indexs(board, neighbor) do
    {Enum.find_index(board, &(&1 == neighbor)), Enum.find_index(board, &(&1 == @blank))}
  end

  def change_parts(board, neighbor, neighbor_index, blank_index) do
    board
    |> List.replace_at(neighbor_index, @blank)
    |> List.replace_at(blank_index, neighbor)
    |> Enum.chunk_every(@chunk_size)
  end

  def space_neighbors(chunk_board) do
    chunk_board
    |> get_blank_position()
    |> capture_moving_parts_in_own_chunk()
    |> capture_other_moving_parts(chunk_board)
  end

  def get_blank_position(chunk_board) do
    chunk_board
    |> Enum.with_index()
    |> Enum.filter(fn {chunk, _index} -> Enum.member?(chunk, 0) end)
    |> List.first()
    |> then(fn {chunk, index} ->
      {chunk, index, Enum.find_index(chunk, &(&1 == @blank))}
    end)
  end

  def capture_moving_parts_in_own_chunk({chunk, index, @first_position_in_chunk = blank_index}) do
    {[Enum.at(chunk, blank_index + 1)], index, blank_index}
  end

  def capture_moving_parts_in_own_chunk({chunk, index, @last_position_in_chunk = blank_index}) do
    {[Enum.at(chunk, blank_index - 1)], index, blank_index}
  end

  def capture_moving_parts_in_own_chunk({chunk, index, blank_index}) do
    parts = [Enum.at(chunk, blank_index - 1), Enum.at(chunk, blank_index + 1)]
    {parts, index, blank_index}
  end

  def capture_other_moving_parts(
        {blank_neighbors, @first_position_in_board = blank_chunk_index, blank_index},
        chunks
      ) do
    neighbor_piece =
      chunks
      |> Enum.at(blank_chunk_index + 1)
      |> Enum.at(blank_index)

    [neighbor_piece | blank_neighbors]
  end

  def capture_other_moving_parts(
        {blank_neighbors, @last_position_in_board = blank_chunk_index, blank_index},
        chunks
      ) do
    neighbor_piece =
      chunks
      |> Enum.at(blank_chunk_index - 1)
      |> Enum.at(blank_index)

    [neighbor_piece | blank_neighbors]
  end

  def capture_other_moving_parts({blank_neighbors, blank_chunk_index, blank_index}, chunks) do
    [Enum.at(chunks, blank_chunk_index + 1), Enum.at(chunks, blank_chunk_index - 1)]
    |> Enum.reduce(blank_neighbors, fn neighboring_chunk, acc ->
      neighbor_piece = Enum.at(neighboring_chunk, blank_index)
      [neighbor_piece | acc]
    end)
  end
end
