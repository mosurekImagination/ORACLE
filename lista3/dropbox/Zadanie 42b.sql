-- Zadanie 42
-- Milusie postanowiły zadbać o swoje interesy.
-- Wynajęły więc informatyka, aby zapuścił wirusa w system Tygrysa.
-- Teraz przy każdej próbie zmiany przydziału myszy na plus
-- (o minusie w ogóle nie może być mowy) o wartość mniejszą niż
-- 10% przydziału myszy Tygrysa żal Miluś ma być utulony podwyżką
-- ich przydziału o tą wartość oraz podwyżką myszy extra o 5.
-- Tygrys ma być ukarany stratą wspomnianych 10%.
-- Jeśli jednak podwyżka będzie satysfakcjonująca, 
-- przydział myszy extra Tygrysa ma wzrosnąć o 5.
--
-- Zaproponować dwa rozwiązania zadania,
-- które ominą podstawowe ograniczenie dla wyzwalacza wierszowego
-- aktywowanego poleceniem DML tzn. brak możliwości odczytu lub zmiany relacji,
-- na której operacja (polecenie DML) „wyzwala” ten wyzwalacz.
--
-- W pierwszym rozwiązaniu (klasycznym) wykorzystać kilku wyzwalaczy
-- i pamięć w postaci specyfikacji dedykowanego zadaniu pakietu,
-- w drugim wykorzystać wyzwalacz COMPOUND. 
--
-- Podać przykład funkcjonowania wyzwalaczy,
-- a następnie zlikwidować wprowadzone przez nie zmiany.

SET AUTOCOMMIT OFF;

CREATE OR REPLACE TRIGGER Zad42_CompoundTrigger
FOR UPDATE ON Kocury
COMPOUND TRIGGER
  przydzial NUMBER DEFAULT 0;
  kara NUMBER DEFAULT 0;
  nagroda NUMBER DEFAULT 0;
  f_min NUMBER DEFAULT 0;
  f_max NUMBER DEFAULT 0;
  diff NUMBER DEFAULT 0;
  tmp NUMBER DEFAULT 0;
  
  BEFORE STATEMENT IS BEGIN
    SELECT przydzial_myszy INTO przydzial FROM Kocury WHERE pseudo = 'TYGRYS';
  END BEFORE STATEMENT;
  
  BEFORE EACH ROW IS BEGIN
    SELECT min_myszy, max_myszy INTO f_min, f_max
    FROM Funkcje WHERE funkcja = :new.funkcja;
    
    IF :new.funkcja = 'MILUSIA' THEN
      IF :new.przydzial_myszy < :old.przydzial_myszy THEN
        :new.przydzial_myszy := :old.przydzial_myszy;
        DBMS_OUTPUT.PUT_LINE('Zablokowano probe obnizki kota ' || :new.pseudo
            || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);
      END IF;
      
      diff := :new.przydzial_myszy - :old.przydzial_myszy;
    
      IF (diff > 0) AND (diff < 0.1 * przydzial) THEN
      
             DBMS_OUTPUT.PUT_LINE('Kara dla Tygrysa za zmiane dla kota ' || :new.pseudo
            || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);
  
      
         kara := kara + 1;
         :new.przydzial_myszy := :new.przydzial_myszy + 0.1 * przydzial;
         :new.myszy_extra := :new.myszy_extra + 5;
      ELSIF (diff > 0) AND (diff >= 0.1 * przydzial) THEN
      
             DBMS_OUTPUT.PUT_LINE('Nagroda dla Tygrysa za zmiane dla kota ' || :new.pseudo
            || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);
  
      
         nagroda := nagroda + 1;
      END IF;      
    END IF;
    
    -- Sprawdzanie przekroczenia wartosci dla funkcji:
    IF :new.przydzial_myszy < f_min THEN
      :new.przydzial_myszy := f_min;
    ELSIF :new.przydzial_myszy > f_max THEN
      :new.przydzial_myszy := f_max;
    END IF;
  END BEFORE EACH ROW;
  
  AFTER STATEMENT IS BEGIN
    IF kara > 0 THEN
      tmp := kara;
      kara := 0; -- przeciwdziala petli nieskonczonej
      UPDATE Kocury SET
        przydzial_myszy = przydzial_myszy * ( 1 - (0.1 * tmp))
      WHERE pseudo = 'TYGRYS';
    END IF;
    
    IF nagroda > 0 THEN
      tmp := nagroda;
      nagroda := 0; -- przeciwdziala petli nieskonczonej
      UPDATE Kocury SET
        myszy_extra = myszy_extra + (Zad42.nagroda * 5)
      WHERE pseudo = 'TYGRYS';
    END IF;
  END AFTER STATEMENT;
END Zad42_CompoundTrigger;


-- testowanie

SELECT * FROM Kocury;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 1;
SELECT * FROM Kocury;
ROLLBACK;