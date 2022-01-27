defmodule LittleWeb.GameLive do
  use LittleWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, x: 60, y: 60)}
  end

  def render(assigns) do
    ~H"""
    <p>X: <%= inspect(@x) %></p>
    <p>Y: <%= inspect(@y) %></p>

    <div phx-window-keydown="move">
      <svg width="100%" height="95vh" style="background-color: red;" version="1.1" xmlns="http://www.w3.org/2000/svg">
        <rect 
          x={@x}
          y={@y} 
          width="30" 
          height="30" 
          stroke="black" 
          fill="transparent" 
          stroke-width="5"
        />
        <rect 
          x="30"
          y="30" 
          width="30" 
          height="30" 
          stroke="black" 
          fill="transparent" 
          stroke-width="5"
        />

      </svg>
    </div>
    """
  end

  def handle_event("move", %{"key" => "ArrowUp"}, socket) do
    {:noreply, update(socket, :y, fn y -> y - 2 end)}
  end

  def handle_event("move", %{"key" => "ArrowDown"}, socket) do
    {:noreply, update(socket, :y, fn y -> y + 2 end)}
  end

  def handle_event("move", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, update(socket, :x, fn x -> x - 2 end)}
  end

  def handle_event("move", %{"key" => "ArrowRight"}, socket) do
    {:noreply, update(socket, :x, fn x -> x + 2 end)}
  end

  def handle_event("move", _, socket) do
    {:noreply, socket}
  end
end
