-- Zadanie 44
-- ygrysa zaniepokoiło niewytłumaczalne obniżenie zapasów "myszowych".
-- Postanowił więc wprowadzić podatek pogłówny, który zasiliłby spiżarnię.
-- Zarządził więc, że każdy kot ma obowiązek oddawać 5% (zaokrąglonych w górę)
-- swoich całkowitych "myszowych" przychodów. Dodatkowo od tego co pozostanie:
-- -  koty nie posiadające podwładnych oddają po dwie myszy za nieudolność w   
--    umizgach o awans,
-- -  koty nie posiadające wrogów oddają po jednej myszy za zbytnią  ugodowość,
-- -  koty płacą dodatkowy podatek, którego formę określa wykonawca zadania.
--
-- Napisać funkcję, której parametrem jest pseudonim kota,
-- wyznaczającą należny podatek pogłówny kota.
--
-- Funkcję tą razem z procedurą z zad. 40 należy umieścić w pakiecie,
-- a następnie wykorzystać ją do określenia podatku dla wszystkich kotów.

CREATE OR REPLACE PACKAGE Zad44 AS

  PROCEDURE nowa_banda (
      numer_bandy bandy.nr_bandy%TYPE,
      nazwa_bandy bandy.nazwa%TYPE,
      teren_bandy bandy.teren%TYPE);
      
  FUNCTION podatek_nalezny (
      pseudonim_kota Kocury.pseudo%TYPE
    ) RETURN NUMBER;
    
END Zad44;

CREATE OR REPLACE PACKAGE BODY Zad44 AS

  -- przekopiowane z zadania 40
  PROCEDURE nowa_banda (
      numer_bandy bandy.nr_bandy%TYPE,
      nazwa_bandy bandy.nazwa%TYPE,
      teren_bandy bandy.teren%TYPE) IS
    ile NUMBER DEFAULT 0;
    blad STRING(256);
    ZLY_NUMER EXCEPTION;
    ZLA_WARTOSC EXCEPTION;
  BEGIN
    IF numer_bandy <= 0 THEN
      RAISE ZLY_NUMER;
    END IF;
    
    blad := '';
    
    SELECT count(nr_bandy) INTO ile FROM bandy WHERE nr_bandy = numer_bandy;
    IF ile > 0 THEN
      blad := TO_CHAR(numer_bandy);
    END IF;
    
    SELECT count(nazwa) INTO ile FROM bandy WHERE nazwa = nazwa_bandy;
    IF ile > 0 THEN
      IF LENGTH(blad) > 0 THEN
        blad := blad || ', ' || nazwa_bandy;
      ELSE
        blad := nazwa_bandy;
      END IF;
    END IF;
    
    SELECT count(teren) INTO ile FROM bandy WHERE teren = teren_bandy;
    IF ile > 0 THEN
      IF LENGTH(blad) > 0 THEN
        blad := blad || ', ' || teren_bandy;
      ELSE
        blad := teren_bandy;
      END IF;
    END IF;
  
    IF LENGTH(blad) > 0 THEN
      RAISE ZLA_WARTOSC;
    END IF;
  
    INSERT INTO bandy (nr_bandy, nazwa, teren)
    VALUES (numer_bandy, nazwa_bandy, teren_bandy);
    
  EXCEPTION
    WHEN ZLY_NUMER THEN DBMS_OUTPUT.PUT_LINE('Numer musi byc > 0');
    WHEN ZLA_WARTOSC THEN DBMS_OUTPUT.PUT_LINE(blad || ': Juz istnieje');
  --  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Straszny blad!');
  END;

  -- zadanie 44 właściwe
  
  FUNCTION podatek_nalezny (
      pseudonim_kota Kocury.pseudo%TYPE
    ) RETURN NUMBER IS
    rezult NUMBER DEFAULT 0;
    tmp NUMBER DEFAULT 0;
  BEGIN
    
    -- podstawowy podatek
    SELECT
      CEIL( 0.05 * (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) ) INTO rezult
    FROM Kocury WHERE pseudo = pseudonim_kota;
    
    SELECT COUNT(pseudo) INTO tmp
    FROM Kocury WHERE szef = pseudonim_kota;
    IF tmp <= 0 THEN
      rezult := rezult + 2;
    END IF;
    
    SELECT COUNT(pseudo) INTO tmp
    FROM Wrogowie_Kocurow WHERE pseudo = pseudonim_kota;
    IF tmp <= 0 THEN
      rezult := rezult + 1;
    END IF;
    
    SELECT COUNT(pseudo) INTO tmp FROM Kocury
    WHERE pseudo = pseudonim_kota AND plec = 'D';
    IF tmp > 0 THEN
      rezult := rezult - 1;
    END IF;
    
    IF rezult < 0 THEN
      RETURN 0;
    END IF;
    
    RETURN rezult;

  END;

END Zad44;