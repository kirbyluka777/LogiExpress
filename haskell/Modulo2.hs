module Modulo2
    ( menu
    , buscarRutas
    , operaEnDia
    , mostrarRuta
    ) where

import Data.Char (toUpper)
import System.IO (hFlush, isEOF, stdout)
import Text.Read (readMaybe)
import Tipos

-- Modulo 2: busqueda de rutas respetando dias, conexiones, TMC y escalas.
menu :: Grafo -> Int -> IO Int
menu vuelos tmcActual = do
    putStrLn "\n====== MODULO 2 - BUSQUEDA DE RUTAS ======"
    putStrLn "1. Buscar rutas validas"
    putStrLn "0. Volver al menu principal"
    opcion <- leerEntrada "Seleccione una opcion: "

    case opcion of
        "1" -> do
            origenRuta <- leerEntrada "Ciudad de origen: "
            destinoRuta <- leerEntrada "Ciudad de destino: "
            dia <- leerEntrada "Dia de la semana (ej. Lunes): "
            escalasTexto <- leerEntrada "Numero maximo de escalas (K): "
            case readMaybe escalasTexto :: Maybe Int of
                Just maxEscalas | maxEscalas >= 0 -> do
                    let rutas = buscarRutas origenRuta destinoRuta dia
                                  tmcActual maxEscalas vuelos [] [origenRuta]
                    putStrLn ("\nSe encontraron " ++ show (length rutas) ++ " rutas validas:")
                    if null rutas
                        then putStrLn "No hay rutas disponibles que cumplan las restricciones."
                        else mapM_ mostrarRuta rutas
                _ -> putStrLn "Error: K debe ser un entero mayor o igual a cero."
            menu vuelos tmcActual

        "0" -> do
            putStrLn "Volviendo al menu principal..."
            return tmcActual

        _ -> do
            putStrLn "Opcion invalida."
            menu vuelos tmcActual

leerEntrada :: String -> IO String
leerEntrada mensaje = do
    putStr mensaje
    hFlush stdout
    fin <- isEOF
    if fin then return "0" else getLine

-- Retorna las rutas con los vuelos en orden cronologico.
-- rutaActual se almacena invertida para agregar vuelos en tiempo constante;
-- visitadas evita ciclos entre ciudades.
buscarRutas :: Ciudad -> Ciudad -> String -> Int -> Int -> Grafo
            -> [Vuelo] -> [Ciudad] -> [[Vuelo]]
buscarRutas actual destinoFinal dia tmc maxEscalas todosVuelos rutaActual visitadas
    | maxEscalas < 0 = []
    | length rutaActual > maxEscalas + 1 = []
    | ciudadIgual actual destinoFinal && not (null rutaActual) = [reverse rutaActual]
    | otherwise =
        let vuelosValidos = filter (\vuelo ->
                ciudadIgual (origen vuelo) actual &&
                not (any (ciudadIgual (destino vuelo)) visitadas) &&
                operaEnDia (dias vuelo) dia &&
                (null rutaActual ||
                    salida vuelo >= llegada (head rutaActual) + tmc)
              ) todosVuelos
        in concat
            [ buscarRutas (destino vuelo) destinoFinal dia tmc maxEscalas
                todosVuelos (vuelo : rutaActual) (destino vuelo : visitadas)
            | vuelo <- vuelosValidos
            ]

operaEnDia :: String -> String -> Bool
operaEnDia diasOperacion consulta
    | map toUpper (limpiar diasOperacion) == "DIARIO" = True
    | otherwise = normalizarDia consulta `elem` map normalizarDia (tokensDias diasOperacion)

normalizarDia :: String -> String
normalizarDia dia =
    case map toUpper (limpiar dia) of
        "LUNES" -> "L"
        "MARTES" -> "M"
        "MIERCOLES" -> "MI"
        "MIÉRCOLES" -> "MI"
        "JUEVES" -> "J"
        "VIERNES" -> "V"
        "SABADO" -> "S"
        "SÁBADO" -> "S"
        "DOMINGO" -> "D"
        "L" -> "L"
        "M" -> "M"
        "MI" -> "MI"
        "J" -> "J"
        "V" -> "V"
        "S" -> "S"
        "D" -> "D"
        otro -> otro

tokensDias :: String -> [String]
tokensDias [] = []
tokensDias texto =
    case break (== '-') texto of
        (dia, '-':resto) -> dia : tokensDias resto
        (dia, []) -> [dia]
        _ -> []

limpiar :: String -> String
limpiar = unwords . words

mostrarRuta :: [Vuelo] -> IO ()
mostrarRuta ruta = do
    let costoTotal = sum (map precio ruta)
    putStrLn "----------------------------------------"
    mapM_ (putStrLn . ("  * " ++) . show) ruta
    putStrLn ("  ==> Costo total del viaje: " ++ show costoTotal)
    putStrLn "----------------------------------------"
