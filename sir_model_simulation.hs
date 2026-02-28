import System.IO
import Data.List
import System.Directory (listDirectory, createDirectoryIfMissing)
import System.FilePath ((</>), takeExtension, takeBaseName)

-- pokretanje programa:
-- :set -package directory
-- :set -package filepath
-- :l sir_model_simulation.hs

data Stanje = Stanje {
    listaZdravih :: [Int],
    listaZarazenih :: [Int],
    listaOporavljenih :: [Int]
} deriving Show

-- Ucitavanje grafa iz fajla
ucitajGraf :: FilePath -> IO [(Int, [Int])]
ucitajGraf putanja = do
    sadrzaj <- readFile putanja
    return (map parsirajLiniju (lines sadrzaj))

parsirajLiniju :: String -> (Int, [Int])
parsirajLiniju linija = (brojCvora, listaSusjeda)
    where (lijeviDio, desniDio) = break (== ':') linija
          brojCvora = read lijeviDio
          susjediTekst = drop 2 desniDio
          listaSusjeda =
            if susjediTekst == "" then []
            else map read (words susjediTekst)

-- Obrada grafa
obradiGraf :: FilePath -> FilePath -> IO ()
obradiGraf putanjaGrafa izlazniFolder = do
    graf <- ucitajGraf putanjaGrafa
    let sviCvorovi = map fst graf
    let pocetnoStanje = Stanje (delete 0 sviCvorovi) [0] []

    let ispis = unlines (map show graf) ++ "\nStanje:\n" ++ show pocetnoStanje
    let imeIzlaza = izlazniFolder </> takeBaseName putanjaGrafa ++ ".txt"
    writeFile imeIzlaza ispis
    putStrLn ("Rezultati sacuvani u " ++ imeIzlaza)

-- Obrada fajlova
obradiGrafove :: [FilePath] -> FilePath -> IO ()
obradiGrafove [] _ = return ()
obradiGrafove (g:gs) izlazniFolder = do
    obradiGraf g izlazniFolder
    obradiGrafove gs izlazniFolder

-- Obrada foldera
obradiFolder :: FilePath -> FilePath -> IO ()
obradiFolder ulazniFolder izlazniFolder = do
    createDirectoryIfMissing True izlazniFolder
    fajlovi <- listDirectory ulazniFolder
    let txtFajlovi = [ulazniFolder </> f | f <- fajlovi, takeExtension f == ".txt"]
    obradiGrafove txtFajlovi izlazniFolder

main :: IO ()
main = do
    obradiFolder ulazniFolder izlazniFolder
    where ulazniFolder = "grafovi"
          izlazniFolder = "rez1"