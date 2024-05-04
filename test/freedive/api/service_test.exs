defmodule Freedive.Api.ServiceTest do
  use ExUnit.Case
  alias Freedive.Api.Service

  test "command line wrapper" do

    {:ok, services} = Service.list()
    assert length(services) > 10


    assert Service.is_running?("dhclient", ["wlan0"]) == true

    assert Service.is_running?("moused") == true

    {:ok, _stdout} = Service.stop("moused")
    assert Service.is_running?("moused") == false

    {:ok, _stdout} = Service.start("moused")
    assert Service.is_running?("moused") == true
  end
end
