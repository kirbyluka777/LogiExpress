:- use_module(modulo1).
:- use_module(modulo2, []).
:- use_module(modulo3).

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
    write('Seleccione una opcion: '),
    flush_output,

    leer_opcion(Sel),
    seleccion(Sel),

    Sel = 0,
    !.

leer_opcion(Opcion) :-
    read_line_to_string(user_input, Linea),
    (
        Linea == end_of_file
        ->
        Opcion = 0
        ;
        normalize_space(string(Texto), Linea),
        (
            catch(number_string(Numero, Texto), _, fail),
            integer(Numero)
            ->
            Opcion = Numero
            ;
            Opcion = invalida
        )
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