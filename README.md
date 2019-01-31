# zalicz-gmine-gpx

# Requirements

* unpacked gminy.zip from https://gis-support.pl/granice-administracyjne/
* perl packages
    * Geo::ShapeFile 
    * Geo::Proj4
    * Geo::Gpx
 
# Usage

```
% perl gpx2gminy.pl poznan-lodz.gpx

loading gminy
loading gpx
tracing
  2225   827292  3064011  3064011 Poznań
  2156   827184  3021072  3021072 Komorniki
  2155   827178  3021011  3021011 Luboń
  2148   827183  3021052  3021052 Dopiewo
  2149   827199  3021143  3021143 Stęszew
  2157   827185  3021103  3021103 Mosina
  2170   827177  3021021  3021021 Puszczykowo
  2171   827189  3021093  3021093 Kórnik
  2177   827232  3025052  3025052 Zaniemyśl
  2186   827237  3025043  3025043 Środa Wielkopolska                                                                                  2181   827244  3026043  3026043 Śrem
  2187   827235  3025022  3025022 Krzykosy
  2184   827233  3025032  3025032 Nowe Miasto nad Wartą
  2217   827270  3030023  3030023 Miłosław
  2223   827271  3030012  3030012 Kołaczkowo                                                                                          2212   827275  3030043  3030043 Pyzdry
  2176   827231  3023083  3023083 Zagórów
  2195   827225  3023022  3023022 Lądek
  2231   827378  3010082  3010082 Rzgów
  2226   827376  3010073  3010073 Rychwał
  2294   827372  3010022  3010022 Grodziec
  2254   827380  3010112  3010112 Stare Miasto                                                                                        2205   827254  3027073  3027073 Tuliszków
  2202   827255  3027092  3027092 Władysławów
  2182   827245  3027082  3027082 Turek
  2192   827248  3027011  3027011 Turek
  2193   827249  3027062  3027062 Przykona                                                                                            2199   827251  3027033  3027033 Dobra
   427   828731  1011022  1011022 Pęczniew
   383   828724  1011033  1011033 Poddębice
   424   828728  1011062  1011062 Zadzim
   398   828800  1019023  1019023 Szadek
   468   828698  1008062  1008062 Lutomiersk
   382   828656  1003052  1003052 Wodzierady
   472   828700  1008072  1008072 Pabianice
   460   828695  1008021  1008021 Pabianice
   393   828829  1061011  1061011 Łódź

```
