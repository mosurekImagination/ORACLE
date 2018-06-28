CREATE OR REPLACE PROCEDURE PRZYJECIE_MYSZY_NA_STAN(ps Kocury.pseudo%TYPE, dzien DATE) AS 
  nrMyszy NUMBER; 
  czyIstniejeKot NUMBER; 
  queryString VARCHAR2(2000); 
  TYPE wierszMyszy IS RECORD (nr myszy.nr_myszy%TYPE, lowca myszy.lowca%TYPE, zjadacz myszy.zjadacz%TYPE,
                              waga_myszy myszy.waga_myszy%TYPE, data_zlowienia Myszy.data_zlowienia%TYPE, 
                              data_wydania Myszy.data_wydania%TYPE); 
  TYPE tablicaMyszy IS TABLE OF wierszMyszy INDEX BY BINARY_INTEGER; 
  dane tablicaMyszy; 
  
  TYPE wierszMyszyKota IS RECORD (nr_zlowienia Myszy.nr_myszy%TYPE, lowca Myszy.lowca%TYPE, waga_myszy Myszy.waga_myszy%TYPE, 
                                  data_zlowienia Myszy.data_zlowienia%TYPE); 
  TYPE myszyKota IS TABLE OF wierszMyszyKota INDEX BY BINARY_INTEGER; 
  myszyDoZdania myszyKota; 
  
  kot_nieznaleziony_exception EXCEPTION; 
BEGIN 

  SELECT COUNT(*) INTO czyIstniejeKot FROM Kocury WHERE pseudo = ps; 
  IF czyIstniejeKot = 0 THEN 
    RAISE kot_nieznaleziony_exception; 
  END IF; 
  
  SELECT MAX(nr_myszy) INTO nrMyszy FROM Myszy;
  
  queryString:='SELECT * FROM '||ps|| ' WHERE data_zlowienia = ' || q'[']' || dzien || q'[']'; 
  EXECUTE IMMEDIATE queryString BULK COLLECT INTO myszyDoZdania;
  
  nrMyszy:=nrMyszy+1; 
  
  FOR i IN 1..myszyDoZdania.COUNT 
    LOOP 
      dane(i).nr := nrMyszy; 
      dane(i).lowca := myszyDoZdania(i).lowca; 
      dane(i).waga_myszy := myszyDoZdania(i).waga_myszy; 
      dane(i).data_zlowienia := myszyDoZdania(i).data_zlowienia; 
      nrMyszy:=nrMyszy+1;
    END LOOP; 
    
    FOR j IN 1..dane.COUNT 
    LOOP
        INSERT INTO Myszy(nr_myszy, lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
        VALUES(dane(j).nr, dane(j).lowca, dane(j).zjadacz, dane(j).waga_myszy, dane(j).data_zlowienia, dane(j).data_wydania);
    END LOOP;
    
    queryString:='DELETE FROM '||ps|| ' WHERE data_zlowienia = ' || q'[']' || dzien || q'[']'; 
    EXECUTE IMMEDIATE queryString;
    
EXCEPTION 
  WHEN kot_nieznaleziony_exception THEN 
  DBMS_OUTPUT.PUT_LINE('Nie ma takiego kota w stadzie'); 
  WHEN OTHERS THEN 
  DBMS_OUTPUT.PUT_LINE(SQLERRM); 
END PRZYJECIE_MYSZY_NA_STAN;