module Buscador where

import Tipos
import Data.List (isInfixOf)
import Data.Char (toUpper)


normalizarDia :: String -> String
normalizarDia d = 
    case map toUpper d of
        "LUNES"     -> "L"
        "MARTES"    -> "M"
        "MIERCOLES" -> "Mi"
        "MIÉRCOLES" -> "Mi"
        "JUEVES"    -> "J"
        "VIERNES"   -> "V"
        "SABADO"    -> "S"
        "SÁBADO"    -> "S"
        "DOMINGO"   -> "D"
        _           -> d


tokensDias :: String -> [String]
tokensDias [] = []
tokensDias s = 
    case break (== '-') s of
        (h, '-':t) -> h : tokensDias t
        (h, "")    -> [h]
        _          -> []


operaEnDia :: String -> String -> Bool
operaEnDia diasOp consulta
    | "Diario" `isInfixOf` diasOp = True
    | otherwise = normalizarDia consulta `elem` tokensDias diasOp


buscarRutas :: Ciudad -> Ciudad -> String -> Int -> Int -> [Vuelo] -> [Vuelo] -> [[Vuelo]]
buscarRutas actual destinoFinal dia tmc maxEscalas todosVuelos rutaActual visitados
    | actual == destinoFinal && not (null rutaActual) = [reverse rutaActual]
    | length rutaActual > maxEscalas + 1 = []
    | otherwise = 
        let vuelosValidos = filter (\v -> 
                origen v == actual &&
                not (destino v `elem` visitados) &&
                operaEnDia (dias v) dia &&
                (null rutaActual || salida v >= llegada (head rutaActual) + tmc)
              ) todosVuelos
        in concat [ buscarRutas (destino v) destinoFinal dia tmc maxEscalas todosVuelos (v:rutaActual) (destino v : visitados) | v <- vuelosValidos ]


mostrarRuta :: [Vuelo] -> IO ()
mostrarRuta ruta = do
    let costoTotal = sum (map precio ruta)
    putStrLn "----------------------------------------"
    mapM_ (\v -> putStrLn $ "  * " ++ show v) ruta
    putStrLn $ "  ==> Costo Total del Viaje: $" ++ show costoTotal
    putStrLn "----------------------------------------"