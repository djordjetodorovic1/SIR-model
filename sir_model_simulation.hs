import System.IO
import System.Random (randomRIO)
import Data.List
import System.Directory (listDirectory, createDirectoryIfMissing)
import System.FilePath ((</>), takeExtension, takeBaseName)

{- pokretanje programa:
:set -package directory
:set -package filepath
:l sir_model_simulation.hs
-}

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
          susjediTekst = dropWhile (== ' ') (drop 1 desniDio)
          listaSusjeda =
            if susjediTekst == "" then []
            else map read (words susjediTekst)

-- Novi zarazeni
odrediNoveZarazene :: [(Int, [Int])] -> Double -> [Int] -> [Int] -> IO [Int]
odrediNoveZarazene graf beta zdravi zarazeni = do
    noviZarazeni <- mapM (pokusajZaraze beta) potencijalniZarazeni
    return (concat noviZarazeni)
    where susjediZarazenih = concat [susjedi | (cvor, susjedi) <- graf, cvor `elem` zarazeni]
          potencijalniZarazeni = ukloniDuplikate [s | s <- susjediZarazenih, s `elem` zdravi]

pokusajZaraze :: Double -> Int -> IO [Int]
pokusajZaraze beta susjed = do
    randomBr <- randomRIO (0.0, 1.0)
    if randomBr < beta then return [susjed] else return []

ukloniDuplikate :: Eq a => [a] -> [a]
ukloniDuplikate = foldl (\xs x -> if x `elem` xs then xs else xs ++ [x]) []

-- Novi oporavljeni
odrediNoveOporavljene :: Double -> [Int] -> IO [Int]
odrediNoveOporavljene _ [] = return []
odrediNoveOporavljene gamma (cvor:ostatak) = do
    randomBr <- randomRIO (0.0,1.0)
    ostali <- odrediNoveOporavljene gamma ostatak
    if randomBr < gamma
        then return (cvor:ostali)
        else return ostali

-- Korak SIR modela
sirKorak :: [(Int, [Int])] -> Double -> Double -> Stanje -> IO Stanje
sirKorak graf beta gamma trenutnoStanje = do
    let zdravi = listaZdravih trenutnoStanje
    let zarazeni = listaZarazenih trenutnoStanje
    let oporavljeni = listaOporavljenih trenutnoStanje

    noviZarazeniSusjedi <- odrediNoveZarazene graf beta zdravi zarazeni
    noviOporavljeniCvorovi <- odrediNoveOporavljene gamma zarazeni

    let noviZdravi = zdravi \\ noviZarazeniSusjedi
    let noviZarazeni = [cvor | cvor <- zarazeni ++ noviZarazeniSusjedi, cvor `notElem` noviOporavljeniCvorovi]
    let noviOporavljeni = oporavljeni ++ noviOporavljeniCvorovi
    return (Stanje noviZdravi noviZarazeni noviOporavljeni)

-- Simulacija SIR modela
simuliraj :: [(Int, [Int])] -> Double -> Double -> Int -> Stanje -> [(Int, Int, Int)] -> IO [(Int, Int, Int)]
simuliraj _ _ _ 0 _ rezultati = return (reverse rezultati)
simuliraj graf beta gamma brojDana trenutnoStanje rezultati = do
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
    where zaglavlje = "Day,Susceptible,Infected,Recovered"
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