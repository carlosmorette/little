defmodule LittleWeb.GameLive do
  use LittleWeb, :live_view
  import Little.Board, only: [generate_board_with_chunks: 0, make_exchange: 2, space_neighbors: 1]

  @completed_board Enum.to_list(1..15) ++ [0]

  def mount(_params, _session, socket) do
    if connected?(socket) do
      chunk_board = generate_board_with_chunks()

      {:ok,
       assign(socket,
         chunk_board: chunk_board,
         space_neighbors: space_neighbors(chunk_board),
         finished: false
       )}
    else
      {:ok, assign(socket, page: "loading")}
    end
  end

  def render(%{page: "loading"} = assigns) do
    ~H"""
    <h1>Loading...</h1>
    """
  end

  def render(%{space_neighbors: []} = assigns) do
    ~H"""
    <h1>Loading...</h1>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="game-container">
      <div class="game-content">
        <h1>15 puzzle</h1>
        <%= game_render(assigns) %>
      </div>
    </div>
    """
  end

  def game_render(assigns) do
    ~H"""
    <div class="game-container">
      <div>
      <%= if @finished do %>
        <h1>Congratulations!</h1>
      <% else %>

        <%= for line <- @chunk_board do %>
          <div class="flex">
            <%= for column <- line do %>
              <div class="column">

                <%= if not(column == 0) do %>
                  <div class="square fill" phx-value-number={column} phx-click="move">
                    <p><%= column %></p>
                  </div>
                <% else %>
                  <div class="square"></div>
                <% end %>

              </div>
            <% end %>
          </div>
        <% end %>
      <% end %>
      </div>
    </div>
    """
  end

  def handle_event("move", %{"number" => str_number}, socket) do
    int_number = String.to_integer(str_number)
    space_neighbors = socket.assigns.space_neighbors

    if Enum.member?(space_neighbors, int_number) do
      new_chunk_board = make_exchange(socket.assigns.chunk_board, int_number)
      new_space_neighbor = space_neighbors(new_chunk_board)

      socket = 
        if List.flatten(new_chunk_board) == @completed_board do
          update(socket, :finished, fn _ -> true end)
        else
          socket
          |> update(:chunk_board, fn _chunk_board -> new_chunk_board end)
          |> update(:space_neighbors, fn _space_neighbord -> new_space_neighbor end)
        end

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
end
