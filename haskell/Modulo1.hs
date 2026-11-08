module Modulo1
    ( menu
    , cargarVuelos
    ) where

import LecturaDatos
import System.IO (hFlush, isEOF, stdout)
import Text.Read (readMaybe)
import Tipos

-- Modulo 1: carga de datos, consultas simples y configuracion del TMC.
cargarVuelos :: FilePath -> IO (Either String [Vuelo])
cargarVuelos = cargarVuelosDesde

-- Recibe el TMC actual y devuelve el valor que debe conservar Main.
menu :: [Vuelo] -> Int -> IO Int
menu vuelos tmcActual = do
    putStrLn "\n====== MODULO 1 - CONSULTAS BASICAS ======"
    putStrLn "1. Consultar vuelos de salida"
    putStrLn "2. Consultar vuelos de llegada"
    putStrLn "3. Configurar TMC"
    putStrLn "0. Volver al menu principal"
    opcion <- leerEntrada "Seleccione una opcion: "

    case opcion of
        "1" -> do
            ciudad <- leerEntrada "Ingrese la ciudad de origen: "
            let lista = vuelosSalida ciudad vuelos
            if null lista
                then putStrLn ("No hay vuelos que salgan de " ++ ciudad ++ ".")
                else mostrarVuelos lista
            menu vuelos tmcActual

        "2" -> do
            ciudad <- leerEntrada "Ingrese la ciudad de destino: "
            let lista = vuelosLlegada ciudad vuelos
            if null lista
                then putStrLn ("No hay vuelos que lleguen a " ++ ciudad ++ ".")
                else mostrarVuelos lista
            menu vuelos tmcActual

        "3" -> do
            entrada <- leerEntrada ("TMC actual: " ++ show tmcActual ++
                                    " minutos. Nuevo TMC: ")
            case readMaybe entrada :: Maybe Int of
                Just nuevoTmc | nuevoTmc >= 0 -> do
                    putStrLn ("TMC configurado en " ++ show nuevoTmc ++ " minutos.")
                    menu vuelos nuevoTmc
                _ -> do
                    putStrLn "Error: introduzca un entero mayor o igual a cero."
                    menu vuelos tmcActual

        "0" -> do
            putStrLn "Volviendo al menu principal..."
            return tmcActual

        _ -> do
            putStrLn "Opcion invalida."
            menu vuelos tmcActual

mostrarVuelos :: [Vuelo] -> IO ()
mostrarVuelos = foldr (\vuelo siguiente -> putStrLn (show vuelo) >> siguiente) (return ())

leerEntrada :: String -> IO String
leerEntrada mensaje = do
    putStr mensaje
    hFlush stdout
    fin <- isEOF
    if fin then return "0" else getLine
