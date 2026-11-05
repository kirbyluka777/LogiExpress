
:- module(utilidades, [
    leer_linea/1,
    leer_entero/2,
    normalizar/2,
    ciudad_igual/2,
    
    cargar_vuelos/1,
    vuelo/7,
    tmc/1,
    configurar_tmc/1,
    vuelos_cargados/1
]).

% Read a line without requiring quotes or a final period
leer_linea(Ciudad) :-
    read_line_to_string(user_input, Linea),
    normalize_space(string(Texto), Linea),
    normalizar(Texto, Ciudad).


% Read an integer without requiring a final period
leer_entero(Prompt, Numero) :-
    write(Prompt),
    flush_output,
    read_line_to_string(user_input, Linea),
    normalize_space(string(Texto), Linea),
    (
        catch(number_string(N, Texto), _, fail),
        integer(N)
        ->
        Numero = N
        ;
        Numero = invalido
    ).


ciudad_igual(Ciudad1, Ciudad2) :-
    normalizar(Ciudad1, Normalizada1),
    normalizar(Ciudad2, Normalizada2),
    Normalizada1 = Normalizada2.

normalizar(Texto, Normalizado) :-
    normalize_space(string(SinEspacios), Texto),
    string_lower(SinEspacios, Normalizado).

% vuelos

:- dynamic vuelo/7.
:- dynamic tmc/1.

% TMC inicial: 45 minutos
tmc(45).

% Cargar vuelos desde el archivo
cargar_vuelos(Archivo) :-
    catch(
        (
            retractall(vuelo(_,_,_,_,_,_,_)),
            setup_call_cleanup(
                open(Archivo, read, Flujo),
                leer_vuelos(Flujo),
                close(Flujo)
            )
        ),
        Error,
        (
            print_message(error, Error),
            fail
        )
    ).

% Leer todas las lineas del archivo
leer_vuelos(Flujo) :-
    read_line_to_string(Flujo, Linea),
    (
        Linea == end_of_file
        ->
        true
        ;
        (
            normalize_space(string(Texto), Linea),
            (
                Texto \= "",
                parsear_vuelo(Texto)
                ->
                true
                ;
                Texto = ""
                ->
                true
                ;
                format('Advertencia: linea ignorada: ~s~n', [Texto])
            ),
            leer_vuelos(Flujo)
        )
    ).

% Convertir una linea en un hecho vuelo/7
parsear_vuelo(Linea) :-
    split_string(Linea, "|", " ", Campos),
    Campos = [Origen, Destino, Salida, Llegada,
              CostoTexto, Codigo, Dias],
    number_string(Costo, CostoTexto),
    assertz(vuelo(
        Origen, Destino, Salida, Llegada,
        Costo, Codigo, Dias
    )).

% Configurar el TMC
configurar_tmc(Minutos) :-
    integer(Minutos),
    Minutos >= 0,
    retractall(tmc(_)),
    assertz(tmc(Minutos)).

% Obtener todos los vuelos cargados
vuelos_cargados(Lista) :-
    findall(
        vuelo(O,D,S,L,C,Cod,Dia),
        vuelo(O,D,S,L,C,Cod,Dia),
        Lista
    ).