# Stubby
![](https://upload.wikimedia.org/wikipedia/commons/4/44/Sergeant_Stubby.jpg)

Simple, dependable, easy to reason about.

## Why Stubby?
Quick answer: I'm currently working in an Elixir 1.3 app and [Mox only supports 1.5](https://github.com/plataformatec/mox/issues/25)😆  

Long answer: After realizing I couldn't use Mox, I came up with a fairly simple way to roll my own stubbing solution using ETS. 👍

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `stubby` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stubby, "~> 0.1.0", only: :test}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/stubby](https://hexdocs.pm/stubby).

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



