%%%-------------------------------------------------------------------
%%% @author Nelson
%%% @copyright (C) 2016, <ISEP>
%%% @doc
%%%
%%% @end
%%% Created : 16. May 2016 8:08 PM
%%%-------------------------------------------------------------------
-module(tsunami).
-author("Nelson").
%% API
-export([start/0,earth_server/1,sensor/0,timerTenMinutesHandler/1,test_sensor/3]).


%%iniciar programa
start() ->
  P = spawn(tsunami, earth_server, [[]]),
  register(earth, P).


%%servidor terrestre
earth_server(ListaSensores) ->
  receive
    {Request, Sensor_pid} ->
      NovaLista = lists:append(ListaSensores, [Sensor_pid]),
      io:format("Sensor ~w lancou alerta: tamanho da onda foi ~w~n",[Sensor_pid, Request]),
      spawn(fun() -> timer(60000,timerTenMinutesHandler(Sensor_pid))end),
      earth_server(NovaLista)

  end.

%%sensores submarinos
sensor() ->
    receive
      {Wave, Limit} ->
        if
          Wave >= Limit ->
            earth ! {Wave, self()},
            sensor();

          Wave < Limit ->
            io:format("Faz nada"),
            sensor()
        end;

    {check, ok, Timer_pid} ->
      Timer_pid ! ok,
      sensor()
    end.

test_sensor(Pid_sensor, Wave, WaveLimit) ->
  Pid_sensor ! {Wave,WaveLimit}.


timer(Time,Fun) ->
  receive
    cancel -> void

    after Time ->
      Fun()
  end.

timerTenMinutesHandler(Pid_sensor) ->

  Pid_sensor ! {check, ok, self()},

  receive
    ok -> io:format("Dispositivo ok!")

  after 10000 ->
    io:format("Dispositivo ~w em mau funcionamento", [Pid_sensor])
  end.




