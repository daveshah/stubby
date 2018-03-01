![](https://travis-ci.org/daveshah/stubby.svg?branch=master)

# Stubby
![](https://upload.wikimedia.org/wikipedia/commons/4/44/Sergeant_Stubby.jpg)

Simple, dependable, easy to reason about.

## Why Stubby?
Quick answer: I'm currently working in an Elixir 1.3 app and [Mox only supports 1.5](https://github.com/plataformatec/mox/issues/25)😆  

Long answer: When I'm in a functional language (like Elixir), I prefer stubs over mocks. 
I think sometimes people get these terms confused. I've seen people scratch their head when I've mentioned stubs, mocks, spy's, and why I prefer one over the other in some cases. If you're not familiar with the difference, check out [Martin Fowler's article - Mock's aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html)

I was happy when José Valim posted his opinions on [Mocks and Explicit Contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/) and liked the approach he showed with the controller, injecting the controllers dependency on the twitter API. This sets up a nice boundary and helps in thinking about de-coupling concerns and allows one to test the controller and api independently. In the example José has, he's able to test out the happy path by injecting a stub module during tests. The problem here is that, this only covers the happy path. What if calling this module yields an error, or there are additional cases from the output of the function that the controller should account for.

This is where stubbing (and Stubby) helps :)


## Installation

Stubby is on Hex so just add Stubby to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stubby, "~> 0.1.0", only: :test}
  ]
end
```

# Usage
If you haven't yet, please read [Mocks and Explicit Contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/)

Using Stubby follows similiar patterns found in this post.

### Start by defining an [Elixir Behaviour](https://elixir-lang.org/getting-started/typespecs-and-behaviours.html)
```elixir
# Both your 'real' API and Stub API will implement this behaviour.
defmodule Api do
  @callback all() :: {:ok, term} | {:error, String.t}
  @callback get(term) :: {:ok, term} | {:error, String.t}
  ...
end
```

### Use Stubby within a stub module, specifying which Behaviours you intend on stubbing
```elixir
# This stub API can be set in your config/test.exs
defmodule MyApp.StubApi do
  use Stubby, for: [Api] 
  # NOTE: Multiple behaviours can be used with `use Stubby, for: [Behaviour1, Behaviour2, ...]`
end

# This is the API module that will be set in config/prod.exs
defmodule MyApp.RealApi do
  @behaviour Api
  ...
end
```

### Inject your controller
```elixir
# In config/test.exs
config :my_app, :api, MyApp.StubApi

# In config/prod.exs
config :my_app, :api, MyApp.RealApi

```

```elixir
defmodule MyAppWeb.MyController do
  use MyAppWeb :controller
  
  # 'Inject' your API behaviour 
  @api Application.get_env(:my_app, :api)
  
  ...
end
```

### Test with Stubby!
```elixir
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
Once you call `setup/0` on your Stub module, Stubby will generate functions that match the name and arity of what you've defined in your behaviours. You can stub out these functions by by calling `stub/2`.

The `stub/2` function takes, as its first argument a name of the function you're stubbing and as it's second argument, an anonymous stub function. 
**Note: Please ensure the stub function you pass matches the arity of the function you're stubbing**
As an example, if I were stubbing a `get/1` function, this would look something like this:
```elixir
StubApi.stub(:get, fn _unused -> "some output" end)
```



