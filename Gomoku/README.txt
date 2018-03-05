1. Kompilację wykonujemy poleceniem :
    ghc -threaded -rtsopts -with-rtsopts=-N gomoku.hs -o gomoku

2. Uruchamiamy program za pomocą wygenerowanego pliku :
    gomoku.exe

3. Gracz podaje numer wiersza i kolumny do której chce wstawić kamyk.
    3a. kolumny są opisane literami jednak w programie podajemy liczbę z zakresu 1-19

4. Ruch AI zajmuje chwilę czasu.