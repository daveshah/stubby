# Stubby
![](https://upload.wikimedia.org/wikipedia/commons/4/44/Sergeant_Stubby.jpg)

Simple, dependable, easy to reason about.

# Usage
```elixir
# Start by defining your Behaviour
defmodule Api do
  @callback all() :: {:ok, term} | {:error, String.t}
  @callback get(term) :: {:ok, term} | {:error, String.t}
  ...
end

# Use Stubby within a stub module, specifying which Behaviours you intend on stubbing
defmodule StubApi do
  use Stubby, for: [Api]
end

defmodule MyAppWeb.MyController do
  use MyAppWeb :controller
  
  # 'Inject' your API behaviour 
  @api Application.get_env(:my_app, :api)
  
  ...
end

defmodule MyAppWeb.MyControllerTest do
  use MyAppWeb.ConnCase
  
  setup do
    # Call setup prior to stubbing
    StubApi.setup
    :ok
  end
  
  test "a failing API call" do
    # Stub away!
    StubApi.stub(:all, fn -> {:error, "¯\_(ツ)_/¯"} end)
    
    response = get conn, "/"
    
    assert json_response(response, 502)
  end
end

```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `stubby` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stubby, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/stubby](https://hexdocs.pm/stubby).

