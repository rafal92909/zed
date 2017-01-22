# Śledzie
Rafal Meller 106450  
`r format(Sys.time(), '%d %B %Y')`  





# Podsumowanie
Analiza ma na celu odpowiedź na pytanie dlaczego rozmiar śledzia w pewnym momencie zaczął maleć. <br />
Analizowany zbiór danych zawiera prawie 53 tys. rekordóW, które zostały zebrane na przestrzeni ostatnich 60 lat. Niestyty, w przypadku aż 20% rekordów brakowało wartości niektórych atrybutów, które zostały uzupełnione wartościami średnimi danego atrybutu.<br />
W zbiorze występuje silna korelacja trzech par atrybutów (chel1 i lcop1, chel2 i lcop2, cumf i fbar). Ze względu na korelację, zbiór danych został odchudzony o trzy atrybuty (chel1,chel2, fbar).<br />
Następnie, wykonana została regresja, która przewiduje zmianę rozmiaru śledzia w czasie oraz przeprowadzona została analiza ważności atrybutów.
Analiza ta, pokazuje, że bezpośredni wpływ na spadek długości śledzia ma miesiąc połowu, a także dostępność określonych gatunkóW planktou (Calanus finmarchicus gat. 2 oraz widłonogów gat. 1) oraz temperatura wody zmierzona tuż przy jej powierzchni.


# Kod wyliczający wykorzystane biblioteki:


```r
library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)
library(mice)
library(knitr)
library(corrplot)
library(randomForest)
library(caret)
```



# Kod zapewniający powtarzalność wyników przy każdym uruchomieniu raportu na tych samych danych:


```r
set.seed(67)
```



# Kod pozwalający wczytać dane z pliku:


```r
sledzie <-read.csv("sledzie.csv", sep = ",", na.strings = "?", header = TRUE)
```



# Kod przetwarzający brakujące dane.



W zbiorze danych liczba wszystkich rekordów wynosi:

```
## [1] 52582
```
W zbiorze danych liczba rekordów, które zawierają wartość NA wynosi:

```
## [1] 10094
```
Nie możemy usunąć rekordów z wartościami pustymi ponieważ stanowią one prawie 20% całego zbioru.

```
## [1] "19.2 %"
```
Dane przedstawione poniżej pokazują ilość wartości NA w każdej z kolumn w procentach:

-------  -------
X        0 %    
length   0 %    
cfin1    3.01 % 
cfin2    2.92 % 
chel1    2.96 % 
chel2    2.96 % 
lcop1    3.14 % 
lcop2    3.03 % 
fbar     0 %    
recr     0 %    
cumf     0 %    
totaln   0 %    
sst      3.01 % 
sal      0 %    
xmonth   0 %    
nao      0 %    
-------  -------
<br /><br />
W kolumnach, w których występują wartości puste, ilość NA oscyluje w okolicach 3%, a więc nie ma potrzeby usuwania żadnej z kolumn z procesu analizy danych. 
<br />
Poniższy wykres przedstawia ilość wartości pustych w każdej z kolumn.

![](sledzie_files/figure-html/ile_na_wykres-1.png)<!-- -->
<br /><br /><br />Brakujące wartości zostaną uzupełnione przy użyciu funkcji mice należącej do pakietu mice. Funkcja zastępuje brakujące elementy wartością średnią kolumny, w której dana wartość pusta się znajduje. 





# Sekcja podsumowującą rozmiar zbioru i podstawowe statystyki.


           X             length         cfin1             cfin2             chel1            chel2            lcop1              lcop2             fbar             recr              cumf             totaln             sst             sal            xmonth            nao         
---  --------------  -------------  ----------------  ----------------  ---------------  ---------------  -----------------  ---------------  ---------------  ----------------  ----------------  ----------------  --------------  --------------  ---------------  -----------------
     Min.   :    0   Min.   :19.0   Min.   : 0.0000   Min.   : 0.0000   Min.   : 0.000   Min.   : 5.238   Min.   :  0.3074   Min.   : 7.849   Min.   :0.0680   Min.   : 140515   Min.   :0.06833   Min.   : 144137   Min.   :12.77   Min.   :35.40   Min.   : 1.000   Min.   :-4.89000 
     1st Qu.:13145   1st Qu.:24.0   1st Qu.: 0.0000   1st Qu.: 0.2778   1st Qu.: 2.469   1st Qu.:13.589   1st Qu.:  2.5479   1st Qu.:17.808   1st Qu.:0.2270   1st Qu.: 360061   1st Qu.:0.14809   1st Qu.: 306068   1st Qu.:13.63   1st Qu.:35.51   1st Qu.: 5.000   1st Qu.:-1.89000 
     Median :26291   Median :25.5   Median : 0.1333   Median : 0.7012   Median : 6.083   Median :21.435   Median :  7.1229   Median :25.338   Median :0.3320   Median : 421391   Median :0.23191   Median : 539558   Median :13.86   Median :35.51   Median : 8.000   Median : 0.20000 
     Mean   :26291   Mean   :25.3   Mean   : 0.4458   Mean   : 2.0248   Mean   :10.006   Mean   :21.221   Mean   : 12.8108   Mean   :28.419   Mean   :0.3304   Mean   : 520367   Mean   :0.22981   Mean   : 514973   Mean   :13.87   Mean   :35.51   Mean   : 7.258   Mean   :-0.09236 
     3rd Qu.:39436   3rd Qu.:26.5   3rd Qu.: 0.3603   3rd Qu.: 1.9973   3rd Qu.:11.500   3rd Qu.:27.193   3rd Qu.: 21.2315   3rd Qu.:37.232   3rd Qu.:0.4560   3rd Qu.: 724151   3rd Qu.:0.29803   3rd Qu.: 730351   3rd Qu.:14.16   3rd Qu.:35.52   3rd Qu.: 9.000   3rd Qu.: 1.63000 
     Max.   :52581   Max.   :32.5   Max.   :37.6667   Max.   :19.3958   Max.   :75.000   Max.   :57.706   Max.   :115.5833   Max.   :68.736   Max.   :0.8490   Max.   :1565890   Max.   :0.39801   Max.   :1015595   Max.   :14.73   Max.   :35.61   Max.   :12.000   Max.   : 5.08000 



# Analiza atrybutów

Zbiór danych składa się z 15 atrybutów. Opisują one:
<ul>
<li>długość złowionego śledzia (length),</li>
<li>dostępność planktonu (cfin1, cfin2, chel1, chel2, lcop1, lcop2),</li>
<li>narybek (fbar, recr, cumf),</li>
<li>łączną liczbę złowionych ryb w ramach połowu (totaln)</li>
<li>wodę (sst, sal, nao),</li>
<li>miesiąc połowu (xmonth).</li>
</ul>



# Sekcja sprawdzająca korelacje między zmiennymi
 
![](sledzie_files/figure-html/unnamed-chunk-6-1.png)<!-- -->
<br /><br />
![](sledzie_files/figure-html/unnamed-chunk-7-1.png)<!-- -->
<br /><br />
![](sledzie_files/figure-html/unnamed-chunk-8-1.png)<!-- -->
<br /><br />
![](sledzie_files/figure-html/unnamed-chunk-9-1.png)<!-- -->
<br /><br />
 Z powyższych wykresów można zaobserwować, że najbardziej skorelowanyne ze sobą są pary atrybutów:
 <ul>
 <li>chel1 i lcop1</li>
 <li>chel2 i lcop2</li>
 <li>fbar i cumf</li>
 </ul>
 
 Na tej podstawie możemy usunąć trzy atrybuty (chel1, chel2, fbar) z przetwarzanego zbioru danych/

 

 
# Zmiana rozmiaru śledzia w czasie - wykres interaktywny

<!--html_preserve--><div id="htmlwidget-0fb278240514a02d61d0" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-0fb278240514a02d61d0">{"x":{"data":[{"x":[0,665.582278481013,1331.16455696203,1996.74683544304,2662.32911392405,3327.91139240506,3993.49367088608,4659.07594936709,5324.6582278481,5990.24050632911,6655.82278481013,7321.40506329114,7986.98734177215,8652.56962025316,9318.15189873418,9983.73417721519,10649.3164556962,11314.8987341772,11980.4810126582,12646.0632911392,13311.6455696203,13977.2278481013,14642.8101265823,15308.3924050633,15973.9746835443,16639.5569620253,17305.1392405063,17970.7215189873,18636.3037974684,19301.8860759494,19967.4683544304,20633.0506329114,21298.6329113924,21964.2151898734,22629.7974683544,23295.3797468354,23960.9620253165,24626.5443037975,25292.1265822785,25957.7088607595,26623.2911392405,27288.8734177215,27954.4556962025,28620.0379746835,29285.6202531646,29951.2025316456,30616.7848101266,31282.3670886076,31947.9493670886,32613.5316455696,33279.1139240506,33944.6962025316,34610.2784810127,35275.8607594937,35941.4430379747,36607.0253164557,37272.6075949367,37938.1898734177,38603.7721518987,39269.3544303797,39934.9367088608,40600.5189873418,41266.1012658228,41931.6835443038,42597.2658227848,43262.8481012658,43928.4303797468,44594.0126582278,45259.5949367089,45925.1772151899,46590.7594936709,47256.3417721519,47921.9240506329,48587.5063291139,49253.0886075949,49918.6708860759,50584.253164557,51249.835443038,51915.417721519,52581],"y":[24.3992315080778,24.5291695130141,24.6580145649872,24.7846737110339,24.9080539981911,25.0270624734954,25.1406061839839,25.2475921766931,25.34692749866,25.437526041801,25.5194131353754,25.5949447901831,25.6667704912415,25.737539723568,25.8099019721802,25.8865067220954,25.9700034583312,26.0630416659048,26.168131928154,26.2835722009096,26.4027901998548,26.51894234833,26.6251850696753,26.7146747872309,26.780567924337,26.8160209043336,26.8141901505611,26.7690500740793,26.6840841931912,26.5689109340982,26.4332509714667,26.2868249799631,26.139353634254,26.0005576090058,25.8801575788848,25.7878742185575,25.7314065211486,25.7071407500615,25.7075303663256,25.7250248823732,25.7520738106369,25.7811266635492,25.8046329535424,25.8150421930491,25.8048066306038,25.7691036724492,25.7109496573914,25.6347618085204,25.5449573489258,25.4459535016977,25.3421674899257,25.2380165366998,25.1379178651098,25.0462492015808,24.9650184726597,24.892560415082,24.8268937922657,24.7660373676291,24.7080099045905,24.6508301665681,24.5925169169802,24.5310889192449,24.464686109255,24.393623711165,24.320098515313,24.246369352344,24.1746950529031,24.1073344476353,24.0465463671856,23.9945896421992,23.953723103321,23.9259047080662,23.9107029725339,23.9065469545268,23.9118586943984,23.9250602325023,23.944573609192,23.968820864821,23.9962240397429,24.0252051743113],"text":["X: 0<br>length: 24.4","X: 665.58<br>length: 24.53","X: 1331.16<br>length: 24.66","X: 1996.75<br>length: 24.78","X: 2662.33<br>length: 24.91","X: 3327.91<br>length: 25.03","X: 3993.49<br>length: 25.14","X: 4659.08<br>length: 25.25","X: 5324.66<br>length: 25.35","X: 5990.24<br>length: 25.44","X: 6655.82<br>length: 25.52","X: 7321.41<br>length: 25.59","X: 7986.99<br>length: 25.67","X: 8652.57<br>length: 25.74","X: 9318.15<br>length: 25.81","X: 9983.73<br>length: 25.89","X: 10649.32<br>length: 25.97","X: 11314.9<br>length: 26.06","X: 11980.48<br>length: 26.17","X: 12646.06<br>length: 26.28","X: 13311.65<br>length: 26.4","X: 13977.23<br>length: 26.52","X: 14642.81<br>length: 26.63","X: 15308.39<br>length: 26.71","X: 15973.97<br>length: 26.78","X: 16639.56<br>length: 26.82","X: 17305.14<br>length: 26.81","X: 17970.72<br>length: 26.77","X: 18636.3<br>length: 26.68","X: 19301.89<br>length: 26.57","X: 19967.47<br>length: 26.43","X: 20633.05<br>length: 26.29","X: 21298.63<br>length: 26.14","X: 21964.22<br>length: 26","X: 22629.8<br>length: 25.88","X: 23295.38<br>length: 25.79","X: 23960.96<br>length: 25.73","X: 24626.54<br>length: 25.71","X: 25292.13<br>length: 25.71","X: 25957.71<br>length: 25.73","X: 26623.29<br>length: 25.75","X: 27288.87<br>length: 25.78","X: 27954.46<br>length: 25.8","X: 28620.04<br>length: 25.82","X: 29285.62<br>length: 25.8","X: 29951.2<br>length: 25.77","X: 30616.78<br>length: 25.71","X: 31282.37<br>length: 25.63","X: 31947.95<br>length: 25.54","X: 32613.53<br>length: 25.45","X: 33279.11<br>length: 25.34","X: 33944.7<br>length: 25.24","X: 34610.28<br>length: 25.14","X: 35275.86<br>length: 25.05","X: 35941.44<br>length: 24.97","X: 36607.03<br>length: 24.89","X: 37272.61<br>length: 24.83","X: 37938.19<br>length: 24.77","X: 38603.77<br>length: 24.71","X: 39269.35<br>length: 24.65","X: 39934.94<br>length: 24.59","X: 40600.52<br>length: 24.53","X: 41266.1<br>length: 24.46","X: 41931.68<br>length: 24.39","X: 42597.27<br>length: 24.32","X: 43262.85<br>length: 24.25","X: 43928.43<br>length: 24.17","X: 44594.01<br>length: 24.11","X: 45259.59<br>length: 24.05","X: 45925.18<br>length: 23.99","X: 46590.76<br>length: 23.95","X: 47256.34<br>length: 23.93","X: 47921.92<br>length: 23.91","X: 48587.51<br>length: 23.91","X: 49253.09<br>length: 23.91","X: 49918.67<br>length: 23.93","X: 50584.25<br>length: 23.94","X: 51249.84<br>length: 23.97","X: 51915.42<br>length: 24","X: 52581<br>length: 24.03"],"key":null,"type":"scatter","mode":"lines","name":"fitted values","line":{"width":3.77952755905512,"color":"rgba(51,102,255,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text"},{"x":[0,665.582278481013,1331.16455696203,1996.74683544304,2662.32911392405,3327.91139240506,3993.49367088608,4659.07594936709,5324.6582278481,5990.24050632911,6655.82278481013,7321.40506329114,7986.98734177215,8652.56962025316,9318.15189873418,9983.73417721519,10649.3164556962,11314.8987341772,11980.4810126582,12646.0632911392,13311.6455696203,13977.2278481013,14642.8101265823,15308.3924050633,15973.9746835443,16639.5569620253,17305.1392405063,17970.7215189873,18636.3037974684,19301.8860759494,19967.4683544304,20633.0506329114,21298.6329113924,21964.2151898734,22629.7974683544,23295.3797468354,23960.9620253165,24626.5443037975,25292.1265822785,25957.7088607595,26623.2911392405,27288.8734177215,27954.4556962025,28620.0379746835,29285.6202531646,29951.2025316456,30616.7848101266,31282.3670886076,31947.9493670886,32613.5316455696,33279.1139240506,33944.6962025316,34610.2784810127,35275.8607594937,35941.4430379747,36607.0253164557,37272.6075949367,37938.1898734177,38603.7721518987,39269.3544303797,39934.9367088608,40600.5189873418,41266.1012658228,41931.6835443038,42597.2658227848,43262.8481012658,43928.4303797468,44594.0126582278,45259.5949367089,45925.1772151899,46590.7594936709,47256.3417721519,47921.9240506329,48587.5063291139,49253.0886075949,49918.6708860759,50584.253164557,51249.835443038,51915.417721519,52581,52581,52581,51915.417721519,51249.835443038,50584.253164557,49918.6708860759,49253.0886075949,48587.5063291139,47921.9240506329,47256.3417721519,46590.7594936709,45925.1772151899,45259.5949367089,44594.0126582278,43928.4303797468,43262.8481012658,42597.2658227848,41931.6835443038,41266.1012658228,40600.5189873418,39934.9367088608,39269.3544303797,38603.7721518987,37938.1898734177,37272.6075949367,36607.0253164557,35941.4430379747,35275.8607594937,34610.2784810127,33944.6962025316,33279.1139240506,32613.5316455696,31947.9493670886,31282.3670886076,30616.7848101266,29951.2025316456,29285.6202531646,28620.0379746835,27954.4556962025,27288.8734177215,26623.2911392405,25957.7088607595,25292.1265822785,24626.5443037975,23960.9620253165,23295.3797468354,22629.7974683544,21964.2151898734,21298.6329113924,20633.0506329114,19967.4683544304,19301.8860759494,18636.3037974684,17970.7215189873,17305.1392405063,16639.5569620253,15973.9746835443,15308.3924050633,14642.8101265823,13977.2278481013,13311.6455696203,12646.0632911392,11980.4810126582,11314.8987341772,10649.3164556962,9983.73417721519,9318.15189873418,8652.56962025316,7986.98734177215,7321.40506329114,6655.82278481013,5990.24050632911,5324.6582278481,4659.07594936709,3993.49367088608,3327.91139240506,2662.32911392405,1996.74683544304,1331.16455696203,665.582278481013,0,0],"y":[24.3267572614693,24.4694144173589,24.6094261727919,24.7446867415255,24.8730725185675,24.9932429141026,25.1052771170574,25.2099174111257,25.307560913968,25.3980255609111,25.4814740743594,25.5594773227311,25.6335951380404,25.705423330634,25.7770946406164,25.8516325066158,25.9326907901676,26.0240323448498,26.1290560693297,26.2461050885989,26.3677303697169,26.4859672918042,26.5929561317124,26.6814637429857,26.7451542865894,26.7782433008728,26.7749895069232,26.7301708303241,26.6470639783324,26.5343260299747,26.4005421128618,26.2545012055366,26.1057212324086,25.9645933349922,25.8419458258615,25.74856996041,25.6928219085671,25.6706339701544,25.673435440602,25.692543357869,25.7195922861327,25.7470317378237,25.7681261736266,25.7764575804466,25.7655023724179,25.730891919367,25.6749853832995,25.6011294065835,25.5126335744066,25.4132446430102,25.3075825857324,25.2009963217769,25.0990386212849,25.00704855786,24.9272408691099,24.8571467772711,24.7936827480366,24.7338084298149,24.6750348483581,24.6157703368243,24.5550498050864,24.4920130607714,24.4256767883961,24.3563110429851,24.2852242996068,24.213562020416,24.142578659594,24.074159094157,24.011078899572,23.9566505810656,23.9142226222466,23.8865381230361,23.8730282065172,23.8712178873297,23.8780391355504,23.890078755065,23.9045866440048,23.9202324790763,23.9364689524828,23.9527309378781,23.9527309378781,24.0976794107445,24.055979127003,24.0174092505656,23.9845605743791,23.9600417099395,23.9456782532465,23.9418760217239,23.9483777385506,23.9652712930962,23.9932235843953,24.0325287033327,24.0820138347993,24.1405098011136,24.2068114462122,24.2791766842721,24.3549727310193,24.430936379345,24.503695430114,24.5701647777184,24.6299840288739,24.6858899963119,24.7409849608229,24.7982663054433,24.8601048364947,24.9279740528928,25.0027960762096,25.0854498453017,25.1767971089346,25.2750367516227,25.3767523941191,25.4786623603852,25.5772811234451,25.6683942104573,25.7469139314834,25.8073154255314,25.8441108887897,25.8536268056515,25.8411397334582,25.8152215892746,25.7845553351411,25.7575064068775,25.7416252920492,25.7436475299687,25.76999113373,25.827178476705,25.918369331908,26.0365218830193,26.1729860360995,26.3191487543897,26.4659598300716,26.6034958382217,26.72110440805,26.8079293178346,26.853390794199,26.8537985077944,26.8159815620845,26.7478858314761,26.6574140076383,26.5519174048558,26.4378500299928,26.3210393132202,26.2072077869784,26.1020509869599,26.0073161264947,25.9213809375751,25.8427093037441,25.7696561165021,25.6999458444426,25.6304122576351,25.5573521963914,25.477026522691,25.386294083352,25.2852669422605,25.1759352509103,25.0608820328883,24.9430354778147,24.8246606805424,24.7066029571825,24.5889246086693,24.4717057546863,24.3267572614693],"text":["X: 0<br>length: 24.4","X: 665.58<br>length: 24.53","X: 1331.16<br>length: 24.66","X: 1996.75<br>length: 24.78","X: 2662.33<br>length: 24.91","X: 3327.91<br>length: 25.03","X: 3993.49<br>length: 25.14","X: 4659.08<br>length: 25.25","X: 5324.66<br>length: 25.35","X: 5990.24<br>length: 25.44","X: 6655.82<br>length: 25.52","X: 7321.41<br>length: 25.59","X: 7986.99<br>length: 25.67","X: 8652.57<br>length: 25.74","X: 9318.15<br>length: 25.81","X: 9983.73<br>length: 25.89","X: 10649.32<br>length: 25.97","X: 11314.9<br>length: 26.06","X: 11980.48<br>length: 26.17","X: 12646.06<br>length: 26.28","X: 13311.65<br>length: 26.4","X: 13977.23<br>length: 26.52","X: 14642.81<br>length: 26.63","X: 15308.39<br>length: 26.71","X: 15973.97<br>length: 26.78","X: 16639.56<br>length: 26.82","X: 17305.14<br>length: 26.81","X: 17970.72<br>length: 26.77","X: 18636.3<br>length: 26.68","X: 19301.89<br>length: 26.57","X: 19967.47<br>length: 26.43","X: 20633.05<br>length: 26.29","X: 21298.63<br>length: 26.14","X: 21964.22<br>length: 26","X: 22629.8<br>length: 25.88","X: 23295.38<br>length: 25.79","X: 23960.96<br>length: 25.73","X: 24626.54<br>length: 25.71","X: 25292.13<br>length: 25.71","X: 25957.71<br>length: 25.73","X: 26623.29<br>length: 25.75","X: 27288.87<br>length: 25.78","X: 27954.46<br>length: 25.8","X: 28620.04<br>length: 25.82","X: 29285.62<br>length: 25.8","X: 29951.2<br>length: 25.77","X: 30616.78<br>length: 25.71","X: 31282.37<br>length: 25.63","X: 31947.95<br>length: 25.54","X: 32613.53<br>length: 25.45","X: 33279.11<br>length: 25.34","X: 33944.7<br>length: 25.24","X: 34610.28<br>length: 25.14","X: 35275.86<br>length: 25.05","X: 35941.44<br>length: 24.97","X: 36607.03<br>length: 24.89","X: 37272.61<br>length: 24.83","X: 37938.19<br>length: 24.77","X: 38603.77<br>length: 24.71","X: 39269.35<br>length: 24.65","X: 39934.94<br>length: 24.59","X: 40600.52<br>length: 24.53","X: 41266.1<br>length: 24.46","X: 41931.68<br>length: 24.39","X: 42597.27<br>length: 24.32","X: 43262.85<br>length: 24.25","X: 43928.43<br>length: 24.17","X: 44594.01<br>length: 24.11","X: 45259.59<br>length: 24.05","X: 45925.18<br>length: 23.99","X: 46590.76<br>length: 23.95","X: 47256.34<br>length: 23.93","X: 47921.92<br>length: 23.91","X: 48587.51<br>length: 23.91","X: 49253.09<br>length: 23.91","X: 49918.67<br>length: 23.93","X: 50584.25<br>length: 23.94","X: 51249.84<br>length: 23.97","X: 51915.42<br>length: 24","X: 52581<br>length: 24.03","X: 52581<br>length: 24.03","X: 52581<br>length: 24.03","X: 51915.42<br>length: 24","X: 51249.84<br>length: 23.97","X: 50584.25<br>length: 23.94","X: 49918.67<br>length: 23.93","X: 49253.09<br>length: 23.91","X: 48587.51<br>length: 23.91","X: 47921.92<br>length: 23.91","X: 47256.34<br>length: 23.93","X: 46590.76<br>length: 23.95","X: 45925.18<br>length: 23.99","X: 45259.59<br>length: 24.05","X: 44594.01<br>length: 24.11","X: 43928.43<br>length: 24.17","X: 43262.85<br>length: 24.25","X: 42597.27<br>length: 24.32","X: 41931.68<br>length: 24.39","X: 41266.1<br>length: 24.46","X: 40600.52<br>length: 24.53","X: 39934.94<br>length: 24.59","X: 39269.35<br>length: 24.65","X: 38603.77<br>length: 24.71","X: 37938.19<br>length: 24.77","X: 37272.61<br>length: 24.83","X: 36607.03<br>length: 24.89","X: 35941.44<br>length: 24.97","X: 35275.86<br>length: 25.05","X: 34610.28<br>length: 25.14","X: 33944.7<br>length: 25.24","X: 33279.11<br>length: 25.34","X: 32613.53<br>length: 25.45","X: 31947.95<br>length: 25.54","X: 31282.37<br>length: 25.63","X: 30616.78<br>length: 25.71","X: 29951.2<br>length: 25.77","X: 29285.62<br>length: 25.8","X: 28620.04<br>length: 25.82","X: 27954.46<br>length: 25.8","X: 27288.87<br>length: 25.78","X: 26623.29<br>length: 25.75","X: 25957.71<br>length: 25.73","X: 25292.13<br>length: 25.71","X: 24626.54<br>length: 25.71","X: 23960.96<br>length: 25.73","X: 23295.38<br>length: 25.79","X: 22629.8<br>length: 25.88","X: 21964.22<br>length: 26","X: 21298.63<br>length: 26.14","X: 20633.05<br>length: 26.29","X: 19967.47<br>length: 26.43","X: 19301.89<br>length: 26.57","X: 18636.3<br>length: 26.68","X: 17970.72<br>length: 26.77","X: 17305.14<br>length: 26.81","X: 16639.56<br>length: 26.82","X: 15973.97<br>length: 26.78","X: 15308.39<br>length: 26.71","X: 14642.81<br>length: 26.63","X: 13977.23<br>length: 26.52","X: 13311.65<br>length: 26.4","X: 12646.06<br>length: 26.28","X: 11980.48<br>length: 26.17","X: 11314.9<br>length: 26.06","X: 10649.32<br>length: 25.97","X: 9983.73<br>length: 25.89","X: 9318.15<br>length: 25.81","X: 8652.57<br>length: 25.74","X: 7986.99<br>length: 25.67","X: 7321.41<br>length: 25.59","X: 6655.82<br>length: 25.52","X: 5990.24<br>length: 25.44","X: 5324.66<br>length: 25.35","X: 4659.08<br>length: 25.25","X: 3993.49<br>length: 25.14","X: 3327.91<br>length: 25.03","X: 2662.33<br>length: 24.91","X: 1996.75<br>length: 24.78","X: 1331.16<br>length: 24.66","X: 665.58<br>length: 24.53","X: 0<br>length: 24.4","X: 0<br>length: 24.4"],"key":null,"type":"scatter","mode":"lines","line":{"width":3.77952755905512,"color":"transparent","dash":"solid"},"fill":"toself","fillcolor":"rgba(153,153,153,0.4)","hoveron":"points","hoverinfo":"x+y","showlegend":false,"xaxis":"x","yaxis":"y","name":""}],"layout":{"margin":{"t":43.7625570776256,"r":7.30593607305936,"b":40.1826484018265,"l":37.2602739726027},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"title":"Zmiana rozmiaru śledzia w czasie","titlefont":{"color":"rgba(0,0,0,1)","family":"","size":17.5342465753425},"xaxis":{"domain":[0,1],"type":"linear","autorange":false,"tickmode":"array","range":[-2629.05,55210.05],"ticktext":["0","10000","20000","30000","40000","50000"],"tickvals":[0,10000,20000,30000,40000,50000],"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"y","title":"Czas","titlefont":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"type":"linear","autorange":false,"tickmode":"array","range":[23.7220888563065,27.0029275388176],"ticktext":["24","25","26","27"],"tickvals":[24,25,26,27],"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"x","title":"Rozmiar śledzia [cm]","titlefont":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(51,51,51,1)","width":0.66417600664176,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895}},"hovermode":"closest"},"source":"A","config":{"modeBarButtonsToAdd":[{"name":"Collaborate","icon":{"width":1000,"ascent":500,"descent":-50,"path":"M487 375c7-10 9-23 5-36l-79-259c-3-12-11-23-22-31-11-8-22-12-35-12l-263 0c-15 0-29 5-43 15-13 10-23 23-28 37-5 13-5 25-1 37 0 0 0 3 1 7 1 5 1 8 1 11 0 2 0 4-1 6 0 3-1 5-1 6 1 2 2 4 3 6 1 2 2 4 4 6 2 3 4 5 5 7 5 7 9 16 13 26 4 10 7 19 9 26 0 2 0 5 0 9-1 4-1 6 0 8 0 2 2 5 4 8 3 3 5 5 5 7 4 6 8 15 12 26 4 11 7 19 7 26 1 1 0 4 0 9-1 4-1 7 0 8 1 2 3 5 6 8 4 4 6 6 6 7 4 5 8 13 13 24 4 11 7 20 7 28 1 1 0 4 0 7-1 3-1 6-1 7 0 2 1 4 3 6 1 1 3 4 5 6 2 3 3 5 5 6 1 2 3 5 4 9 2 3 3 7 5 10 1 3 2 6 4 10 2 4 4 7 6 9 2 3 4 5 7 7 3 2 7 3 11 3 3 0 8 0 13-1l0-1c7 2 12 2 14 2l218 0c14 0 25-5 32-16 8-10 10-23 6-37l-79-259c-7-22-13-37-20-43-7-7-19-10-37-10l-248 0c-5 0-9-2-11-5-2-3-2-7 0-12 4-13 18-20 41-20l264 0c5 0 10 2 16 5 5 3 8 6 10 11l85 282c2 5 2 10 2 17 7-3 13-7 17-13z m-304 0c-1-3-1-5 0-7 1-1 3-2 6-2l174 0c2 0 4 1 7 2 2 2 4 4 5 7l6 18c0 3 0 5-1 7-1 1-3 2-6 2l-173 0c-3 0-5-1-8-2-2-2-4-4-4-7z m-24-73c-1-3-1-5 0-7 2-2 3-2 6-2l174 0c2 0 5 0 7 2 3 2 4 4 5 7l6 18c1 2 0 5-1 6-1 2-3 3-5 3l-174 0c-3 0-5-1-7-3-3-1-4-4-5-6z"},"click":"function(gd) { \n        // is this being viewed in RStudio?\n        if (location.search == '?viewer_pane=1') {\n          alert('To learn about plotly for collaboration, visit:\\n https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html');\n        } else {\n          window.open('https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html', '_blank');\n        }\n      }"}],"modeBarButtonsToRemove":["sendDataToCloud"]},"base_url":"https://plot.ly"},"evals":["config.modeBarButtonsToAdd.0.click"],"jsHooks":[]}</script><!--/html_preserve-->



# Regresor przewidujący rozmiar śledzia

W naszym przypadku regresja ma za zadanie stworzyć model, który będzie przewidywał długość śledzi w czasie.
Dane wejścopwe są oczyszczone z wartości pustych, a atrybuty chel1,chel2, fbar usunięte, ze względu na silną korelację.
Zbiór danych podzielony został na dane uczące, walidujące i testowe.
Tak przygotowe dane zostaną poddane procesowi uczenia przy pomocy algorytmu random forest.

<br />
Trafność rekgrasji została oszacowana na podstawie miar R<sup>2</sup> i RMSE.

---------  ----------
RMSE        1.1627559
Rsquared    0.5132303
---------  ----------
<br /><br /><br />
Poniższy wykres przedstawia przewidywaną zmianę długości śledzia w czasie.
![](sledzie_files/figure-html/regresja_wykres-1.png)<!-- -->



# Analiza ważności atrybutów 

Analiza ważności atrybutóW dowodzi, że największy wpływ na spadek długości śledzia ma miesiąc połowu. Znaczący wpływa ma również dostępność planktonów Calanus finmarchicus gat. 2 oraz widłonogów gat. 1, a także temperatura przy powiedzchni wody. <br />Natomiast na długość śledzia nie ma wpływu roczny narybek ani oscylacja północnoatlantycka. Reszta atrybutów ma znikomy wpływ.

```
## rf variable importance
## 
##        Overall
## xmonth 100.000
## cfin2   27.299
## sst     19.903
## lcop2   19.400
## lcop1    9.163
## totaln   8.672
## sal      3.365
## cfin1    2.845
## cumf     1.035
## nao      0.308
## recr     0.000
```

![](sledzie_files/figure-html/waznosc-1.png)<!-- -->
