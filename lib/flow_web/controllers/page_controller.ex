defmodule FlowWeb.PageController do
  use FlowWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
