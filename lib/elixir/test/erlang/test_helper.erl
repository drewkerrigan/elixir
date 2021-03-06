-module(test_helper).
-include("elixir.hrl").
-export([test/0, run_and_remove/2, throw_elixir/1, throw_erlang/1]).

test() ->
  application:start(elixir),
  eunit:test([
    atom_test,
    control_test,
    function_test,
    match_test,
    module_test,
    operators_test,
    string_test,
    tokenizer_test
  ]).

% Execute a piece of code and purge given modules right after
run_and_remove(Fun, Modules) ->
  try
    Fun()
  after
    [code:purge(Module)  || Module <- Modules],
    [code:delete(Module) || Module <- Modules]
  end.

% Throws an error with the Erlang Abstract Form from the Elixir string
throw_elixir(String) ->
  Forms = elixir_translator:'forms!'(String, 1, "nofile", []),
  Tree = elixir_translator:translate(Forms, elixir:scope_for_eval([])),
  erlang:error(io:format("~p~n", [Tree])).

% Throws an error with the Erlang Abstract Form from the Erlang string
throw_erlang(String) ->
  {ok, Tokens, _} = erl_scan:string(String),
  {ok, [Form]} = erl_parse:parse_exprs(Tokens),
  erlang:error(io:format("~p~n", [Form])).
