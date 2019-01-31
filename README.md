# zalicz-gmine-gpx

## Zalicz Gmine
http://zaliczgmine.pl/

## Requirements

* unpacked gminy.zip from https://gis-support.pl/granice-administracyjne/
* perl packages
    * Geo::ShapeFile 
    * Geo::Proj4
    * Geo::Gpx
 
## Usage

```
% perl gpx2gminy.pl poznan-lodz.gpx
loading gminy
loading gpx
tracing
  1   2225 827292 3064011 Poznań
  2   2155 827178 3021011 Luboń
  3   2156 827184 3021072 Komorniki
  4   2157 827185 3021103 Mosina
  5   2149 827199 3021143 Stęszew
  6   2170 827177 3021021 Puszczykowo
  7   2171 827189 3021093 Kórnik
  8   2177 827232 3025052 Zaniemyśl
  9   2187 827235 3025022 Krzykosy
 10   2217 827270 3030023 Miłosław
 11   2223 827271 3030012 Kołaczkowo
 12   2212 827275 3030043 Pyzdry
 13   2176 827231 3023083 Zagórów
 14   2231 827378 3010082 Rzgów
 15   2226 827376 3010073 Rychwał
 16   2254 827380 3010112 Stare Miasto
 17   2205 827254 3027073 Tuliszków
 18   2202 827255 3027092 Władysławów
 19   2182 827245 3027082 Turek
 20   2192 827248 3027011 Turek
 21   2193 827249 3027062 Przykona
 22   2199 827251 3027033 Dobra
 23    427 828731 1011022 Pęczniew
 24    383 828724 1011033 Poddębice
 25    424 828728 1011062 Zadzim
 26    398 828800 1019023 Szadek
 27    382 828656 1003052 Wodzierady
 28    472 828700 1008072 Pabianice
 29    393 828829 1061011 Łódź

```
