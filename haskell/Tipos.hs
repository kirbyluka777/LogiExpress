module Tipos
    ( Ciudad
    , Minutos
    , Precio
    , CodigoVuelo
    , DiasOperacion
    , Grafo
    , Vuelo(..)
    , parseHora
    , horaToMins
    , minsAHora
    , ciudadIgual
    ) where

import Data.Char (isDigit, toLower)

-- Tipos basicos compartidos por los modulos del sistema.
type Ciudad = String
type Minutos = Int
type Precio = Float
type CodigoVuelo = String
type DiasOperacion = String

-- Cada vuelo representa una arista dirigida del grafo:
-- origen -> destino, con horario, precio y dias de operacion.
type Grafo = [Vuelo]

data Vuelo = Vuelo
    { origen  :: Ciudad
    , destino :: Ciudad
    , salida  :: Minutos
    , llegada :: Minutos
    , precio  :: Precio
    , codigo  :: CodigoVuelo
    , dias    :: DiasOperacion
    } deriving (Eq)

instance Show Vuelo where
    show v = codigo v ++ ": " ++ origen v ++ " -> " ++ destino v ++
             " | Salida: " ++ minsAHora (salida v) ++
             " | Llegada: " ++ minsAHora (llegada v) ++
             " | Precio: " ++ show (precio v) ++
             " | Dias: " ++ dias v

-- Convierte HH:MM a minutos desde medianoche.
-- Devuelve Nothing si el formato u horario no es valido.
parseHora :: String -> Maybe Minutos
parseHora texto =
    case break (== ':') texto of
        (hh, ':':mm)
            | length hh == 2
            , length mm == 2
            , all isDigit hh
            , all isDigit mm ->
                let h = read hh :: Int
                    m = read mm :: Int
                in if h >= 0 && h < 24 && m >= 0 && m < 60
                   then Just (h * 60 + m)
                   else Nothing
        _ -> Nothing

-- Se conserva esta funcion por compatibilidad con el codigo original.
-- La carga del archivo utiliza parseHora para no aceptar horas invalidas.
horaToMins :: String -> Minutos
horaToMins texto = maybe 0 id (parseHora texto)

minsAHora :: Minutos -> String
minsAHora minutos =
    let h = minutos `div` 60
        m = minutos `mod` 60
        dosDigitos n = if n < 10 then "0" ++ show n else show n
    in dosDigitos h ++ ":" ++ dosDigitos m

-- Compara ciudades ignorando mayusculas y espacios sobrantes.
ciudadIgual :: Ciudad -> Ciudad -> Bool
ciudadIgual a b = normalizar a == normalizar b
  where
    normalizar = map toLower . unwords . words
