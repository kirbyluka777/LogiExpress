module LecturaDatos
    ( cargarVuelosDesde
    , parsearVuelo
    , separarPorPipe
    , vuelosSalida
    , vuelosLlegada
    ) where

import Control.Exception (IOException, evaluate, try)
import Data.Char (isSpace)
import System.IO.Error (ioeGetErrorString)
import Text.Read (readMaybe)
import Tipos

-- Lee y valida el archivo indicado. Los errores se devuelven como texto
-- para que el menu principal pueda mostrarlos sin cerrar inesperadamente.
cargarVuelosDesde :: FilePath -> IO (Either String [Vuelo])
cargarVuelosDesde ruta = do
    resultado <- try (readFile ruta >>= \contenido -> evaluate (length contenido) >> return contenido)
                 :: IO (Either IOException String)
    case resultado of
        Left err -> return (Left ("No se pudo leer '" ++ ruta ++ "': " ++ ioeGetErrorString err))
        Right contenido -> return (parsearLineas (zip [1 ..] (lines contenido)))

parsearLineas :: [(Int, String)] -> Either String [Vuelo]
parsearLineas [] = Right []
parsearLineas ((numero, linea):resto)
    | null (limpiar linea) = parsearLineas resto
    | otherwise =
        case parsearVuelo linea of
            Left mensaje -> Left ("Error en la linea " ++ show numero ++ ": " ++ mensaje)
            Right vuelo -> (vuelo :) <$> parsearLineas resto

-- El formato tiene exactamente siete campos separados por '|'.
-- Importante: no se reemplazan los guiones, porque forman parte de los dias
-- de operacion, por ejemplo L-M-Mi-J-V.
parsearVuelo :: String -> Either String Vuelo
parsearVuelo linea =
    case map limpiar (separarPorPipe linea) of
        [orig, dest, sal, lle, prec, cod, diasOp] -> do
            validarCampo "origen" orig
            validarCampo "destino" dest
            validarCampo "codigo" cod
            validarCampo "dias de operacion" diasOp
            horaSalida <- validarHora "salida" sal
            horaLlegada <- validarHora "llegada" lle
            costo <- maybe (Left ("precio invalido: " ++ prec)) Right (readMaybe prec :: Maybe Float)
            if isNaN costo || isInfinite costo || costo < 0
                then Left "el precio debe ser un numero finito mayor o igual a cero"
                else Right (Vuelo
                    { origen = orig
                    , destino = dest
                    , salida = horaSalida
                    , llegada = horaLlegada
                    , precio = costo
                    , codigo = cod
                    , dias = diasOp
                    })
        campos -> Left
            ("se esperaban 7 campos separados por '|', pero se encontraron " ++ show (length campos))

validarCampo :: String -> String -> Either String ()
validarCampo nombre valor
    | null valor = Left ("el campo '" ++ nombre ++ "' no puede estar vacio")
    | otherwise = Right ()

validarHora :: String -> String -> Either String Minutos
validarHora nombre texto =
    maybe (Left ("hora de " ++ nombre ++ " invalida ('" ++ texto ++ "'). Use HH:MM."))
          Right
          (parseHora texto)

separarPorPipe :: String -> [String]
separarPorPipe texto =
    case break (== '|') texto of
        (campo, '|':resto) -> campo : separarPorPipe resto
        (campo, []) -> [campo]
        _ -> []

limpiar :: String -> String
limpiar = quitarBordes . filter (/= '\r')
  where
    quitarBordes = dropWhileEnd isSpace . dropWhile isSpace
    dropWhileEnd f = reverse . dropWhile f . reverse

vuelosSalida :: Ciudad -> [Vuelo] -> [Vuelo]
vuelosSalida ciudad = filter (\vuelo -> ciudadIgual (origen vuelo) ciudad)

vuelosLlegada :: Ciudad -> [Vuelo] -> [Vuelo]
vuelosLlegada ciudad = filter (\vuelo -> ciudadIgual (destino vuelo) ciudad)
