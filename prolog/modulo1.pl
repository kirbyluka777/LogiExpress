:- module(modulo1, [menu/0,
    cargar_vuelos/1,
    vuelo/7,
    tmc/1]
    ).
:- use_module(utils).


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
    repeat,
    nl,
    writeln('====== MODULO 1 ======'),
    writeln('1. Consultar vuelos de salida'),
    writeln('2. Consultar vuelos de llegada'),
    writeln('3. Configurar TMC'),
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


% Consultar vuelos de salida

seleccion(1) :-
    write('Ingrese la ciudad de origen: '),
    flush_output,
    leer_linea(Ciudad),
    vuelos_salida(Ciudad, Lista),

    (
        Lista = []
        ->
        format('No hay vuelos que salgan de ~s.~n', [Ciudad])
        ;
        mostrar_vuelos(Lista)
    ).


% Consultar vuelos de llegada

seleccion(2) :-
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

seleccion(3) :-
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