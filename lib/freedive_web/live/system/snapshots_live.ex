defmodule FreediveWeb.SystemSnapshotsLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.title>
      System Snapshots
    </.title>
    """
  end
end
