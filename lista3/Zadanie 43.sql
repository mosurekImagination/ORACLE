-- Zadanie 43
--
-- Napisać blok, który zrealizuje zad. 33 w sposób uniwersalny
-- (bez konieczności uwzględniania wiedzy o funkcjach pełnionych przez koty).
--
-- -- Zadanie 33
-- -- Napisać zapytanie, w ramach którego obliczone zostaną
-- -- sumy całkowitego spożycia myszy przez koty sprawujące każdą z funkcji
-- -- z podziałem na bandy i płcie kotów.
-- -- Podsumować przydziały dla każdej z funkcji. 

DECLARE
  CURSOR curFunkcje IS
    SELECT DISTINCT Funkcje.funkcja
    FROM Kocury
    LEFT JOIN Funkcje ON Kocury.funkcja = Funkcje.funkcja;
  CURSOR curBandy IS
    SELECT DISTINCT Bandy.nr_bandy, Bandy.nazwa
    FROM Kocury
    LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy;
  plec Kocury.plec%TYPE;
  ile NUMBER;
BEGIN
  DBMS_OUTPUT.PUT(RPAD('NAZWA BANDY', 20) || RPAD('PLEC', 7) || RPAD('ILE', 5));
  FOR funkcja IN curFunkcje LOOP
      DBMS_OUTPUT.PUT(RPAD(funkcja.funkcja, 10));
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(RPAD('SUMA', 10));
  DBMS_OUTPUT.PUT(LPAD(' ', 20, '-') || LPAD(' ', 7, '-') || LPAD(' ', 5, '-'));
  FOR funkcja IN curFunkcje LOOP
      DBMS_OUTPUT.PUT(' ---------');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ---------');
  
  FOR banda IN curBandy LOOP
      DBMS_OUTPUT.PUT(RPAD(banda.nazwa, 20));
      FOR i IN 1..2 LOOP
        IF i = 1 THEN
          plec := 'D';
          DBMS_OUTPUT.PUT(RPAD('Kotka',7));
        ELSE
          plec := 'M';
          DBMS_OUTPUT.PUT(RPAD(' ',20));
          DBMS_OUTPUT.PUT(RPAD('Kocur',7));
        END IF;
        
        SELECT COUNT(*) INTO ile
        FROM Kocury
        WHERE Kocury.nr_bandy = banda.nr_bandy
          AND Kocury.plec = plec;
          
        DBMS_OUTPUT.PUT(LPAD(ile || ' ',5));
        FOR funkcja IN curFunkcje LOOP
          SELECT SUM ( CASE
            WHEN Kocury.funkcja = funkcja.funkcja THEN NVL(przydzial_myszy,0) + NVL(myszy_extra,0)
            ELSE 0
            END ) INTO ile
          FROM Kocury
          WHERE Kocury.nr_bandy = banda.nr_bandy
            AND Kocury.plec = plec;
          DBMS_OUTPUT.PUT(LPAD(ile || ' ',10));
        END LOOP;
            
        SELECT SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) INTO ile
        FROM Kocury
        WHERE Kocury.nr_bandy = banda.nr_bandy
          AND Kocury.plec = plec;
        
        DBMS_OUTPUT.PUT(LPAD(ile || ' ',10));
        DBMS_OUTPUT.PUT_LINE('');
      END LOOP; -- FOR i IN 1..2
  END LOOP; -- FOR banda IN curBandy
  DBMS_OUTPUT.PUT('Z' || LPAD(' ', 19, '-') || LPAD(' ', 7, '-') || LPAD(' ', 5, '-'));
  FOR funkcja IN curFunkcje LOOP
        DBMS_OUTPUT.PUT(LPAD(' ', 10, '-'));
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE(LPAD(' ', 10, '-'));
  DBMS_OUTPUT.PUT(RPAD('ZJADA RAZEM', 20) || LPAD(' ', 7) || LPAD(' ', 5));
  
  FOR funkcja IN curFunkcje LOOP
    SELECT SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) INTO ile
    FROM Kocury WHERE Kocury.funkcja = funkcja.funkcja;
    
    DBMS_OUTPUT.PUT(LPAD(ile || ' ', 10));
  END LOOP;
  
  SELECT SUM(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) INTO ile FROM Kocury;
  
  DBMS_OUTPUT.PUT(LPAD(ile || ' ',10));
  DBMS_OUTPUT.PUT_LINE('');

END;
