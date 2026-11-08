:- module(modulo3, [menu/0]).
:- use_module(utils).
:- use_module(modulo2, []).

% Calculo de Costo
costo_ruta([], 0).
costo_ruta([vuelo(_,_,_,_,Costo,_,_)|Resto], Total) :-
    costo_ruta(Resto, SubTotal),
    Total is SubTotal + Costo.

% Calculo de Tiempo
tiempo_ruta(Ruta, Tiempo) :-
    Ruta = [PrimerVuelo|_],
    last(Ruta, UltimoVuelo),
    PrimerVuelo = vuelo(_,_,Salida,_,_,_,_),
    UltimoVuelo = vuelo(_,_,_,Llegada,_,_,_),
    hora_a_minutos(Salida, MinSalida),
    hora_a_minutos(Llegada, MinLlegada),
    (MinLlegada >= MinSalida ->
        Tiempo is MinLlegada - MinSalida
    ;
        Tiempo is MinLlegada + 1440 - MinSalida).

% QuickSort
quicksort(_, [], []).
quicksort(Criterio, [Pivote|Resto], Ordenada) :-
    valor_criterio(Criterio, Pivote, ValorPivote),
    partir(Criterio, ValorPivote, Resto, Menores, Mayores),
    quicksort(Criterio, Menores, MenoresOrd),
    quicksort(Criterio, Mayores, MayoresOrd),
    append(MenoresOrd, [Pivote|MayoresOrd], Ordenada).

% Particion
partir(_, _, [], [], []).
partir(Criterio, ValorPivote, [H|T], Menores, Mayores) :-
    valor_criterio(Criterio, H, Valor),
    (Valor =< ValorPivote ->
        Menores = [H|RestoMenores],
        Mayores = RestoMayores
    ;
        Menores = RestoMenores,
        Mayores = [H|RestoMayores]
    ),
    partir(Criterio, ValorPivote, T, RestoMenores, RestoMayores).

% Valor usado para comparar cada ruta.
valor_criterio(costo, Ruta, Valor) :-
    costo_ruta(Ruta, Valor).

valor_criterio(tiempo, Ruta, Valor) :-
    tiempo_ruta(Ruta, Valor).

% Se conservan estos nombres para mantener la interfaz anterior.
quicksort_costo(Lista, Ordenada) :-
    quicksort(costo, Lista, Ordenada).

quicksort_tiempo(Lista, Ordenada) :-
    quicksort(tiempo, Lista, Ordenada).

menu :-
    writeln('\n====== MODULO 3: OPTIMIZACION ======'),
    writeln('1. Ruta mas economica'),
    writeln('2. Ruta mas rapida'),
    writeln('3. Reporte ordenado por Costo'),
    writeln('4. Reporte ordenado por Tiempo'),
    writeln('0. Volver al menu principal'),
    leer_entero('Seleccione una opcion: ', Sel),
    seleccion(Sel).

seleccion(0) :-
    writeln('Volviendo al menu principal...').

% Opciones válidas (1 a 4): Pide datos, calcula y vuelve a mostrar el menú de Módulo 3
seleccion(Sel) :-
    member(Sel, [1, 2, 3, 4]),
    !,
    write('Ciudad de origen: '), flush_output, leer_linea(Origen),
    write('Ciudad de destino: '), flush_output, leer_linea(Destino),
    write('Dia de viaje: '), flush_output, leer_linea(Dia),
    
    % Reutiliza modulo 2 para obtener las rutas validas
    modulo2:rutas_validas(Origen, Destino, Dia, ilimitadas, Rutas),
    
    ( Rutas == [] ->
        writeln('No hay rutas validas para optimizar.')
    ;
        ejecutar_optimizacion(Sel, Rutas)
    ),
    nl,
    menu.

% Opción inválida: Muestra error y vuelve a mostrar el menú
seleccion(_) :-
    writeln('Opcion invalida.'),
    nl,
    menu.

% Ejecuta el ordenamiento una sola vez, segun la opcion elegida.
ejecutar_optimizacion(Opcion, Rutas) :-
    criterio_opcion(Opcion, Criterio),
    ordenar_rutas(Criterio, Rutas, Ordenadas),
    mostrar_resultado(Opcion, Ordenadas).

criterio_opcion(1, costo).
criterio_opcion(2, tiempo).
criterio_opcion(3, costo).
criterio_opcion(4, tiempo).

ordenar_rutas(costo, Rutas, Ordenadas) :-
    quicksort_costo(Rutas, Ordenadas).

ordenar_rutas(tiempo, Rutas, Ordenadas) :-
    quicksort_tiempo(Rutas, Ordenadas).

mostrar_resultado(1, [MasEconomica|_]) :-
    costo_ruta(MasEconomica, Costo),
    mostrar_ruta_optima('RUTA MAS ECONOMICA', 'Costo total', Costo, MasEconomica).

mostrar_resultado(2, [MasRapida|_]) :-
    tiempo_ruta(MasRapida, Tiempo),
    minutos_a_hora(Tiempo, TiempoHHMM),
    format(string(Detalle), '~w (~w min)', [TiempoHHMM, Tiempo]),
    mostrar_ruta_optima('RUTA MAS RAPIDA', 'Tiempo total', Detalle, MasRapida).

mostrar_resultado(3, Ordenadas) :-
    writeln('\n--- RUTAS ORDENADAS POR COSTO ---'),
    modulo2:mostrar_lista_rutas(Ordenadas, 1).

mostrar_resultado(4, Ordenadas) :-
    writeln('\n--- RUTAS ORDENADAS POR TIEMPO ---'),
    modulo2:mostrar_lista_rutas(Ordenadas, 1).

% Muestra la ruta destacada sin repetir el formato de salida.
mostrar_ruta_optima(Titulo, Etiqueta, Valor, Ruta) :-
    format('~n--- ~w ---~n', [Titulo]),
    format('~w: ~w~n', [Etiqueta, Valor]),
    modulo2:mostrar_vuelos_ruta(Ruta).