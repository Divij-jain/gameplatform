{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Gameplatform.Repo, :manual)

Mox.defmock(TwilioClientMock, for: Gameplatform.Client.TwilioClient)

Mimic.copy(Gameplatform.Users.UserSupervisor)
Mimic.copy(Gameplatform.Auth.Token.TokenClient)
