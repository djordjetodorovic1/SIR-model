# Simulacija SIR epidemiološkog modela

## 1. Uvod

Jedan od najpoznatijih modela za opisivanje epidemija je `SIR model`, koji populaciju dijeli u tri osnovne kategorije: podložne infekciji, zaražene i oporavljene. Iako je model relativno jednostavan, on omogućava analizu osnovnih karakteristika širenja bolesti u populaciji.

U stvarnim društvenim sistemima kontakti između pojedinaca formiraju različite **mrežne strukture**. Zbog toga topologija mreže može imati značajan uticaj na dinamiku epidemije. Cilj ovog projekta je da se, korišćenjem programskog jezika *Haskell*, analizira kako različite mrežne strukture utiču na širenje infekcije u okviru SIR modela.

## 2. SIR epidemiološki model

SIR model dijeli populaciju na tri grupe:

* **`S` (Susceptible)** – osobe koje su podložne infekciji  
* **`I` (Infected)** – osobe koje su trenutno zaražene i mogu prenijeti bolest  
* **`R` (Recovered)** – osobe koje su se oporavile i stekle imunitet  

Tokom simulacije pojedinci prelaze iz jednog stanja u drugo prema sljedećim pravilima:

1. Podložna osoba može postati zaražena ako je povezana sa zaraženom osobom, zavisno od parametra `β` 
2. Zaražena osoba prelazi u stanje oporavljenih, zavisno od parametra `γ`
3. Oporavljena osoba više ne učestvuje u procesu infekcije

Prelazi između stanja određeni su parametrima:

* **`β` (beta)** – vjerovatnoća prenosa infekcije između zaraženog i podložnog čvora  
* **`γ` (gamma)** – vjerovatnoća oporavka zaraženog čvora

U mrežnim modelima širenje infekcije zavisi i od prosječnog broja veza po čvoru. Veća povezanost mreže ili veća vrijednost parametra `β` povećavaju vjerovatnoću da se epidemija proširi.

Takođe, dinamika zaraženih zavisi od odnosa **R₀ = β / γ**, poznatog kao **osnovni reprodukcioni broj** (basic reproduction number).  
R₀ predstavlja očekivani broj novih infekcija (R₀ > 1 - epidemija se širi).

## 3. Različite topologije mreže

U okviru ovog projekta simulacija je izvršena na nekoliko tipova mreža koje imaju različite strukturne karakteristike.

* **Random mreže (Erdős–Rényi)** – mreže u kojima se svaka dva čvora povezuju sa određenom vjerovatnoćom *p* (gustina grafa).
* **Grid mreže** – 2D mreže gdje je svaki čvor povezan sa najbližim susjedima.
* **Scale-free mreže (Barabási–Albert)** – imaju nekoliko čvorova sa velikim brojem veza (hub-ovi).  
* **Small-world mreže (Watts–Strogatz)** – uglavnom lokalne veze sa nekoliko dugih veza.  
* **Modularne mreže** – sastavljene od gustih modula sa slabim vezama između modula.
* **Homogene mreže** - kompletan graf.

## 4. Metodologija simulacije

Za potrebe eksperimenta generisano je više mreža sa približno istim brojem čvorova kako bi se omogućilo poređenje rezultata između različitih topologija.

Parametri simulacije:

| Parametar           | Vrijednost            |
| ------------------- | --------------------- |
| Trajanje simulacije | 100 vremenskih koraka |
| Početno zaraženih   | 1 čvor                |
| β (stopa infekcije) | 0.03 – 0.5            |
| γ (stopa oporavka)  | 0.1                   |

U svakom koraku:

* Zaraženi čvor može prenijeti infekciju na svoje susjede sa vjerovatnoćom `β`  
* Zaraženi čvor prelazi u stanje oporavljenih sa vjerovatnoćom `γ`

Tokom simulacije prati se broj čvorova u stanjima **`S`**, **`I`** i **`R`**.

## 5. Analiza rezultata

Rezultati simulacije prikazani su grafički, pokazujući promjene broja podložnih, zaraženih i oporavljenih čvorova tokom vremena u folderima oznacenim kao *rezultati_beta*, za vrijednosti `β`: 0.03, 0.05, 0.08, 0.1, 0.12, 0.2, 0.3 i 0.5.

Analizirani parametri:

* Broj zaraženih u određenom trenutku  
* Vrijeme dostizanja maksimuma epidemije  
* Ukupni broj zaraženih tokom epidemije  

Analizirani grafovi:

* **Random mreže (Erdős–Rényi)** – Za manju vrijednost *p* (manju gustinu grafa) i `β`, epidemija se često brzo ugasi, dok za veće vrijednosti infekcija se brzo širi i zahvata veliki dio mreže.
* **Grid mreže** – Epidemija se širi postepeno i sporo zbog kratkih lokalnih veza između susjednih čvorova.
* **Scale-free mreže (Barabási–Albert)** – Zaraza jednog hub-a može brzo proširiti epidemiju kroz mrežu, zavisno od gustine grafa i vrijednosti `β`.  
* **Small-world mreže (Watts–Strogatz)** – infekcija se širi sporo zbog većeg broja lokalnih veza, ali mali broj udaljenih veza omogućava "skok" broja zaraženih i brže širenje epidemije u odnosu na grid mrežu.
* **Modularne mreže** – Epidemija se brzo širi unutar modula, dok prelazak u druge module zavisi od `β` i međusobnih veza između modula.
* **Kompletne (homogene) mreže** - Epidemija se širi veoma brzo jer je svaki zaraženi čvor povezan sa svim ostalim čvorovima, a dinamika epidemije zavisi od parametra `β`.