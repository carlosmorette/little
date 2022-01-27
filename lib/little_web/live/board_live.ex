defmodule LittleWeb.BoardLive do
  use LittleWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, socket}
    else
      {:ok, assign(socket, page: "loading")}
    end
  end

  def render(%{page: "loading"} = assigns) do
    ~H"""
    <h1>Loading...</h1>
    """
  end

  def render(assigns) do
    ~H"""
    <%= for line <- Enum.shuffle(0..15) |> Enum.chunk_every(4) do %>
      <div class="flex">
        <%= for column <- line do %>
          <div class="column">
            <%= if not(column == 0) do %>
              <div class="square fill">
                <p><%= column %></p>
              </div>
            <% else %>
              <div class="square">
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    <% end %>
    """
  end
end
