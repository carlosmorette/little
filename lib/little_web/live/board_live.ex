defmodule LittleWeb.BoardLive do
  use LittleWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= for _line <- 1..5 do %>
      <div style="width: 80vw; display: flex">
        <%= for _c <- 1..5 do %>
          <div style="display: flex; flex-direction: column">
            <div class="square"></div>
          </div>
        <% end %>
      </div>
    <% end %>
    """
  end
end
