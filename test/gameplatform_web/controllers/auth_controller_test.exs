defmodule GameplatformWeb.AuthControllerTest do
  use GameplatformWeb.ConnCase, async: true

  import Mox

  setup :verify_on_exit!

  describe "test for getOtp request" do
    setup %{conn: conn} do
      path = Routes.auth_path(conn, :get_otp)
      {:ok, %{path: path}}
    end

    test "request fails on missing content-type header", %{conn: conn, path: path} do
      assert json_response =
               conn
               |> post(path)
               |> json_response(422)

      errors = get_errors(json_response)
      assert errors["detail"] == "Missing header: content-type"
    end

    test "request fails due to missing body_params", %{conn: conn, path: path} do
      body_params = %{"phone_number" => "123456789"}

      assert json_response =
               conn
               |> put_req_header("content-type", "application/json")
               |> post(path, body_params)
               |> json_response(422)

      errors = get_errors(json_response)
      assert errors["detail"] == "Missing field: country_code"
    end

    test "request fails due to invalid body_params", %{conn: conn, path: path} do
      body_params = %{"phone_number" => "1234567890", "country_code" => "+910"}

      assert json_response =
               conn
               |> put_req_header("content-type", "application/json")
               |> post(path, body_params)
               |> json_response(422)

      errors = get_errors(json_response)
      assert errors["detail"] == "Invalid format. Expected ~r/\\+91{1}$/"
    end

    test "request fails on error returned from Twilio client of invalid phone", %{
      conn: conn,
      path: path
    } do
      body_params = %{"phone_number" => "1234567890", "country_code" => "+91"}

      expect(TwilioClientMock, :send_sms, fn _, _ -> {:error, :invalid_phone} end)

      conn
      |> put_req_header("content-type", "application/json")
      |> post(path, body_params)
      |> json_response(400)
    end

    test "requests succeeds for sending otp to user", %{conn: conn, path: path} do
      body_params = %{"phone_number" => "1234567890", "country_code" => "+91"}

      expect(TwilioClientMock, :send_sms, fn _, _ -> {:ok, %{"some_key" => "some_value"}} end)

      conn
      |> put_req_header("content-type", "application/json")
      |> post(path, body_params)
      |> json_response(200)
    end
  end

  defp get_errors(json) do
    hd(json["errors"])
  end
end
