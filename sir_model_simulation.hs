-- beta - stopa zaraze
-- gamma - stopa oporavka
-- R0 = beta/gamma (R0>1 - epidemija raste)

-- Korak SIR modela
sirKorak :: Double -> Double -> Double 
        -> (Double, Double, Double) 
        -> (Double, Double, Double)
sirKorak beta gamma n (s, i, r) = (s1, i1, r1)
    where novozarazeni = beta * s * i / n
          noviOporavljeni = gamma * i
          
          s1 = s - novozarazeni
          i1 = i + novozarazeni - noviOporavljeni
          r1 = r + noviOporavljeni

-- Simulacija SIR modela
simulacija :: Int -> Double -> Double -> Double
         -> (Double, Double, Double)    
         -> [(Double, Double, Double)]  
simulacija 0 _ _ _ _ = []               
simulacija brDana beta gamma brCvorova stanje = 
    novoStanje : simulacija (brDana - 1) beta gamma brCvorova novoStanje
    where novoStanje = sirKorak beta gamma brCvorova stanje

-- Pretvaranje rezultata u CSV
toCSV :: [(Double, Double, Double)] -> String
toCSV rezultati = zaglavlje ++ concat redovi
    where zaglavlje = "Day,Susceptible,Infected,Recovered\n"
          redovi = zipWith formatirajRed [1..] rezultati

formatirajRed :: Int -> (Double, Double, Double) -> String
formatirajRed dan (s, i, r) = 
    show dan ++ "," ++ show s ++ "," ++ show i ++ "," ++ show r ++ "\n"

-- Testiranje
runTest :: Double -> Double -> String -> IO ()
runTest beta gamma fileName = do
    writeFile fileName csvData
    where brojCvorova = 1000
          brojDana = 120
          pocetnoStanje = (999, 1, 0)
          rezultati = simulacija brojDana beta gamma brojCvorova pocetnoStanje
          csvData = toCSV rezultati

main :: IO ()
main = do
    runTest 0.05 0.1 (folder ++ "sir_case1.csv") -- broj zarazenih brzo opada 
    runTest 0.25 0.1 (folder ++ "sir_case2.csv") -- sporije sirenje zaraze
    runTest 0.5 0.1 (folder ++ "sir_case3.csv") -- brze sirenje zaraze
    runTest 0.7 0.1 (folder ++ "sir_case4.csv")
    runTest 0.7 0.2 (folder ++ "sir_case5.csv")
    runTest 0.5 0.5 (folder ++ "sir_case6.csv") -- R0 = 1 - granicni slucaj - sporo sirenje
    putStrLn "Testiranje zavrseno!"
    where folder = "rezultati1/"