
SET AUTOCOMMIT OFF;

CREATE OR REPLACE TRIGGER Wirus_Compound
FOR UPDATE ON Kocury
COMPOUND TRIGGER
  przydzial NUMBER DEFAULT 0;
  kara NUMBER DEFAULT 0;
  nagroda NUMBER DEFAULT 0;
  roznica NUMBER DEFAULT 0;
  bufor NUMBER DEFAULT 0;
  
  BEFORE STATEMENT IS BEGIN
    SELECT przydzial_myszy INTO przydzial FROM Kocury WHERE pseudo = 'TYGRYS';
  END BEFORE STATEMENT;
  
  BEFORE EACH ROW IS BEGIN
    IF :new.funkcja = 'MILUSIA' THEN
    
    roznica := :new.przydzial_myszy - :old.przydzial_myszy;

    IF roznica < 0 THEN
      :new.przydzial_myszy := :old.przydzial_myszy;
      DBMS_OUTPUT.PUT_LINE('Obnizki niedozwolone');
    END IF;
    
    roznica := :new.przydzial_myszy - :old.przydzial_myszy;
  
    IF (roznica > 0) AND (roznica < 0.1 * przydzial) THEN
      DBMS_OUTPUT.PUT_LINE('Przyzano kare dla Tygrysa');

      kara := kara + 1;
      :new.przydzial_myszy := :new.przydzial_myszy + 0.1 * przydzial;
      :new.myszy_extra := :new.myszy_extra + 5;
    ELSIF (roznica > 0) AND (roznica >= 0.1 * przydzial) THEN
    
      DBMS_OUTPUT.PUT_LINE('Przyznano Nagrode dla Tygrysa');
      nagroda := nagroda + 1;
    END IF;      
  END IF;

  END BEFORE EACH ROW;
  
  AFTER STATEMENT IS BEGIN
    IF kara > 0 THEN
      bufor := kara;
      kara := 0;
      UPDATE Kocury SET
        przydzial_myszy = przydzial_myszy * ( 1 - (0.1 * bufor))
      WHERE pseudo = 'TYGRYS';
    END IF;
    
    IF nagroda > 0 THEN
      bufor := nagroda;
      nagroda := 0;
      UPDATE Kocury SET
        myszy_extra = myszy_extra + (bufor * 5)
      WHERE pseudo = 'TYGRYS';
    END IF;
  END AFTER STATEMENT;
END Wirus_Compound;
