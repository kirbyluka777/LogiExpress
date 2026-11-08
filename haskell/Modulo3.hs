module Modulo3
    ( menu
    ) where

import Data.List (intercalate)
import Tipos
import Modulo2 (buscarRutas, mostrarRuta)
import System.IO (hFlush, isEOF, stdout)

costoTotal :: [Vuelo] -> Float
costoTotal = foldl (\acumulado vuelo -> acumulado + precio vuelo) 0

tiempoTotal :: [Vuelo] -> Int
tiempoTotal [] = 0
tiempoTotal (primerVuelo:resto) =
    let inicio = salida primerVuelo
        fin = foldl (\_ vuelo -> llegada vuelo) (llegada primerVuelo) resto
    in if fin >= inicio then fin - inicio else fin + 1440 - inicio

-- QuickSort
quicksort :: (a -> a -> Ordering) -> [a] -> [a]
quicksort _ [] = []
quicksort cmp (x:xs) =
    let menores = quicksort cmp [y | y <- xs, cmp y x == LT || cmp y x == EQ]
        mayores = quicksort cmp [y | y <- xs, cmp y x == GT]
    in menores ++ [x] ++ mayores

compararPorCosto :: [Vuelo] -> [Vuelo] -> Ordering
compararPorCosto r1 r2 = compare (costoTotal r1) (costoTotal r2)

compararPorTiempo :: [Vuelo] -> [Vuelo] -> Ordering
compararPorTiempo r1 r2 = compare (tiempoTotal r1) (tiempoTotal r2)

-- Menú
menu :: Grafo -> Int -> IO Int
menu vuelos tmcActual = do
    putStrLn "\n====== MODULO 3 - OPTIMIZACION DE RUTAS ======"
    origenRuta <- leerEntrada "Ciudad de origen: "
    destinoRuta <- leerEntrada "Ciudad de destino: "
    dia <- leerEntrada "Dia de la semana: "
    
    let rutas = buscarRutas origenRuta destinoRuta dia tmcActual 999 vuelos [] [origenRuta]
    
    if null rutas
        then putStrLn "No hay rutas validas para optimizar." >> return tmcActual
        else do
            putStrLn "1. Ver ruta de Costo Economico Minimo"
            putStrLn "2. Ver ruta de Menor Tiempo Total"
            putStrLn "3. Reporte ordenado por Costo"
            putStrLn "4. Reporte ordenado por Tiempo"
            opcion <- leerEntrada "Seleccione una opcion: "
            
            case opcion of
                "1" -> do
                    case quicksort compararPorCosto rutas of
                        rutaMin:_ -> do
                            putStrLn "\n--- RUTA MAS ECONOMICA ---"
                            mostrarRuta rutaMin
                        [] -> putStrLn "No hay rutas disponibles para ordenar."
                "2" -> do
                    case quicksort compararPorTiempo rutas of
                        rutaMin:_ -> do
                            putStrLn "\n--- RUTA MAS RAPIDA ---"
                            mostrarRuta rutaMin
                        [] -> putStrLn "No hay rutas disponibles para ordenar."
                "3" -> do
                    let ordenadas = quicksort compararPorCosto rutas
                    putStrLn "\n--- RUTAS ORDENADAS POR COSTO ---"
                    mapM_ mostrarRuta ordenadas
                "4" -> do
                    let ordenadas = quicksort compararPorTiempo rutas
                    putStrLn "\n--- RUTAS ORDENADAS POR TIEMPO ---"
                    mapM_ mostrarRuta ordenadas
                _   -> putStrLn "Opcion invalida."
            
            return tmcActual

leerEntrada :: String -> IO String
leerEntrada mensaje = do
    putStr mensaje
    hFlush stdout
    fin <- isEOF
    if fin then return "0" else getLine