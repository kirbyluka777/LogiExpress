module Modulo3
    ( menu
    ) where

import Tipos
import Modulo2 (buscarRutas, operaEnDia, mostrarRuta)
import System.IO (hFlush, isEOF, stdout)

-- Calcula el costo total sumando los precios de los vuelos de la ruta
costoTotal :: [Vuelo] -> Float
costoTotal = sum . map precio

-- Calcula el tiempo total en minutos (considerando cruce de medianoche básico)
tiempoTotal :: [Vuelo] -> Int
tiempoTotal [] = 0
tiempoTotal ruta = 
    let ini = salida (head ruta)
        fin = llegada (last ruta)
    in if fin >= ini then fin - ini else fin + 1440 - ini

-- QuickSort
quicksort :: (a -> a -> Ordering) -> [a] -> [a]
quicksort _ [] = []
quicksort cmp (x:xs) =
    let menores = quicksort cmp [y | y <- xs, cmp y x == LT || cmp y x == EQ]
        mayores = quicksort cmp [y | y <- xs, cmp y x == GT]
    in menores ++ [x] ++ mayores

-- Funciones de comparación
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
                    let rutaMin = head (quicksort compararPorCosto rutas)
                    putStrLn "\n--- RUTA MAS ECONOMICA ---"
                    mostrarRuta rutaMin
                "2" -> do
                    let rutaMin = head (quicksort compararPorTiempo rutas)
                    putStrLn "\n--- RUTA MAS RAPIDA ---"
                    mostrarRuta rutaMin
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