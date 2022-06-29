defmodule Gameplatform.Ecto.ChangesetErrorTranslator do
  @moduledoc """

  the purpose of the module is translate the error returned by changeset
  in better format.

  Incoming format :
  ```
    #Ecto.Changeset<
     action: :insert,
     changes: %{phone_number: "1234567890"},
     errors: [country_code: {"can't be blank", [validation: :required]}],
     data: #Gameplatform.Accounts.Schema.User<>,
     valid?: false
    >}

    #Ecto.Changeset<
     action: :insert,
     changes: %{},
     errors: [
      country_code: {"can't be blank", [validation: :required]},
      phone_number: {"is invalid", [type: :string, validation: :cast]}
     ],
    data: #Gameplatform.Accounts.Schema.User<>,
    valid?: false
    >

  ```

  Output format:
  ```
    %{country_code: ["can't be blank"], phone_number: ["is invalid"]}
  ```
  """

  alias Ecto.Changeset

  @spec translate_error(Ecto.Changeset.t()) :: map()
  def translate_error(changeset) do
    Changeset.traverse_errors(changeset, &convert_error/1)
  end

  def convert_error({msg, opts}) do
    case opts[:count] do
      nil -> Gettext.dgettext(Gameplatform.Gettext, "errors", msg, opts)
      count -> Gettext.dngettext(Gameplatform.Gettext, "errors", msg, msg, count, opts)
    end
  end
end
