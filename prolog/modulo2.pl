:- module(modulo2, [
    menu/0,
    rutas_validas/5
]).

:- use_module(utils).


% NORMALIZACION DE Dias

normalizar_dia(Entrada, Codigo) :-
    normalizar(Entrada, Dia),
    codigo_dia(Dia, Codigo).

codigo_dia("lunes", "l").
codigo_dia("lun", "l").
codigo_dia("l", "l").

codigo_dia("martes", "m").
codigo_dia("mar", "m").
codigo_dia("m", "m").

codigo_dia("miercoles", "mi").
codigo_dia("miércoles", "mi").
codigo_dia("mie", "mi").
codigo_dia("mié", "mi").
codigo_dia("mi", "mi").

codigo_dia("jueves", "j").
codigo_dia("jue", "j").
codigo_dia("j", "j").

codigo_dia("viernes", "v").
codigo_dia("vie", "v").
codigo_dia("v", "v").

codigo_dia("sabado", "s").
codigo_dia("sábado", "s").
codigo_dia("sab", "s").
codigo_dia("sáb", "s").
codigo_dia("s", "s").

codigo_dia("domingo", "d").
codigo_dia("dom", "d").
codigo_dia("d", "d").


% COMPATIBILIDAD DE FRECUENCIA

vuelo_disponible("Diario", _) :-
    !.

vuelo_disponible(DiasVuelo, Dia) :-
    string_lower(DiasVuelo, DiasNormalizados),
    split_string(DiasNormalizados, "-", "", ListaDias),
    member(Dia, ListaDias).


% VALIDACION DE CONEXIONES

% The next flight must depart at least TMC minutes
% after the previous flight arrives.

conexion_valida(
    vuelo(_, _, _, LlegadaAnterior, _, _, _),
    vuelo(_, _, SalidaActual, _, _, _, _),
    TMC
) :-
    hora_a_minutos(LlegadaAnterior, MinLlegada),
    hora_a_minutos(SalidaActual, MinSalida),
    Minimo is MinLlegada + TMC,
    MinSalida >= Minimo.


% CONTROL DE CICLOS

no_visitada(_, []).

no_visitada(Ciudad, [Visitada | Resto]) :-
    \+ ciudad_igual(Ciudad, Visitada),
    no_visitada(Ciudad, Resto).


% CONTROL DEL NUMERO DE ESCALAS

% ilimitadas means there is no limit.
% Otherwise, the number of flights already selected
% cannot exceed the maximum number of connections.

puede_agregar_vuelo(_, ilimitadas).

puede_agregar_vuelo(VuelosUsados, MaxEscalas) :-
    integer(MaxEscalas),
    MaxEscalas >= 0,
    VuelosUsados =< MaxEscalas.


% BUSQUEDA RECURSIVA DFS

buscar_ruta(
    Actual,
    Destino,
    _Dia,
    _TMC,
    _MaxEscalas,
    _Visitadas,
    _VuelosUsados,
    _Anterior,
    []
) :-
    ciudad_igual(Actual, Destino),
    !.

buscar_ruta(
    Actual,
    Destino,
    Dia,
    TMC,
    MaxEscalas,
    Visitadas,
    VuelosUsados,
    Anterior,
    [VueloActual | Resto]
) :-
    puede_agregar_vuelo(VuelosUsados, MaxEscalas),

    vuelo(O, D, Salida, Llegada, Costo, Codigo, Dias),

    ciudad_igual(O, Actual),

    vuelo_disponible(Dias, Dia),

    no_visitada(D, Visitadas),

    VueloActual = vuelo(
        O, D, Salida, Llegada, Costo, Codigo, Dias
    ),

    (
        Anterior == ninguno
        ;
        conexion_valida(Anterior, VueloActual, TMC)
    ),

    NuevosVuelos is VuelosUsados + 1,

    buscar_ruta(
        D,
        Destino,
        Dia,
        TMC,
        MaxEscalas,
        [D | Visitadas],
        NuevosVuelos,
        VueloActual,
        Resto
    ).


% PREDICADO PRINCIPAL DE BUSQUEDA

rutas_validas(Origen, Destino, DiaEntrada, MaxEscalas, Rutas) :-

    normalizar_dia(DiaEntrada, Dia),

    tmc(TMC),

    (
        ciudad_igual(Origen, Destino)
        ->
        Rutas = []
        ;
        findall(
            Ruta,
            buscar_ruta(
                Origen,
                Destino,
                Dia,
                TMC,
                MaxEscalas,
                [Origen],
                0,
                ninguno,
                Ruta
            ),
            Rutas
        )
    ).


% MOSTRAR RESULTADOS

mostrar_rutas([]) :-
    writeln('No se encontraron rutas validas.').

mostrar_rutas(Rutas) :-
    Rutas \= [],
    length(Rutas, Total),
    format('~nSe encontraron ~w rutas validas:~n', [Total]),
    mostrar_lista_rutas(Rutas, 1).


mostrar_lista_rutas([], _).

mostrar_lista_rutas([Ruta | Resto], Numero) :-

    length(Ruta, CantidadVuelos),
    Escalas is CantidadVuelos - 1,

    format('~n========== RUTA ~w (~w escalas) ==========~n',
           [Numero, Escalas]),

    mostrar_vuelos_ruta(Ruta),

    Siguiente is Numero + 1,
    mostrar_lista_rutas(Resto, Siguiente).


mostrar_vuelos_ruta([]).

mostrar_vuelos_ruta([
    vuelo(O, D, S, L, C, Cod, Dias) | Resto
]) :-

    format(
        '~nCodigo: ~w | ~w -> ~w | Salida: ~w | Llegada: ~w | Costo: ~w | Dias: ~w',
        [Cod, O, D, S, L, C, Dias]
    ),

    mostrar_vuelos_ruta(Resto).


% LECTURA DEL LIMITE DE ESCALAS

leer_limite_escalas(MaxEscalas) :-

    write('Maximo de escalas (enter para ilimitado): '),
    flush_output,

    leer_linea(Texto),

    (
        (
            Texto = ""
        )
        ->
        MaxEscalas = ilimitadas

        ;

        catch(number_string(K, Texto), _, fail),
        integer(K),
        K >= 0
        ->
        MaxEscalas = K

        ;

        MaxEscalas = invalido
    ).


% MENU INTERACTIVO

menu :-

    repeat,

    nl,
    writeln('====== MODULO 2: BUSQUEDA DE RUTAS ======'),
    writeln('1. Buscar rutas validas'),
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


seleccion(1) :-

    write('Ciudad de origen: '),
    flush_output,
    leer_linea(Origen),

    write('Ciudad de destino: '),
    flush_output,
    leer_linea(Destino),

    write('Dia de viaje: '),
    flush_output,
    leer_linea(Dia),

    leer_limite_escalas(MaxEscalas),

    (
        MaxEscalas == invalido
        ->
        writeln('Error: limite de escalas invalido.')

        ;

        (
            normalizar_dia(Dia, _)
            ->
            rutas_validas(
                Origen,
                Destino,
                Dia,
                MaxEscalas,
                Rutas
            ),
            mostrar_rutas(Rutas)

            ;

            writeln('Error: dia de la semana no reconocido.')
        )
    ).


seleccion(_) :-
    writeln('Opcion invalida.').