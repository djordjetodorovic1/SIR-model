-- Korak SIR modela
sirKorak :: Double -> Double -> Double 
        -> (Double, Double, Double) 
        -> (Double, Double, Double)
sirKorak beta gamma n (s, i, r) = (s, i, r) -- uraditi
-- beta - stopa zaraze
-- gamma - stopa oporavka

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
toCSV results = "csv zapis" -- uraditi


-- Testiranje
runTest :: Double -> Double -> String -> IO ()
runTest beta gamma fileName = do
    writeFile fileName csvData
    putStrLn ("Sacuvan fajl: " ++ fileName)
    where brojCvorova = 1000
          brojDana = 160
          pocetnoStanje = (999, 1, 0)
          rezultati = simulacija brojDana beta gamma brojCvorova pocetnoStanje
          csvData = toCSV rezultati

main :: IO ()
main = do
    runTest 0.3 0.1 "sir_test1.csv"