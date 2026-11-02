module Main where

import System.IO
import Tipos
import LecturaDatos

menu :: [Vuelo] -> IO ()
menu vuelos = do
    putStrLn "\n--- LOGIEXPRESS - MENU PRINCIPAL ---"
    putStrLn "1. Ver todos los vuelos"
    putStrLn "2. Consultar salidas por ciudad"
    putStrLn "3. Consultar llegadas por ciudad"
    putStrLn "4. Configurar TMC"
    putStrLn "5. Salir"
    putStr "Elige una opcion: "
    hFlush stdout
    op <- getLine
    
    case op of
        "1" -> do
            mapM_ print vuelos
            menu vuelos
        "2" -> do
            putStr "Ciudad de origen: "
            hFlush stdout
            c <- getLine
            mapM_ print (vuelosSalida c vuelos)
            menu vuelos
        "3" -> do
            putStr "Ciudad de llegada: "
            hFlush stdout
            c <- getLine
            mapM_ print (vuelosLlegada c vuelos)
            menu vuelos
        "4" -> do
            putStr "Minutos de TMC: "
            hFlush stdout
            tmc <- getLine
            putStrLn $ "TMC fijado en " ++ tmc ++ " minutos."
            menu vuelos
        "5" -> putStrLn "Saliendo..."
        _   -> do
            putStrLn "Opcion invalida, prueba otra vez."
            menu vuelos

main :: IO ()
main = do
    putStrLn "Cargando vuelos..."
    vuelos <- cargarVuelos
    putStrLn $ "Cargados " ++ show (length vuelos) ++ " vuelos correctamente."
    menu vuelos