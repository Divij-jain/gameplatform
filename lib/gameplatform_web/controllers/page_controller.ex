defmodule GameplatformWeb.PageController do
  use GameplatformWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

# %Plug.Conn{
#   adapter: {Plug.Cowboy.Conn, :...},
#   assigns: %{},
#   body_params: %{},
#   cookies: %{},
#   halted: false,
#   host: "localhost",
#   method: "GET",
#   owner: #PID<0.578.0>,
#   params: %{},
#   path_info: [],
#   path_params: %{},
#   port: 4000,
#   private: %{
#     GameplatformWeb.Router => {[], %{Plug.Swoosh.MailboxPreview => ["mailbox"]}},
#     :before_send => [#Function<2.17183421/1 in Phoenix.Controller.fetch_flash/2>,
#      #Function<0.77458138/1 in Plug.Session.before_send/2>,
#      #Function<0.23023616/1 in Plug.Telemetry.call/2>,
#      #Function<1.25036529/1 in Phoenix.LiveReloader.before_send_inject_reloader/3>],
#     :phoenix_action => :index,
#     :phoenix_controller => GameplatformWeb.PageController,
#     :phoenix_endpoint => GameplatformWeb.Endpoint,
#     :phoenix_flash => %{},
#     :phoenix_format => "html",
#     :phoenix_layout => {GameplatformWeb.LayoutView, :app},
#     :phoenix_request_logger => {"request_logger", "request_logger"},
#     :phoenix_root_layout => {GameplatformWeb.LayoutView, :root},
#     :phoenix_router => GameplatformWeb.Router,
#     :phoenix_view => GameplatformWeb.PageView,
#     :plug_session => %{},
#     :plug_session_fetch => :done
#   },
#   query_params: %{},
#   query_string: "",
#   remote_ip: {127, 0, 0, 1},
#   req_cookies: %{},
#   req_headers: [
#     {"accept",
#      "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"},
#     {"accept-encoding", "gzip, deflate, br"},
#     {"accept-language", "en-GB,en-US;q=0.9,en;q=0.8"},
#     {"connection", "keep-alive"},
#     {"host", "localhost:4000"},
#     {"sec-ch-ua",
#      "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"101\", \"Google Chrome\";v=\"101\""},
#     {"sec-ch-ua-mobile", "?0"},
#     {"sec-ch-ua-platform", "\"macOS\""},
#     {"sec-fetch-dest", "document"},
#     {"sec-fetch-mode", "navigate"},
#     {"sec-fetch-site", "none"},
#     {"sec-fetch-user", "?1"},
#     {"upgrade-insecure-requests", "1"},
#     {"user-agent",
#      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36"}
#   ],
#   request_path: "/",
#   resp_body: nil,
#   resp_cookies: %{},
#   resp_headers: [
#     {"cache-control", "max-age=0, private, must-revalidate"},
#     {"x-request-id", "FvGvUR7nhcBtJ3cAAAFk"},
#     {"x-frame-options", "SAMEORIGIN"},
#     {"x-xss-protection", "1; mode=block"},
#     {"x-content-type-options", "nosniff"},
#     {"x-download-options", "noopen"},
#     {"x-permitted-cross-domain-policies", "none"},
#     {"cross-origin-window-policy", "deny"}
#   ],
#   scheme: :http,
#   script_name: [],
#   secret_key_base: :...,
#   state: :unset,
#   status: nil
# }
