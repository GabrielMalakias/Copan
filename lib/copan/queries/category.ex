defmodule Copan.Queries.Category do
  @moduledoc """
  Defines some categories queries
  """

  import Ecto.Query, only: [from: 2]

  def all(id) do
    Copan.Repo.all(Copan.Schema.Category, prefix: id)
  end
end
