:- module(modulo3, [menu/0]).
:- use_module(utils).
:- use_module(modulo2).

% Calculo de Costo
costo_ruta([], 0).
costo_ruta([vuelo(_,_,_,_,Costo,_,_)|Resto], Total) :-
    costo_ruta(Resto, SubTotal),
    Total is SubTotal + Costo.

% Calculo de Tiempo
% Reutilizamos hora_a_minutos asumiendo formato HH:MM
hora_a_minutos_mod3(Hora, Total) :-
    split_string(Hora, ":", "", [HorasTexto, MinutosTexto]),
    number_string(Horas, HorasTexto),
    number_string(Minutos, MinutosTexto),
    Total is Horas * 60 + Minutos.

tiempo_ruta(Ruta, Tiempo) :-
    Ruta = [PrimerVuelo|_],
    last(Ruta, UltimoVuelo),
    PrimerVuelo = vuelo(_,_,Salida,_,_,_,_),
    UltimoVuelo = vuelo(_,_,_,Llegada,_,_,_),
    hora_a_minutos_mod3(Salida, MinSalida),
    hora_a_minutos_mod3(Llegada, MinLlegada),
    (MinLlegada >= MinSalida -> 
        Tiempo is MinLlegada - MinSalida 
    ; 
        Tiempo is MinLlegada + 1440 - MinSalida).

% QuickSort
quicksort_costo([], []).
quicksort_costo([H|T], Ordenada) :-
    partir_costo(H, T, Menores, Mayores),
    quicksort_costo(Menores, MenoresOrd),
    quicksort_costo(Mayores, MayoresOrd),
    append(MenoresOrd, [H|MayoresOrd], Ordenada).

partir_costo(_, [], [], []).
partir_costo(Pivote, [H|T], [H|Menores], Mayores) :-
    costo_ruta(H, C1), costo_ruta(Pivote, C2), C1 =< C2,
    partir_costo(Pivote, T, Menores, Mayores).
partir_costo(Pivote, [H|T], Menores, [H|Mayores]) :-
    costo_ruta(H, C1), costo_ruta(Pivote, C2), C1 > C2,
    partir_costo(Pivote, T, Menores, Mayores).

quicksort_tiempo([], []).
quicksort_tiempo([H|T], Ordenada) :-
    partir_tiempo(H, T, Menores, Mayores),
    quicksort_tiempo(Menores, MenoresOrd),
    quicksort_tiempo(Mayores, MayoresOrd),
    append(MenoresOrd, [H|MayoresOrd], Ordenada).

partir_tiempo(_, [], [], []).
partir_tiempo(Pivote, [H|T], [H|Menores], Mayores) :-
    tiempo_ruta(H, T1), tiempo_ruta(Pivote, T2), T1 =< T2,
    partir_tiempo(Pivote, T, Menores, Mayores).
partir_tiempo(Pivote, [H|T], Menores, [H|Mayores]) :-
    tiempo_ruta(H, T1), tiempo_ruta(Pivote, T2), T1 > T2,
    partir_tiempo(Pivote, T, Menores, Mayores).

%Menú Modulo 3
menu :-
    writeln('\n====== MODULO 3: OPTIMIZACION ======'),
    write('Ciudad de origen: '), flush_output, leer_linea(Origen),
    write('Ciudad de destino: '), flush_output, leer_linea(Destino),
    write('Dia de viaje: '), flush_output, leer_linea(Dia),
    
    % Reutiliza modulo 2 para obtener las rutas validas
    modulo2:rutas_validas(Origen, Destino, Dia, ilimitadas, Rutas),
    
    ( Rutas == [] ->
        writeln('No hay rutas validas para optimizar.')
    ;
        writeln('1. Ruta mas economica'),
        writeln('2. Ruta mas rapida'),
        writeln('3. Reporte ordenado por Costo'),
        writeln('4. Reporte ordenado por Tiempo'),
        leer_entero('Seleccione una opcion: ', Sel),
        ejecutar_optimizacion(Sel, Rutas)
    ).

ejecutar_optimizacion(1, Rutas) :-
    quicksort_costo(Rutas, [MasEconomica|_]),
    writeln('\n--- RUTA MAS ECONOMICA ---'),
    costo_ruta(MasEconomica, C), format('Costo Total: ~w~n', [C]),
    modulo2:mostrar_vuelos_ruta(MasEconomica).

ejecutar_optimizacion(2, Rutas) :-
    quicksort_tiempo(Rutas, [MasRapida|_]),
    writeln('\n--- RUTA MAS RAPIDA ---'),
    tiempo_ruta(MasRapida, T), format('Tiempo Total (min): ~w~n', [T]),
    modulo2:mostrar_vuelos_ruta(MasRapida).

ejecutar_optimizacion(3, Rutas) :-
    quicksort_costo(Rutas, Ordenadas),
    writeln('\n--- RUTAS ORDENADAS POR COSTO ---'),
    modulo2:mostrar_lista_rutas(Ordenadas, 1).

ejecutar_optimizacion(4, Rutas) :-
    quicksort_tiempo(Rutas, Ordenadas),
    writeln('\n--- RUTAS ORDENADAS POR TIEMPO ---'),
    modulo2:mostrar_lista_rutas(Ordenadas, 1).

ejecutar_optimizacion(_, _) :- writeln('Opcion invalida.').