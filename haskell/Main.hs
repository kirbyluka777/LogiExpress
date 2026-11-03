module Main where

import System.IO
import Tipos
import LecturaDatos
import Buscador


menu :: [Vuelo] -> Int -> IO ()
menu vuelos tmcActual = do
    putStrLn "\n--- LOGIEXPRESS - MENU PRINCIPAL ---"
    putStrLn "1. Ver todos los vuelos"
    putStrLn "2. Buscar rutas validas (Modulo 2)"
    putStrLn "3. Consultar salidas por ciudad"
    putStrLn "4. Consultar llegadas por ciudad"
    putStrLn "5. Configurar TMC"
    putStrLn "6. Salir"
    putStr "Elige una opcion: "
    hFlush stdout
    op <- getLine
    
    case op of
        "1" -> do
            mapM_ print vuelos
            menu vuelos tmcActual
        "2" -> do
            putStr "Ciudad de origen: "
            hFlush stdout
            org <- getLine
            putStr "Ciudad de destino: "
            hFlush stdout
            dest <- getLine
            putStr "Dia de la semana (ej. Lunes): "
            hFlush stdout
            dia <- getLine
            putStr "Numero maximo de escalas (K): "
            hFlush stdout
            kStr <- getLine
            let maxEsc = read kStr :: Int
            
            let rutas = buscarRutas org dest dia tmcActual maxEscalas vuelos [org]
            putStrLn $ "\nSe encontraron " ++ show (length rutas) ++ " rutas validas:"
            if null rutas
                then putStrLn "No hay rutas disponibles que cumplan las restricciones."
                else mapM_ mostrarRuta rutas
            menu vuelos tmcActual
        "3" -> do
            putStr "Ciudad de origen: "
            hFlush stdout
            c <- getLine
            mapM_ print (vuelosSalida c vuelos)
            menu vuelos tmcActual
        "4" -> do
            putStr "Ciudad de llegada: "
            hFlush stdout
            c <- getLine
            mapM_ print (vuelosLlegada c vuelos)
            menu vuelos tmcActual
        "5" -> do
            putStr "Minutos de TMC (actual: "
            putStr $ show tmcActual
            putStrLn "):"
            putStr "Nuevo valor en minutos: "
            hFlush stdout
            tmcStr <- getLine
            let nuevoTmc = read tmcStr :: Int
            putStrLn $ "[Info] TMC fijado en " ++ show nuevoTmc ++ " minutos."
            menu vuelos nuevoTmc
        "6" -> putStrLn "Saliendo del sistema..."
        _   -> do
            putStrLn "Opcion invalida, prueba otra vez."
            menu vuelos tmcActual

main :: IO ()
main = do
    putStrLn "Cargando vuelos..."
    vuelos <- cargarVuelos
    putStrLn $ "Cargados " ++ show (length vuelos) ++ " vuelos correctamente."

    menu vuelos 45