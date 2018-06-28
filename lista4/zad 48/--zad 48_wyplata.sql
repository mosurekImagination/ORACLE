SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE WYPLATA AS 
  sroda DATE := (next_day(last_day(sysdate)-7, 'Œroda')); --ostatnia sroda miesiaca
  licznik NUMBER := 1;  
  flag BOOLEAN;
  licznikStartowy NUMBER := 1;
  
  TYPE wierszMyszy IS RECORD (nr myszy.nr_myszy%TYPE, lowca myszy.lowca%TYPE, zjadacz myszy.zjadacz%TYPE, waga_myszy myszy.waga_myszy%TYPE, 
                              data_zlowienia myszy.data_zlowienia%TYPE, data_wydania myszy.data_wydania%TYPE); 
  TYPE tablicaMyszy IS TABLE OF wierszMyszy INDEX BY BINARY_INTEGER; 
  myszyDoWyplaty tablicaMyszy; 
  
  TYPE daneKota IS RECORD (pseudo kocury.pseudo%TYPE, myszy NUMBER(3)); 
  TYPE tablica IS TABLE OF daneKota INDEX BY BINARY_INTEGER; 
  koty tablica; 
BEGIN 
  SELECT * BULK COLLECT INTO myszyDoWyplaty  -- myszy, ktore nie sa jeszcze przydzielone
  FROM myszy 
  WHERE zjadacz IS NULL AND data_zlowienia <= sroda; 
  
  DBMS_OUTPUT.PUT_LINE(myszyDoWyplaty.COUNT);
  
  SELECT pseudo, przydzial_myszy + nvl(myszy_extra, 0) AS myszy -- koty, które sa w stadzie myszy czyli ma jakis przydzial
  BULK COLLECT INTO koty 
  FROM Kocury 
  WHERE w_stadku_od <= sroda
  START WITH szef IS NULL 
  CONNECT BY PRIOR pseudo=szef
  ORDER BY LEVEL ASC; 
  
  
  FOR i IN 1..myszyDoWyplaty.count 
    LOOP 
    flag := true;
        licznikStartowy := licznik;
        WHILE flag
        LOOP
          IF koty.COUNT = licznik THEN
            licznik := 1;
          END IF;
          DBMS_OUTPUT.PUT_LINE(koty(licznik).myszy); 
          IF koty(licznik).myszy > 0 THEN 
            myszyDoWyplaty(i).zjadacz := koty(licznik).pseudo; 
            koty(licznik).myszy := koty(licznik).myszy - 1; 
            flag := false;
          ELSE 
            flag := true;
          END IF;
          licznik := licznik + 1;
          IF licznikStartowy = licznik THEN --gdy jakies zostaja
            myszyDoWyplaty(i).zjadacz := 'TYGRYS';  
            flag := false;
          END IF;
        END LOOP;
    END LOOP;
    
    FOR j IN 1..myszyDoWyplaty.COUNT
    LOOP
        UPDATE myszy 
        SET data_wydania = sroda, zjadacz = myszyDoWyplaty(j).zjadacz 
        WHERE nr_myszy = myszyDoWyplaty(j).nr;
    END LOOP;
    
EXCEPTION 
  WHEN OTHERS THEN 
  DBMS_OUTPUT.PUT_LINE(SQLERRM); 
END;

show errors;