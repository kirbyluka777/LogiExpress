module Main where

import System.Directory (doesFileExist)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hFlush, isEOF, stdout)
import qualified Modulo2
import qualified Modulo1
import qualified Modulo3
import Tipos

main :: IO ()
main = do
    argumentos <- getArgs
    rutaArchivo <- seleccionarArchivo argumentos
    putStrLn "Cargando vuelos..."
    resultado <- Modulo1.cargarVuelos rutaArchivo

    case resultado of
        Left mensaje -> do
            putStrLn mensaje
            putStrLn "No se pudo iniciar el sistema. Verifique vuelos.txt."
            exitFailure
        Right vuelos -> do
            putStrLn ("Vuelos cargados correctamente: " ++ show (length vuelos))
            menuPrincipal vuelos 45

seleccionarArchivo :: [String] -> IO FilePath
seleccionarArchivo (ruta:_) = return ruta
seleccionarArchivo [] = do
    let candidatos = ["vuelos.txt", "haskell/vuelos.txt", "../vuelos.txt"]
    existentes <- buscarExistentes candidatos
    return (case existentes of
                (ruta:_) -> ruta
                [] -> "vuelos.txt")

buscarExistentes :: [FilePath] -> IO [FilePath]
buscarExistentes [] = return []
buscarExistentes (ruta:resto) = do
    existe <- doesFileExist ruta
    if existe
        then return [ruta]
        else buscarExistentes resto

-- Menu principal: cada modulo recibe el TMC actual y devuelve el nuevo valor.
menuPrincipal :: Grafo -> Int -> IO ()
menuPrincipal vuelos tmcActual = do
    putStrLn "\n====== LOGIEXPRESS - CONTROL DE VUELOS ======"
    putStrLn "1. Modulo 1 - Consultas basicas"
    putStrLn "2. Modulo 2 - Busqueda de rutas"
    putStrLn "3. Modulo 3: Optimizacion de Rutas"
    putStrLn "0. Salir"
    opcion <- leerOpcion

    case opcion of
        "1" -> do
            nuevoTmc <- Modulo1.menu vuelos tmcActual
            menuPrincipal vuelos nuevoTmc
        "2" -> do
            nuevoTmc <- Modulo2.menu vuelos tmcActual
            menuPrincipal vuelos nuevoTmc
        "3" -> do
            nuevoTmc <- Modulo3.menu vuelos tmcActual
            loopPrincipal vuelos nuevoTm
        "0" -> putStrLn "Terminando programa..."
        _ -> do
            putStrLn "Opcion invalida."
            menuPrincipal vuelos tmcActual

leerOpcion :: IO String
leerOpcion = do
    putStr "Seleccione una opcion: "
    hFlush stdout
    fin <- isEOF
    if fin then return "0" else getLine
