defmodule LittleWeb.BoardLive do
  use LittleWeb, :live_view

  @chunk_size 4

  def mount(_params, _session, socket) do
    if connected?(socket) do
      IO.inspect("NA SINTONIA")

      board =
        Range.new(0, 15)
        |> Enum.shuffle()
        |> Enum.chunk_every(@chunk_size)

      Process.send_after(self(), :capture_parts, 1000)

      {:ok, assign(socket, random_board: board, enabled_parts: [])}
    else
      {:ok, assign(socket, page: "loading")}
    end
  end

  def render(%{page: "loading", enabled_parts: []} = assigns) do
    ~H"""
    <h1>Loading...</h1>
    """
  end

  def render(assigns) do
    ~H"""
    <%= for line <- @random_board do %>
      <div class="flex">
        <%= for column <- line do %>
          <div class="column">

            <%= if not(column == 0) do %>
              <div class="square fill" phx-value-number={column} phx-click="move">
                <p><%= column %></p>
              </div>
            <% else %>
              <div class="square" phx-value-zero-id={column} ></div>
            <% end %>

          </div>
        <% end %>
      </div>
    <% end %>
    """
  end

  def handle_info(:capture_parts, socket),
    do: {:noreply, assign(socket, :enabled_parts, enabled_parts(socket))}

  def handle_event("move", %{"number" => number}, socket) do
    if Enum.member?(socket.assigns.enabled_parts, number) do
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def enabled_parts(socket) do
    socket.assigns.random_board
    |> Enum.with_index()
    |> Enum.filter(fn {chunk, _index} -> Enum.member?(chunk, 0) end)
    |> Enum.map(fn {chunk, index} ->
      {chunk, index, Enum.find_index(chunk, &(&1 == 0))}
    end)
    |> List.first()
    |> capture_moving_parts_in_own_chunk()
    |> capture_other_moving_parts(socket.assigns.random_board)
  end

  def capture_moving_parts_in_own_chunk({chunk, index, zero_index}) do
    cond do
      List.first(chunk) == 0 ->
        [Enum.at(chunk, zero_index + 1)]

      List.last(chunk) == 0 ->
        [Enum.at(chunk, zero_index - 1)]

      true ->
        [Enum.at(chunk, zero_index - 1), Enum.at(chunk, zero_index + 1)]
    end
    |> then(fn parts -> {parts, index, zero_index} end)
  end

  def capture_other_moving_parts({enabled_parts, chunk_index, zero_index}, chunks) do
    cond do
      chunk_index == 0 ->
        [Enum.at(chunks, chunk_index + 1)]

      chunk_index == 3 ->
        [Enum.at(chunks, chunk_index - 1)]

      true ->
        [Enum.at(chunks, chunk_index + 1), Enum.at(chunks, chunk_index - 1)]
    end
    |> Enum.reduce(enabled_parts, fn neighboring_chunk, acc ->
      [Enum.at(neighboring_chunk, zero_index) | acc]
    end)
  end
end
