defmodule GameplatformWeb.AuthControllerTest do
  use GameplatformWeb.ConnCase, async: true

  import Mox

  setup :verify_on_exit!

  describe "test for getOtp request" do
    setup %{conn: conn} do
      path = Routes.auth_path(conn, :get_otp)
      phone = get_random_mobile_no()
      {:ok, %{path: path, phone: phone}}
    end

    test "request fails on missing content-type header", %{conn: conn, path: path} do
      assert json_response =
               conn
               |> post(path)
               |> json_response(422)

      errors = get_errors(json_response)
      assert errors["detail"] == "Missing header: content-type"
    end

    test "request fails due to missing body_params", %{conn: conn, path: path, phone: phone} do
      body_params = %{"phone_number" => phone}

      assert json_response = send_request(conn, path, 422, body_params)

      errors = get_errors(json_response)
      assert errors["detail"] == "Missing field: country_code"
    end

    test "request fails due to invalid body_params", %{conn: conn, path: path, phone: phone} do
      body_params = %{"phone_number" => phone, "country_code" => "+910"}

      assert json_response = send_request(conn, path, 422, body_params)

      errors = get_errors(json_response)
      assert errors["detail"] == "Invalid format. Expected ~r/\\+91{1}$/"
    end

    test "request fails on error returned from Twilio client of invalid phone", %{
      conn: conn,
      path: path,
      phone: phone
    } do
      body_params = %{"phone_number" => phone, "country_code" => "+91"}

      expect(TwilioClientMock, :send_sms, 1, fn _, _ -> {:error, :invalid_phone} end)

      send_request(conn, path, 400, body_params)
    end

    test "requests succeeds for sending otp to user", %{conn: conn, path: path, phone: phone} do
      body_params = %{"phone_number" => phone, "country_code" => "+91"}

      expect(TwilioClientMock, :send_sms, 1, fn _, _ -> {:ok, %{"some_key" => "some_value"}} end)

      send_request(conn, path, 200, body_params)
    end
  end

  describe "tests for submit otp" do
    setup %{conn: conn} do
      path = Routes.auth_path(conn, :submit_otp)
      phone = get_random_mobile_no()
      {:ok, %{path: path, phone: phone}}
    end

    test "request fails on missing content-type header", %{conn: conn, path: path} do
      assert json_response =
               conn
               |> post(path)
               |> json_response(422)

      errors = get_errors(json_response)
      assert errors["detail"] == "Missing header: content-type"
    end

    test "request fails due to missing body_params", %{conn: conn, path: path, phone: phone} do
      body_params = %{"phone_number" => phone, "country_code" => "+91"}

      assert json_response = send_request(conn, path, 422, body_params)

      errors = get_errors(json_response)
      assert errors["detail"] == "Missing field: otp"
    end

    test "request fails due to invalid body_params", %{conn: conn, path: path, phone: phone} do
      body_params = %{"phone_number" => phone, "country_code" => "+91", "otp" => 12345}

      assert json_response = send_request(conn, path, 422, body_params)

      errors = get_errors(json_response)
      assert errors["detail"] == "Invalid string. Got: integer"
    end

    test "request fails on submiting expired otp", %{conn: conn, path: path, phone: phone} do
      body_params = %{"phone_number" => phone, "country_code" => "+91", "otp" => "123456"}

      assert json_response = send_request(conn, path, 400, body_params)

      assert json_response["errors"] == "OTP Expired try sending a new one"
    end

    test "request fails on submiting invalid otp", %{conn: conn, path: submit_path, phone: phone} do
      get_body_params = %{"phone_number" => phone, "country_code" => "+91"}
      get_path = Routes.auth_path(conn, :get_otp)

      expect(TwilioClientMock, :send_sms, 1, fn _phone_number, _message_body ->
        {:ok, %{"some_key" => "some_value"}}
      end)

      send_request(conn, get_path, 200, get_body_params)

      submit_body_params = %{"phone_number" => phone, "country_code" => "+91", "otp" => "123456"}

      assert json_response = send_request(conn, submit_path, 400, submit_body_params)

      assert json_response["errors"] == "Invalid OTP try again"
    end

    test "request finally succeeds on submitting correct otp", %{
      conn: conn,
      path: submit_path,
      phone: phone
    } do
      get_body_params = %{"phone_number" => phone, "country_code" => "+91"}
      get_path = Routes.auth_path(conn, :get_otp)

      expect(TwilioClientMock, :send_sms, 1, fn _phone_number, message_body ->
        [_, otp] = String.split(message_body, "is ")
        {:ok, %{"otp" => otp}}
      end)

      json_response = send_request(conn, get_path, 200, get_body_params)

      otp = json_response["otp"]

      submit_body_params = %{"phone_number" => phone, "country_code" => "+91", "otp" => otp}

      assert token_cookie =
               conn
               |> put_req_header("content-type", "application/json")
               |> post(submit_path, submit_body_params)
               |> get_cookie_from_conn("_gameplatform_web_user_token")

      assert token_cookie != nil
    end
  end

  describe "tests for logout user" do
    setup _ do
      phone = get_random_mobile_no()
      {:ok, %{phone: phone}}
    end

    test "request successfully deletes the cookie", %{conn: conn, phone: phone} do
      get_body_params = %{"phone_number" => phone, "country_code" => "+91"}
      get_path = Routes.auth_path(conn, :get_otp)

      expect(TwilioClientMock, :send_sms, 1, fn _phone_number, message_body ->
        [_, otp] = String.split(message_body, "is ")
        {:ok, %{"otp" => otp}}
      end)

      json_response = send_request(conn, get_path, 200, get_body_params)

      otp = json_response["otp"]

      submit_path = Routes.auth_path(conn, :submit_otp)
      submit_body_params = %{"phone_number" => phone, "country_code" => "+91", "otp" => otp}

      assert resp_conn =
               conn
               |> put_req_header("content-type", "application/json")
               |> post(submit_path, submit_body_params)

      token_cookie = get_cookie_from_conn(resp_conn, "_gameplatform_web_user_token")

      assert token_cookie != nil

      logout_path = Routes.auth_path(conn, :log_out)

      token_cookie =
        conn
        |> put_req_header("content-type", "application/json")
        |> put_req_cookie("_gameplatform_web_user_token", token_cookie)
        |> post(logout_path)
        |> get_cookie_from_conn("_gameplatform_web_user_token")

      assert token_cookie == nil
    end
  end

  defp get_random_mobile_no() do
    DateTime.utc_now()
    |> :erlang.phash2(900_000_000)
    |> Kernel.+(9_000_000_000)
    |> to_string()
  end

  def send_request(conn, path, status_code, body \\ []) do
    assert conn
           |> put_req_header("content-type", "application/json")
           |> post(path, body)
           |> json_response(status_code)
  end

  def get_cookie_from_conn(%{cookies: cookies} = _conn, key) do
    Map.get(cookies, key)
  end

  defp get_errors(json) do
    hd(json["errors"])
  end
end
