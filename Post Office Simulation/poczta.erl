-module(poczta).
-author("Adam Buczek").
-export([main/1]).
-compile(export_all).
-define(HOUR, 15000).
-define(BREAK, 1000).
-define(MINUTE, 250).




okienko(Ppid, Nr, Epid) ->
    receive
        {obsluguj,{Numer,H,_}} -> Epid!{printxy,27,Nr*3, string:concat("Obsluguje czas - ", lists:flatten(io_lib:format("~p min. Numer klienta: ~p", [H/?MINUTE,Numer])))}, 
                                  timer:sleep(H),
                                  Ppid!{okienko,self(),Nr},
                                  okienko(Ppid,Nr, Epid);
        
        {przerwa} ->              Epid!{printxy,27,Nr*3, "Przerwa"},
                                  timer:sleep(?HOUR), 
                                  Ppid!{okienko, self(),Nr}, 
                                  okienko(Ppid,Nr, Epid);
        
        {zamkniete} ->            Epid!{printxy,27,Nr*3, "Zamkniete"},
                                  timer:sleep(?BREAK),
                                  Ppid!{okienko, self(),Nr},
                                  okienko(Ppid,Nr, Epid);

        {chwilowo} ->             Epid!{printxy,27,Nr*3, "Chwilowo zamkniete z powodu malej ilosci klientow"},
                                  timer:sleep(?BREAK), 
                                  Ppid!{okienko, self(),Nr}, 
                                  okienko(Ppid,Nr, Epid);
        {brak} ->                 Epid!{printxy,27,Nr*3, "Brak klientow"}, 
                                  timer:sleep(?BREAK),
                                  Ppid!{okienko, self(),Nr},
                                  okienko(Ppid,Nr, Epid)
    end.


controller(Godzina,[],[], Epid, Spid) ->
    receive
        {godzina,Hour} ->    controller(Hour,[],[], Epid, Spid);
        
        {nowi, L1,L2} ->     if (Godzina >= 16) or (Godzina < 7) -> Epid!{printxy,28,12,"0 0"}, 
                                                                    controller(Godzina,[],[], Epid, Spid);
                                                            true -> Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength(L1),lists:flatlength(L2)]))},
                                                                    controller(Godzina,L1,L2, Epid, Spid)
                             end;
        
        {okienko, Opid,_} -> if (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete},
                                                                    Epid!{printxy,28,12,"0 0"}, 
                                                                    controller(Godzina,[],[], Epid, Spid);
                                                            true -> Opid!{brak}, 
                                                                    Epid!{printxy,28,12,"0 0"}, 
                                                                    controller(Godzina,[],[], Epid, Spid)
                             end
    end;


controller(Godzina,[],[H|T], Epid, Spid) ->
    receive
        {godzina,Hour} ->    controller(Hour,[],[H|T], Epid, Spid);
        
        {nowi, L1, L2} ->    if (Godzina >= 16) or (Godzina < 7) -> Epid!{printxy,28,12,"0 0"},
                                                                    controller(Godzina,[],[], Epid, Spid);
                                                            true -> Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength(L1),lists:flatlength(L2)]))},
                                                                    controller(Godzina,L1,[H|T]++L2, Epid, Spid)
                             end;
        
        {okienko, Opid,1} -> if (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete},
                                                                    Epid!{printxy,28,12,"0 0"}, 
                                                                    controller(Godzina,[],[], Epid, Spid);
                                                            true -> Opid!{brak}, 
                                                                    Epid!{printxy,28,12,lists:flatten(io_lib:format("0 ~p", [lists:flatlength([H|T])]))}, 
                                                                    controller(Godzina,[],[H|T], Epid, Spid)
                             end;
		
        {okienko, Opid,2} -> Length = lists:flatlength([H|T]),
                             if Godzina =:= 13 -> Opid!{przerwa}, 
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("0 ~p", [lists:flatlength([H|T])]))},
                                                  controller(Godzina,[],[H|T], Epid, Spid);
              (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete}, 
                                                  Epid!{printxy,28,12,"0 0"}, 
                                                  controller(Godzina,[],[], Epid, Spid);
                                   Length < 10 -> Opid!{chwilowo}, 
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("0 ~p", [lists:flatlength([H|T])]))}, 
                                                  controller(Godzina,[],[H|T], Epid, Spid);
                                          true -> Spid!{ilosc}, 
                                                  Opid!{obsluguj,H}, 
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("0 ~p", [lists:flatlength([T])]))},
                                                  controller(Godzina,[],T, Epid, Spid)
                             end;

		{okienko, Opid,3} -> Length = lists:flatlength([H|T]),
                             if Godzina =:= 14 -> Opid!{przerwa}, 
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("0 ~p", [lists:flatlength([H|T])]))}, 
                                                  controller(Godzina,[],[H|T], Epid, Spid);
              (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete},
                                                  Epid!{printxy,28,12,"0 0"}, 
                                                  controller(Godzina,[],[], Epid, Spid);
                                    Length < 1 -> Opid!{brak}, 
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("0 ~p", [lists:flatlength([H|T])]))},
                                                  controller(Godzina,[],[H|T], Epid, Spid);
                                          true -> Spid!{ilosc}, 
                                                  Opid!{obsluguj,H}, 
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("0 ~p", [lists:flatlength([T])]))}, 
                                                  controller(Godzina,[],T, Epid, Spid)
                             end
    end;

controller(Godzina,[H|T],[], Epid, Spid) ->
    receive
        {godzina,Hour} ->    controller(Hour, [H|T], [], Epid, Spid);
        
        {nowi, L1, L2} ->    if (Godzina >= 16) or (Godzina < 7) -> Epid!{printxy,28,12,"0 0"}, 
                                                                    controller(Godzina,[],[], Epid, Spid);
                                                            true -> Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength(L1),lists:flatlength(L2)]))}, 
                                                                    controller(Godzina,[H|T]++L1,L2, Epid, Spid)
                             end;
        
        {okienko, Opid,2} -> if (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete}, 
                                                                    Epid!{printxy,28,12,"0 0"}, 
                                                                    controller(Godzina,[],[], Epid, Spid);
                                                            true -> Opid!{brak}, 
                                                                    Epid!{printxy,28,12,lists:flatten(io_lib:format("~p 0", [lists:flatlength([H|T])]))}, 
                                                                    controller(Godzina,[H|T],[], Epid, Spid)
                            end;
		
        {okienko, Opid,1} -> Length = lists:flatlength([H|T]),
                             if Godzina =:= 12 -> Opid!{przerwa},
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("~p 0", [lists:flatlength([H|T])]))}, 
                                                  controller(Godzina,[H|T],[], Epid, Spid);
              (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete}, Epid!{printxy,28,12,"0"}, 
                                                  controller(Godzina,[],[], Epid, Spid);
                                   Length < 10 -> Opid!{chwilowo}, 
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("~p 0", [lists:flatlength([H|T])]))}, 
                                                  controller(Godzina,[H|T],[], Epid, Spid);
                                          true -> Spid!{ilosc},
                                                  Opid!{obsluguj,H},
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("~p 0", [lists:flatlength([T])]))},
                                                  controller(Godzina,T,[], Epid, Spid)
                             end;

		{okienko, Opid,3} -> Length = lists:flatlength([H|T]),
                             if Godzina =:= 14 -> Opid!{przerwa},
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("~p 0", [lists:flatlength([H|T])]))}, 
                                                  controller(Godzina,[H|T],[], Epid, Spid);
              (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete}, 
                                                  Epid!{printxy,28,12,"0 0"},
                                                  controller(Godzina,[],[], Epid, Spid);
                                    Length < 1 -> Opid!{brak}, 
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("~p 0", [lists:flatlength([H|T])]))},
                                                  controller(Godzina,[H|T],[], Epid, Spid);
                                          true -> Spid!{ilosc}, 
                                                  Opid!{obsluguj,H},
                                                  Epid!{printxy,28,12,lists:flatten(io_lib:format("~p 0", [lists:flatlength([T])]))}, 
                                                  controller(Godzina,T,[], Epid, Spid)
                             end
    end;

controller(Godzina,[{N1,C1,R1}|T1],[{N2,C2,R2}|T2], Epid, Spid) ->
    receive
        {godzina,Hour} ->     controller(Hour,[{N1,C1,R1}|T1],[{N2,C2,R2}|T2], Epid, Spid);
        
        {nowi, L1,L2} ->      controller(Godzina,[{N1,C1,R1}|T1]++L1,[{N2,C2,R2}|T2]++L2, Epid, Spid);
        
        {okienko, Opid, 1} -> Length = lists:flatlength([{N1,C1,R1}|T1]),
                              if Godzina =:= 12 -> Opid!{przerwa}, 
                                                   Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([{N1,C1,R1}|T1]),lists:flatlength([{N2,C2,R2}|T2])]))},
                                                   controller(Godzina,[{N1,C1,R1}|T1],[{N2,C2,R2}|T2], Epid, Spid);
               (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete},
                                                   Epid!{printxy,28,12,"0 0"}, 
                                                   controller(Godzina,[],[], Epid, Spid);
                                    Length < 10 -> Opid!{chwilowo}, 
                                                   Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([{N1,C1,R1}|T1]),lists:flatlength([{N2,C2,R2}|T2])]))}, 
                                                   controller(Godzina,[{N1,C1,R1}|T1],[{N2,C2,R2}|T2], Epid, Spid);
                                           true -> Spid!{ilosc},
                                                   Opid!{obsluguj,{N1,C1,R1}}, 
                                                   Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([T1]),lists:flatlength([{N2,C2,R2}|T2])]))},
                                                   controller(Godzina,T1,[{N2,C2,R2}|T2], Epid, Spid)
                              end;

        {okienko, Opid, 2} -> Length = lists:flatlength([{N2,C2,R2}|T2]),
                              if Godzina =:= 13 -> Opid!{przerwa}, 
                                                   Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([{N1,C1,R1}|T1]),lists:flatlength([{N2,C2,R2}|T2])]))}, 
                                                   controller(Godzina,[{N1,C1,R1}|T1],[{N2,C2,R2}|T2], Epid, Spid);
               (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete}, 
                                                   Epid!{printxy,28,12,"0 0"}, 
                                                   controller(Godzina,[],[], Epid, Spid);
                                    Length < 10 -> Opid!{chwilowo}, 
                                                   Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([{N1,C1,R1}|T1]),lists:flatlength([{N2,C2,R2}|T2])]))}, 
                                                   controller(Godzina,[{N1,C1,R1}|T1],[{N2,C2,R2}|T2], Epid, Spid);
                                           true -> Spid!{ilosc},
                                                   Opid!{obsluguj,{N2,C2,R2}}, 
                                                   Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([T2]),lists:flatlength([{N1,C1,R1}|T1])]))}, 
                                                   controller(Godzina,[{N1,C1,R1}|T1],T2, Epid, Spid)
                              end;

        {okienko, Opid, 3} -> if N1 < N2 -> if Godzina =:= 14 -> Opid!{przerwa}, 
                                                                 Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([{N1,C1,R1}|T1]),lists:flatlength([{N2,C2,R2}|T2])]))}, 
                                                                 controller(Godzina,[{N1,C1,R1}|T1],[{N2,C2,R2}|T2], Epid, Spid);
                             (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete}, 
                                                                 Epid!{printxy,28,12,"0 0"}, controller(Godzina,[],[], Epid, Spid);
                                                         true -> Spid!{ilosc}, 
                                                                 Opid!{obsluguj,{N1,C1,R1}},
                                                                 Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([T1]),lists:flatlength([{N2,C2,R2}|T2])]))}, 
                                                                 controller(Godzina,T1,[{N2,C2,R2}|T2], Epid, Spid)
                                            end;
							        true -> if Godzina =:= 14 -> Opid!{przerwa}, 
                                                                 Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([{N1,C1,R1}|T1]),lists:flatlength([{N2,C2,R2}|T2])]))}, 
                                                                 controller(Godzina,[{N1,C1,R1}|T1],[{N2,C2,R2}|T2], Epid, Spid);
                             (Godzina >= 16) or (Godzina < 8) -> Opid!{zamkniete}, 
                                                                 Epid!{printxy,28,12,"0 0"}, 
                                                                 controller(Godzina,[],[], Epid, Spid);
                                                         true -> Spid!{ilosc}, 
                                                                 Opid!{obsluguj,{N2,C2,R2}}, 
                                                                 Epid!{printxy,28,12,lists:flatten(io_lib:format("~p ~p", [lists:flatlength([{N1,C1,R1}|T1]),lists:flatlength([T2])]))}, 
                                                                 controller(Godzina,[{N1,C1,R1}|T1],T2, Epid, Spid)
                                            end	
							  end
    end.   



generuj(0,_,L) ->
    L;
generuj(N,Numer,L) -> 
    generuj(N-1,Numer+1,L++[{Numer,(losuj(2)+2)*500,losuj(2)}]).
generuj_liste(N,Numer) ->
    generuj(N,Numer,[]).

podziel(L1,L2,[]) -> 
    {L1,L2}; 
podziel(L1,L2,[{N,Numer,Rodzaj}|T]) ->
	if Rodzaj =:= 1 -> podziel(L1++[{N,Numer,Rodzaj}],L2,T);
		       true -> podziel(L1,L2++[{N,Numer,Rodzaj}],T)
end.

losuj(N) ->
    rand:uniform(N).

generuj_klientow(Ppid, Numer) ->
	receive
	    {zeruj} ->            generuj_klientow(Ppid,1);

        {Godzina, generuj} -> if (Godzina >= 8) and (Godzina < 16) -> L = generuj_liste(losuj(5)+9,Numer),
		                                                              {L1, L2} = podziel([],[],L),
		                                                              Ppid!{nowi,L1,L2},    	
    	                                                              generuj_klientow(Ppid,Numer+lists:flatlength(L));
		                                                      true -> generuj_klientow(Ppid,Numer)
                              end
	end.


zegar(Godzina, Minuta, Ppid, Lpid, Epid,Spid) ->
	Epid!{printxy,17,1, lists:flatten(io_lib:format("~p:~p", [Godzina,Minuta]))},
    timer:sleep(?MINUTE),
	if (Minuta =:= 59) and (Godzina =:= 23) -> Lpid!{zeruj}, 
                                               Ppid!{godzina, Godzina+1}, 
                                               zegar(0,0,Ppid,Lpid, Epid,Spid);
		                    (Minuta =:= 59) -> Spid!{godzina}, 
                                               Lpid!{Godzina+1, generuj}, Ppid!{godzina, Godzina+1}, 
                                               zegar(Godzina+1,0,Ppid,Lpid, Epid,Spid);
			                           true -> Spid!{godzina}, 
                                               zegar(Godzina,Minuta+1,Ppid,Lpid, Epid,Spid)
	end.
    

print({gotoxy,X,Y}) ->
   io:format("\e[~p;~pH",[Y,X]);
print({printxy1,X,Y,Msg}) ->
   io:format("\e[~p;~pH~p",[Y,X,Msg]);
print({printxy,X,Y,Msg}) ->
   io:format("\e[~p;~pH~p",[Y,X,Msg]),
   print({clear_line}); 
print({clear_line}) ->
   io:format("\e[K",[]);
print({clear}) ->
   io:format("\e[2J",[]).
printxy({X,Y,Msg}) ->
   io:format("\e[~p;~pH~p",[Y,X,Msg]).


ekran(Kpid) ->
	receive
		{koniec,X} ->        ekran(X);
		
        {printxy,X,Y,Msg} -> print({printxy,X,Y,Msg}), 
                             print({printxy,1,18,"Wpisz 1 i kliknij enter aby zakonczyc dzialanie symulacji"}), 
                             Kpid!{koniec}, 
                             ekran(Kpid)
	end.

zabij_wszystkich(L,Spid) -> 
    print({clear}),
    Spid!{wypisz},
    zabij(L).


zabij([]) -> 
    ok;
zabij([H|T]) -> 
    exit(H,kill),
    zabij(T).

koniec(L,Spid) ->
	receive
	    {koniec} -> {ok, [X]} = io:fread("A> ", "~d"),
				    if X =:= 1 -> zabij_wszystkich(L++[self()],Spid) ;
					      true -> koniec(L,Spid)
	                end
	end.

statystyki(Godziny, Minuty, Ilosc) ->
	receive	
		{godzina} -> if Minuty =:= 59 -> statystyki(Godziny+1,0,Ilosc);
				                 true -> statystyki(Godziny,Minuty+1,Ilosc)
					 end;
		
        {ilosc} ->   statystyki(Godziny,Minuty,Ilosc+1);
		
        {wypisz} ->  print({printxy,1,2,lists:flatten(io_lib:format("Czas trwania symulacji(czas w programie): ~p godzin, ~p minut.", [Godziny,Minuty]))}), 
					 print({printxy,1,4,lists:flatten(io_lib:format("Ilosc obsluzonych klientow: ~p.", [Ilosc]))}),
					 print({printxy,1,6,""}),
					 exit(self(),kill)
	end.







main(Start) ->
	print({clear}),
	print({printxy1,5,1,"Godzina: "}),
	print({printxy1,5,3,"Okienko 1 wplaty:   "}),
	print({printxy1,5,6,"Okienko 2 paczki:   "}),
	print({printxy1,5,9,"Okienko 3 wszystko: "}),
	print({printxy1,5,12,"Ilosc oczekujacych: "}),
	print({printxy1,5,15,"SYMULACJA OBSLUGI KLIENTOW NA POCZCIE"}),
	{L1,L2} = podziel([],[],generuj_liste(10,1)),
	Spid = spawn(?MODULE, statystyki, [0,0,0]),
	Epid = spawn(?MODULE, ekran, [1]),
    Ppid = spawn(?MODULE, controller, [Start,L1,L2,Epid,Spid]),
    Opid1 = spawn(?MODULE, okienko, [Ppid,1,Epid]),
    Opid2 = spawn(?MODULE, okienko, [Ppid,2,Epid]),
    Opid3 = spawn(?MODULE, okienko, [Ppid,3,Epid]),
	if (Start < 8) or (Start > 15) -> Lpid = spawn(?MODULE, generuj_klientow, [Ppid,1]);
	                          true -> Lpid = spawn(?MODULE, generuj_klientow, [Ppid,11]) 
    end,
    Zpid = spawn(?MODULE, zegar,[Start,0,Ppid,Lpid,Epid,Spid]),
	Lista = [Ppid, Opid1, Opid2, Opid3, Zpid, Lpid, Epid],
	Kpid = spawn(?MODULE, koniec, [Lista,Spid]),
    Epid!{koniec,Kpid},
    Ppid!{okienko,Opid1,1},
    Ppid!{okienko,Opid2,2},
    Ppid!{okienko,Opid3,3},
	print({gotoxy,1,14}).
