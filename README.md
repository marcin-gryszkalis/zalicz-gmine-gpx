# zalicz-gmine-gpx

## Zalicz Gmine
https://zaliczgmine.pl/

## Requirements

* perl packages
    * Geo::ShapeFile
    * Geo::Gpx
    * LWP::UserAgent
    * Term::ReadKey
    * File::Slurp

## Usage

```
perl gpx2gminy.pl ride.gpx
loading gminy shapes
shapes: 2479
loading gpx: ride.gpx
tracing: Kwidzyn_Grudzi_dz_Che_mno
  # zgid date       nazwa
  1 1678 2025-07-20 Lichnowy
  2 1696 2025-07-20 Nowy Staw
  3 1688 2025-07-20 Malbork - gmina wiejska
  4 1687 2025-07-20 Malbork - gmina miejska
  5 1691 2025-07-20 Miłoradz
  6 1740 2025-07-20 Sztum
  7 1714 2025-07-20 Ryjewo
  8 1676 2025-07-20 Kwidzyn - gmina wiejska
  9 1675 2025-07-20 Kwidzyn - gmina miejska
 10 1716 2025-07-20 Sadlinki
 11  216 2025-07-20 Grudziądz - gmina wiejska
 12  274 2025-07-20 Rogóźno
 13  215 2025-07-20 Grudziądz - gmina miejska
 14  190 2025-07-20 Chełmno - gmina wiejska
 15  189 2025-07-20 Chełmno - gmina miejska
 16  285 2025-07-20 Stolno
 17  263 2025-07-20 Papowo Biskupie
 18  229 2025-07-20 Kijewo Królewskie
 19  297 2025-07-20 Unisław
 20  201 2025-07-20 Dąbrowa Chełmińska
 21  311 2025-07-20 Zławieś Wielka
 22  295 2025-07-20 Toruń
```

## Mass upload

### Prepare
```
% mkdir gpx reports
% cp /somewhere/files*.gpx gpx/
```

### Process GPX files
This script will process all gpx files in gpx/ that don't have corresponding .txt file in reports/
```
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
This script will process all .txt files from reports/, merge them and create summary in all-reports.txt (sorted by date)
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
This script takes all-reports.txt and posts it to https://zaliczgmine.pl
```
% perl post-all-reports-to-zalicz-gmine.pl
zaliczgmine.pl username: marcin.g
zaliczgmine.pl password:
user: marcin.g (473)
processing: 2011-03-26 - 678,737
```
