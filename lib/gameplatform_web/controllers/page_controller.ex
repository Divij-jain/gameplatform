defmodule GameplatformWeb.PageController do
  use GameplatformWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
