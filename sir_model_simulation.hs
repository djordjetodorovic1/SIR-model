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

-- Korak SIR modela
sirKorak :: [(Int, [Int])] -> Double -> Double -> Stanje -> IO Stanje
sirKorak graf beta gamma trenutnoStanje = do
    let zdravi = listaZdravih trenutnoStanje
    let zarazeni = listaZarazenih trenutnoStanje
    let oporavljeni = listaOporavljenih trenutnoStanje

    -- Testiranje funkcije
    -- Zamjeniti sa oporavljenim i zarazenim za beta i gamma
    let noviZarazeni = take 1 zdravi
    let novaListaZdravih = drop 1 zdravi
    let noviOporavljeni = take 1 zarazeni
    let preostaliZarazeni = drop 1 zarazeni
    let novaListaZarazenih = preostaliZarazeni ++ noviZarazeni
    let novaListaOporavljeni = oporavljeni ++ noviOporavljeni

    return (Stanje novaListaZdravih novaListaZarazenih novaListaOporavljeni)


-- Simulacija SIR modela
simuliraj :: [(Int, [Int])] -> Double -> Double -> Int -> Stanje -> [(Int, Int, Int)] -> IO [(Int, Int, Int)]
simuliraj _ _ _ 0 _ rezultati = return (reverse rezultati)
simuliraj graf beta gamma brojDana trenutnoStanje rezultati = do
    -- putStrLn ("Dan " ++ show (length rezultati + 1) ++ ": zdravi=" ++ show s ++ ", Zarazeni =" ++ show i ++ ", Oporavljeni=" ++ show r)

    novoStanje <- sirKorak graf beta gamma trenutnoStanje
    simuliraj graf beta gamma (brojDana - 1) novoStanje ((s,i,r):rezultati)
    where s = length (listaZdravih trenutnoStanje)
          i = length (listaZarazenih trenutnoStanje)
          r = length (listaOporavljenih trenutnoStanje)

-- CSV format
formatirajRed :: Int -> (Int, Int, Int) -> String
formatirajRed dan (s,i,r) = show dan ++ "," ++ show s ++ "," ++ show i ++ "," ++ show r

toCSV :: [(Int, Int, Int)] -> String
toCSV rezultati = unlines (zaglavlje : redovi)
    where zaglavlje = "Dan,Zdravi,Zarazeni,Oporavljeni"
          redovi = zipWith formatirajRed [1..] rezultati

-- Obrada grafa
obradiGraf :: FilePath -> FilePath -> Double -> Double -> Int -> IO ()
obradiGraf putanjaGrafa izlazniFolder beta gamma brojDana = do
    graf <- ucitajGraf putanjaGrafa
    let sviCvorovi = map fst graf
    let pocetnoStanje = Stanje (delete 0 sviCvorovi) [0] []

    rezultati <- simuliraj graf beta gamma brojDana pocetnoStanje []

    let csvSadrzaj = toCSV rezultati
    let imeIzlaza = izlazniFolder </> takeBaseName putanjaGrafa ++ ".csv"
    writeFile imeIzlaza csvSadrzaj
    putStrLn ("Rezultati sacuvani u " ++ imeIzlaza)

-- Obrada fajlova
obradiGrafove :: [FilePath] -> FilePath -> Double -> Double -> Int -> IO ()
obradiGrafove [] _ _ _ _ = return ()
obradiGrafove (g:gs) izlazniFolder beta gamma brojDana = do
    obradiGraf g izlazniFolder beta gamma brojDana
    obradiGrafove gs izlazniFolder beta gamma brojDana

-- Obrada foldera
obradiFolder :: FilePath -> FilePath -> Double -> Double -> Int -> IO ()
obradiFolder ulazniFolder izlazniFolder beta gamma brojDana = do
    createDirectoryIfMissing True izlazniFolder
    fajlovi <- listDirectory ulazniFolder
    let txtFajlovi = [ulazniFolder </> f | f <- fajlovi, takeExtension f == ".txt"]
    obradiGrafove txtFajlovi izlazniFolder beta gamma brojDana

main :: IO ()
main = do
    obradiFolder ulazniFolder izlazniFolder beta gamma brojDana
    where ulazniFolder = "grafovi"
          izlazniFolder = "rez1"
          beta = 0.1
          gamma = 0.1
          brojDana = 100