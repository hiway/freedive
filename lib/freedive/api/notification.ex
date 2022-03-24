defmodule Freedive.Api.Notification do

  def send(title, message, priority) do
    if Application.get_env(:pushover, :user) != nil and Application.get_env(:pushover, :token) != nil do
      message = %Pushover.Model.Message{
        data: message,
        title: title,
        priority: priority
      }

      Pushover.Api.Messages.send(message)
    end
  end
end
