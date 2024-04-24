defmodule FreediveWeb.SystemUpdatesLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.title>
      Software Updates
    </.title>
    """
  end
end
