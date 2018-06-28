

CREATE OR REPLACE PACKAGE Wirus AS
  przydzial NUMBER DEFAULT 0;
  kara NUMBER DEFAULT 0;
  nagroda NUMBER DEFAULT 0;
END Wirus;

CREATE OR REPLACE TRIGGER Wirus_przydzial_tygrysa
BEFORE UPDATE ON kocury
BEGIN
  SELECT przydzial_myszy INTO Wirus.przydzial FROM Kocury WHERE pseudo = 'TYGRYS';
END;
SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER Wirus_sprawdz_zamiary_tygrysa
BEFORE UPDATE ON Kocury
FOR EACH ROW
DECLARE
  roznica NUMBER DEFAULT 0;
BEGIN
  
  IF :new.funkcja = 'MILUSIA' THEN
    
    roznica := :new.przydzial_myszy - :old.przydzial_myszy;

    IF roznica < 0 THEN
      :new.przydzial_myszy := :old.przydzial_myszy;
      DBMS_OUTPUT.PUT_LINE('Obnizki niedozwolone');
    END IF;
    
    roznica := :new.przydzial_myszy - :old.przydzial_myszy;
  
    IF (roznica > 0) AND (roznica < 0.1 * Wirus.przydzial) THEN
      DBMS_OUTPUT.PUT_LINE('Przyzano kare dla Tygrysa');

      Wirus.kara := Wirus.kara + 1;
      :new.przydzial_myszy := :new.przydzial_myszy + 0.1 * Wirus.przydzial;
      :new.myszy_extra := :new.myszy_extra + 5;
    ELSIF (roznica > 0) AND (roznica >= 0.1 * Wirus.przydzial) THEN
    
      DBMS_OUTPUT.PUT_LINE('Przyznano Nagrode dla Tygrysa');
      Wirus.nagroda := Wirus.nagroda + 1;
    END IF;      
  END IF;
  
END;

CREATE OR REPLACE TRIGGER Wirus_osadz_Tygrysa
AFTER UPDATE ON Kocury
DECLARE
  bufor NUMBER DEFAULT 0;
BEGIN

  IF Wirus.kara > 0 THEN
    bufor := Wirus.kara;
    Wirus.kara := 0;
    UPDATE Kocury SET
      przydzial_myszy = przydzial_myszy * ( 1 - (0.1 * bufor))
    WHERE pseudo = 'TYGRYS';
  END IF;
  
  IF Wirus.nagroda > 0 THEN
    bufor := Wirus.nagroda;
    Wirus.nagroda := 0;
    UPDATE Kocury SET
      myszy_extra = myszy_extra + (bufor * 5)
    WHERE pseudo = 'TYGRYS';
  END IF;

END;

SET AUTOCOMMIT OFF;

SELECT * FROM Kocury WHERE FUNKCJA IN ('SZEFUNIO', 'MILUSIA') ORDER BY funkcja, pseudo;

SET SERVEROUTPUT ON;
UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 11;

SELECT * FROM Kocury WHERE FUNKCJA IN ('SZEFUNIO', 'MILUSIA') ORDER BY funkcja, pseudo;

ROLLBACK;