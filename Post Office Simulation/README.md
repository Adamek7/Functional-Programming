Cele projektu:
Celem programu było zasymulowanie obsługi klientów na poczcie w języku Erlang. 
Każdy klient może mieć jedną z dwóch opcji do załatwienia na poczcie(nadanie/wysłanie paczki lub dokonanie wpłaty). Klienci są umieszczanie w jednej z dwóch kolejek w zależności od rodzaju sprawy do załatwienia. Każdy klient mas tez oszacowywany czas potrzebny do obsłużenia. Poczta jest otwarta od 8:00 do 16:00. Każda godzina na poczcie trwa 15 sekund.

Na poczcie są trzy okienka: 
Okienko 1 – obsługuje wpłaty, jest nieaktywne jeśli ilość oczekujących na dokonanie wpłaty jest mniejsza niż 10 oraz ma godzinną przerwę o 12:00
Okienko 2 – obsługuje paczki, jest nieaktywne jeśli ilość oczekujących na nadanie/odebranie paczki jest mniejsza niż 10 oraz ma godzinną przerwę o 13:00
Okienko 3 – obsługuje oba rodzaje spraw, jest zawsze aktywne w godzinach działania poczty, chyba że na poczcie nie ma żadnych klientów, ma godzinną przerwę o 14:00




Obsługa programu:

Uruchomienie środowiska Erlang
Kompilacja: c(poczta).
Uruchomienie: poczta:main(X). – gdzie X jest godziną od której zaczynamy symulacje
Zakończenie programu: Na ekranie wyświetla się informacja że po wpisaniu znaku „1” i kliknięciu Enter program zostanie zakończony
Działanie:
Podczas działania programu na ekranie pojawiają się informacje o aktualniej godzinie, o statusie każdego z okienek oraz ilość klientów oczekujących na obsługę.
W programie pracuje 9 procesów: 3 okienka, kontroler, zegar, generator klientów, proces odpowiedzialny za wyświetlanie, proces odpowiedzialny za zakończenie pozostałych procesów oraz proces zbierający statystyki symulacji.
W programie jest generator nowych klientów w zależności, który wysyła kolejkę do kontrolera. Kontroler w zależności od otrzymanej godziny oraz ilości klientów zarządza pracą okienek.
Po zakończeniu działania symulacji na ekranie pojawiają się statystyki o czasie trwania programu oraz o ilości obsłużonych klientów.

Możliwe rozszerzenia:

Obsługa wyjątków
Dodatkowe okienka
Więcej rodzajów spraw do załatwienia dla klientów
Więcej poleceń dla użytkownika
