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

## Why Not Something Else?
I think constraints are a good thing when it comes to design (so long as you understand how constraints can impact design and meet your needs for your intended design). That said, limiting stubby to stubbing only imposes a set of constraints.  

If you're looking for more or think this isn't for you, checkout [mox](https://github.com/plataformatec/mox).

## Some recommendations
Keep in mind that, when stubbing (and mocking), you're replacing the real implementation with a fake implementation. That said, it's best to ensure that you still have a good testing strategy in place to run your tests against codepaths that traverse the entire system using real implentations. These need not be the bulk of your tests and don't necessarilly have to be run as frequent as your other tests, but do not neglect these tests.
It's all about finding a balance and understanding the what, why, and how your testing what you're testing.

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

or inject collaborating modules:

```elixir
defmodule MyApp.AwesomeContext do

  def get_all_the_awesome(query, api \\ MyApp.RealApi) do
    api.get(query)
    |> some_other_stuff(:that_is_awesome)
  end
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

```elixir
defmodule MyApp.AwesomeContextTest do
  use ExUnit.Case
  alias MyApp.AwesomeContext
  
  setup do
    # Call setup prior to stubbing
    StubApi.setup
    :ok
  end
  
  test "a failing API call" do
    # Stub away!
    StubApi.stub(:all, fn -> {:error, "¯\_(ツ)_/¯"} end)
    
    assert {:error, "👎" } = AwesomeContext.get_all_the_awesome("👍", StubApi)
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


## License
Copyright 2017 Dave Shah

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.



