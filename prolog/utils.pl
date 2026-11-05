
:- module(utilidades, [
    leer_linea/1,
    leer_entero/2,
    normalizar/2,
    ciudad_igual/2
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