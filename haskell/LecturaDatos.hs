module LecturaDatos where

import System.IO
import Tipos

arreglarLinea :: String -> String
arreglarLinea [] = []
arreglarLinea (x:xs)
    | x == '/' || x == '-' = '|'
    | otherwise = x : arreglarLinea xs

parsearVuelo :: String -> Vuelo
parsearVuelo linea =
    let partes = separarPorPipe (arreglarLinea linea)
    in case partes of
        (orig:dest:sal:lle:prec:cod:diasOp:_) -> 
            Vuelo {
                origen = limpiar espacios orig,
                destino = limpiar espacios dest,
                salida = horaToMins (limpiar espacios sal),
                llegada = horaToMins (limpiar espacios lle),
                precio = read (limpiar espacios prec) :: Float,
                codigo = limpiar espacios cod,
                dias = limpiar espacios diasOp
            }
        _ -> error "Error leyendo una línea del archivo"
  where
    espacios = id
    limpiar _ = unwords . words

separarPorPipe :: String -> [String]
separarPorPipe s = case break (== '|') s of
    (h, '|':t) -> h : separarPorPipe t
    (h, "")    -> [h]
    _          -> []

cargarVuelos :: IO [Vuelo]
cargarVuelos = do
    contenido <- readFile "../vuelos.txt"
    return (map parsearVuelo (filter (not . null) (lines contenido)))

vuelosSalida :: Ciudad -> [Vuelo] -> [Vuelo]
vuelosSalida c = filter (\v -> origen v == c)

vuelosLlegada :: Ciudad -> [Vuelo] -> [Vuelo]
vuelosLlegada c = filter (\v -> destino v == c)