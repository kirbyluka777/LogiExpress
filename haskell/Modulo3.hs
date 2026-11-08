module Modulo3
    ( menu
    ) where

import Tipos
import Modulo2 (buscarRutas, operaEnDia, mostrarRuta)
import System.IO (hFlush, isEOF, stdout)

-- Rutas
costoTotal :: [Vuelo] -> Float
costoTotal = sum . map precio

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

compararPorCosto :: [Vuelo] -> [Vuelo] -> Ordering
compararPorCosto r1 r2 = compare (costoTotal r1) (costoTotal r2)

compararPorTiempo :: [Vuelo] -> [Vuelo] -> Ordering
compararPorTiempo r1 r2 = compare (tiempoTotal r1) (tiempoTotal r2)

-- Menú
menu :: Grafo -> Int -> IO Int
menu vuelos tmcActual = do
    putStrLn "\n====== MODULO 3 - OPTIMIZACION DE RUTAS ======"
    putStrLn "1. Ruta mas economica (Costo Minimo)"
    putStrLn "2. Ruta mas rapida (Menor Tiempo Total)"
    putStrLn "3. Reporte ordenado por Costo"
    putStrLn "4. Reporte ordenado por Tiempo"
    putStrLn "0. Volver al menu principal"
    opcion <- leerEntrada "Seleccione una opcion: "
    
    case opcion of
        "0" -> do
            putStrLn "Volviendo al menu principal..."
            return tmcActual
            
        sel | sel `elem` ["1", "2", "3", "4"] -> do
            origenRuta  <- leerEntrada "Ciudad de origen: "
            destinoRuta <- leerEntrada "Ciudad de destino: "
            dia         <- leerEntrada "Dia de la semana: "
            
            let rutas = buscarRutas origenRuta destinoRuta dia tmcActual 999 vuelos [] [origenRuta]
            
            if null rutas
                then putStrLn "No hay rutas validas para optimizar."
                else ejecutarOptimizacion sel rutas
                
            return tmcActual
            
        _ -> do
            putStrLn "Opcion invalida. Intente de nuevo."
            menu vuelos tmcActual -- Se vuelve a llamar al menu en caso de error

-- Optimización
ejecutarOptimizacion :: String -> [[Vuelo]] -> IO ()
ejecutarOptimizacion "1" rutas = do
    let rutaMin = head (quicksort compararPorCosto rutas)
    putStrLn "\n--- RUTA MAS ECONOMICA ---"
    mostrarRuta rutaMin

ejecutarOptimizacion "2" rutas = do
    let rutaMin = head (quicksort compararPorTiempo rutas)
    putStrLn "\n--- RUTA MAS RAPIDA ---"
    mostrarRuta rutaMin

ejecutarOptimizacion "3" rutas = do
    let ordenadas = quicksort compararPorCosto rutas
    putStrLn "\n--- RUTAS ORDENADAS POR COSTO ---"
    mapM_ mostrarRuta ordenadas

ejecutarOptimizacion "4" rutas = do
    let ordenadas = quicksort compararPorTiempo rutas
    putStrLn "\n--- RUTAS ORDENADAS POR TIEMPO ---"
    mapM_ mostrarRuta ordenadas

ejecutarOptimizacion _ _ = return ()

-- Funcion auxiliar
leerEntrada :: String -> IO String
leerEntrada mensaje = do
    putStr mensaje
    hFlush stdout
    fin <- isEOF
    if fin then return "0" else getLine