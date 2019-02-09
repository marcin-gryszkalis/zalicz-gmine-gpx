# zalicz-gmine-gpx

## Zalicz Gmine
http://zaliczgmine.pl/

## Requirements

* unpacked gminy.zip from https://gis-support.pl/granice-administracyjne/
* perl packages
    * Geo::ShapeFile 
    * Geo::Proj4
    * Geo::Gpx
    * LWP::UserAgent
    * Math::Polygon
    * Term::ReadKey
    * File::Slurp 

## Usage

```
% perl gpx2gminy.pl poznan-lodz.gpx
loading gminy
loading gpx
loading zg-teryt map
tracing: poznan-lodz
  # zgid jpt_op teryt   date       nazwa
  1 2289 827292 3064011 2018-07-05 Poznań
  2 2238 827178 3021011 2018-07-05 Luboń
  3 2209 827184 3021072 2018-07-05 Komorniki
  4 2253 827185 3021103 2018-07-05 Mosina
  5 2318 827199 3021143 2018-07-05 Stęszew
  6 2294 827177 3021021 2018-07-05 Puszczykowo
  7 2218 827189 3021093 2018-07-05 Kórnik
  8 2359 827232 3025052 2018-07-05 Zaniemyśl
  9 2225 827235 3025022 2018-07-05 Krzykosy
 10 2252 827270 3030023 2018-07-05 Miłosław
 11 2206 827271 3030012 2018-07-05 Kołaczkowo
 12 2295 827275 3030043 2018-07-05 Pyzdry
 13 2357 827231 3023083 2018-07-05 Zagórów
 14 2306 827378 3010082 2018-07-05 Rzgów
 15 2303 827376 3010073 2018-07-05 Rychwał
 16 2316 827380 3010112 2018-07-05 Stare Miasto
 17 2337 827254 3027073 2018-07-05 Tuliszków
 18 2350 827255 3027092 2018-07-05 Władysławów
 19 2339 827245 3027082 2018-07-05 Turek
 20 2338 827248 3027011 2018-07-05 Turek
 21 2293 827249 3027062 2018-07-05 Przykona
 22 2167 827251 3027033 2018-07-05 Dobra
 23  719 828731 1011022 2018-07-05 Pęczniew
 24  722 828724 1011033 2018-07-05 Poddębice
 25  774 828728 1011062 2018-07-05 Zadzim
 26  754 828800 1019023 2018-07-05 Szadek
 27  770 828656 1003052 2018-07-05 Wodzierady
 28  714 828700 1008072 2018-07-05 Pabianice
 29  694 828829 1061011 2018-07-05 Łódź
```

## Mass upload

### Prepare
```
% mkdir gpx reports
% cp /somewhere/files*.gpx gpx/
```

### Process GPX files
```
This script will process all gpx files in gpx/ that don't have corresponding .txt file in reports/
% perl process-all-gpxes.pl
processing: gpx/2018-12-31_13-33-12_3m.gpx -> reports/2018-12-31_13-33-12_3m.txt                                                                                                                        
loading gminy
loading gpx
loading zg-teryt map
tracing: 2018-12-31_13-33-12_3m
  # zgid jpt_op teryt   date       nazwa
  1 1655 828626 2262011 2018-12-31 Gdynia
  2 1726 827404 2264011 2018-12-31 Sopot
processing: gpx/2019-01-05_14-09-21_Afternoon_Ride_Cycling.gpx -> reports/2019-01-05_14-09-21_Afternoon_Ride_Cycling.txt                                                                                                                            
loading gminy
loading gpx
loading zg-teryt map
tracing: 2019-01-05_14-09-21_Afternoon_Ride_Cycling.tcx
  # zgid jpt_op teryt   date       nazwa
  1  694 828829 1061011 2019-01-05 Łódź
  2  737 828681 1006103 2019-01-05 Rzgów
```

### Merge reports
This script will process will take all .txt files from reports/, merge them and create summary in all-reports.txt (sorted by date)
```
% perl merge-all-reports.pl
processing: reports/2019-01-05_14-09-21_Afternoon_Ride_Cycling.txt
processing: reports/2018-12-31_13-33-12_3m.txt

% head all-reports.txt
694 2011-03-20 # Łódź
678 2011-03-26 # Ksawerów
737 2011-03-26 # Rzgów
759 2011-04-27 # Tuszyn
625 2011-06-03 # Brójce
```

### Post to zaliczgmine.pl
This script takes all-reports.txt and posts it to http://zaliczgmine.pl
```
% perl post-all-reports-to-zalicz-gmine.pl
zaliczgmine.pl username: marcin.g
zaliczgmine.pl password: 
user: marcin.g (473)
processing: 2011-03-26 - 678,737
```

