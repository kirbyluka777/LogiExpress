:- module(modulo1, [menu/0]).
:- use_module(utils).

:- dynamic vuelo/7.
:- dynamic tmc/1.

% los pasajerois esperan minimo 45 min entre la llegada de un vuelo y la salida otro
tmc(45).

cargar_vuelos(Archivo) :-
    retractall(vuelo(_,_,_,_,_,_,_)),
    open(Archivo, read, Flujo),
    leer_vuelos(Flujo),
    close(Flujo).

leer_vuelos(Flujo) :-
    read_line_to_string(Flujo, Linea),
    (
        Linea == end_of_file
        ->
        true
        ;
        (
            Linea \= "",
            parsear_vuelo(Linea)
            ->
            leer_vuelos(Flujo)
            ;
            leer_vuelos(Flujo)
        )
    ).

parsear_vuelo(Linea) :-
    split_string(Linea, "|", "", Campos),
    Campos = [
        Origen,
        Destino,
        Salida,
        Llegada,
        CostoTexto,
        Codigo,
        Dias
    ],
    number_string(Costo, CostoTexto),
    assertz(vuelo(
        Origen,
        Destino,
        Salida,
        Llegada,
        Costo,
        Codigo,
        Dias
    )).

configurar_tmc(Minutos) :-
    number(Minutos),
    Minutos >= 0,
    retractall(tmc(_)),
    assertz(tmc(Minutos)).


% Dada una ciudad C, generar la lista de todos los vuelos que salen de ella

vuelos_salida(Ciudad, Lista) :-
    findall(
        vuelo(O,D,S,L,C,Cod,Dia),
        (
            vuelo(O,D,S,L,C,Cod,Dia),
            ciudad_igual(O, Ciudad)
        ),
        Lista
    ).

% Dada una ciudad C, generar la lista de todos los vuelos que llegan a ella

vuelos_llegada(Ciudad, Lista) :-
    findall(
        vuelo(O,D,S,L,C,Cod,Dia),
        (
            vuelo(O,D,S,L,C,Cod,Dia),
            ciudad_igual(D, Ciudad)
        ),
        Lista
    ).

    

mostrar_vuelos([]).

mostrar_vuelos([
    vuelo(O,D,S,L,C,Cod,Dia)|Resto
]) :-
    format(
        '~nCodigo: ~w | ~w -> ~w | Salida: ~w | Llegada: ~w | Costo: ~w | Dias: ~w',
        [Cod,O,D,S,L,C,Dia]
    ),
    mostrar_vuelos(Resto).



%cli
% MENU INTERACTIVO

menu :-
    (
        cargar_vuelos('../vuelos.txt')
        ->
        writeln('Vuelos cargados correctamente.')
        ;
        writeln('Error: No se pudo cargar vuelos.txt.')
    ),
    repeat,
    nl,
    writeln('====== MODULO 1 ======'),
    writeln('1. Recargar vuelos'),
    writeln('2. Consultar vuelos de salida'),
    writeln('3. Consultar vuelos de llegada'),
    writeln('4. Configurar TMC'),
    writeln('0. Volver'),
    leer_entero('Seleccione una opcion: ', Sel),

    (
        Sel = 0
        ->
        writeln('Volviendo al menu principal...'),
        !
        ;
        once(seleccion(Sel)),
        fail
    ).


% Cargar vuelos

seleccion(1) :-
    cargar_vuelos('../vuelos.txt'),
    writeln('Vuelos cargados correctamente.').


% Consultar vuelos de salida

seleccion(2) :-
    write('Ingrese la ciudad de origen: '),
    flush_output,
    leer_linea(Ciudad),
    vuelos_salida(Ciudad, Lista),
    mostrar_vuelos(Lista),

    (
        Lista = []
        ->
        format('No hay vuelos que salgan de ~s.~n', [Ciudad])
        ;
        mostrar_vuelos(Lista)
    ).


% Consultar vuelos de llegada

seleccion(3) :-
    write('Ingrese la ciudad de destino: '),
    flush_output,
    leer_linea(Ciudad),
    vuelos_llegada(Ciudad, Lista),

    (
        Lista = []
        ->
        format('No hay vuelos que lleguen a ~s.~n', [Ciudad])
        ;
        mostrar_vuelos(Lista)
    ).


% Configurar TMC

seleccion(4) :-
    leer_entero('Ingrese el TMC en minutos: ', Minutos),
    (
        integer(Minutos),
        Minutos >= 0
        ->
        configurar_tmc(Minutos),
        format('TMC configurado en ~w minutos.~n', [Minutos])
        ;
        writeln('Error: introduzca un numero entero mayor o igual a cero.')
    ).


seleccion(0) :-
    writeln('A').

seleccion(_) :-
    writeln('Opcion invalida.').

vuelos_cargados(Lista) :-
    findall(
        vuelo(O,D,S,L,C,Cod,Dia),
        vuelo(O,D,S,L,C,Cod,Dia),
        Lista
    ).