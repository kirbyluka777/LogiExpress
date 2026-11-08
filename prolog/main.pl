:- use_module(modulo1).
:- use_module(modulo2, []).
:- use_module(modulo3, []).
:- use_module(utils, [leer_entero/2]).

:- initialization(main).
main :-
    (
        cargar_vuelos('../vuelos.txt')
        ->
        writeln('Vuelos cargados correctamente.')
        ;
        writeln('Error: No se pudo cargar vuelos.txt.')
    ),
    repeat,
    nl,
    writeln('====== LOGIEXPRESS - CONTROL DE VUELOS ======'),
    writeln('1. Modulo 1'),
    writeln('2. Modulo 2'),
    writeln('3. Modulo 3'),
    writeln('0. Salir'),

        leer_entero('Seleccione una opcion: ', Sel),
    (
        Sel = 0
        ->
        writeln('Termiando aplicacion...'),
        !
        ;
        once(seleccion(Sel)),
        fail
    ).

seleccion(1) :-
    modulo1:menu.

seleccion(2) :-
    modulo2:menu.

seleccion(3) :-
    modulo3:menu.

seleccion(0) :-
    writeln('Terminando programa...').

seleccion(_) :-
    writeln('Opcion invalida.').