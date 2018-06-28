SET SERVEROUTPUT ON;
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

DECLARE 
TYPE daneKota IS RECORD (pseudo kocury.pseudo%TYPE, myszy NUMBER(3)); 
TYPE tablicaKotow IS TABLE OF daneKota INDEX BY BINARY_INTEGER; 
koty tablicaKotow;
TYPE wierszMyszy IS RECORD (nr Myszy.nr_myszy%TYPE, lowca Myszy.lowca%TYPE, zjadacz Myszy.zjadacz%TYPE, waga_myszy Myszy.waga_myszy%TYPE, 
                            data_zlowienia Myszy.data_zlowienia%TYPE, data_wydania Myszy.data_wydania%TYPE); 
TYPE tablicaMyszy IS TABLE OF wierszMyszy INDEX BY BINARY_INTEGER; 
dane tablicaMyszy; 
sroda DATE DEFAULT '2004-01-01'; 
nastepnyDzien DATE DEFAULT '2004-01-01'; 
liczbaMyszy NUMBER(10); 
i BINARY_INTEGER := 1; 
pom BINARY_INTEGER := 1; 
indeks NUMBER(10) :=1;
queryString VARCHAR2(2048);

BEGIN 
    i := 1;
    pom := 1;
    WHILE sroda < '2018-01-17' 
    LOOP    
    nastepnyDzien := sroda+1; 
    sroda := (next_day(last_day(add_months( sroda, 1))-7, 'Œroda')); --ostatnia œroda miesiaca
          
    queryString := 'SELECT pseudo, przydzial_myszy+NVL(myszy_extra,0) FROM Kocury WHERE w_stadku_od < ' || q'[']' || nastepnyDzien || q'[']';
      EXECUTE IMMEDIATE queryString BULK COLLECT INTO koty; -- wywolania SQL pseudo i sredniej kotów aktualnie znajdujacych sie w stadzie
      
    SELECT ROUND(AVG(przydzial_myszy+nvl(myszy_extra,0))) --sredni przydzial myszy dla kotów aktualnie znajdujacych sie w stadzie
    INTO liczbaMyszy -- srednio upolowanych myszy przez kota
    FROM kocury
    WHERE w_stadku_od <= nastepnyDzien; 
    
    
    pom:=i;
    FOR j IN 1..koty.COUNT  -- dla kazdego kota aktualnie znajdujacego sie w stadzie
    LOOP 
        FOR k IN 1..liczbaMyszy -- wyliczona srednia upolowanych myszy
        LOOP --dla kazdej myszy ustalam dane wybranego kota 
            dane(i).nr := indeks;
            dane(i).lowca := koty(j).pseudo;
            dane(i).waga_myszy := dbms_random.value(3,33); 
            dane(i).data_zlowienia := nastepnyDzien + dbms_random.value(0,25); 
            dane(i).data_wydania := sroda; 
            
            i:=i+1; 
            indeks := indeks + 1;
            
        END LOOP;
    END LOOP; 
    
    FOR j IN 1..koty.COUNT 
    LOOP 
        FOR k IN 1..koty(j).myszy -- dla kazdej myszy ustalam zjadacza
        LOOP 
            dane(pom).zjadacz := koty(j).pseudo; 
            pom:=pom+1; 
        END LOOP; 
    END LOOP;
    
    WHILE pom < i -- jezeli jest jakas nadwyzka
    LOOP 
        dane(pom).zjadacz := 'TYGRYS'; 
        pom:=pom+1; 
    END LOOP; 
    
    i:= i - 1;
    
    
    FOR j IN 1..i --wsadzanie do tabeli
    LOOP
        INSERT INTO Myszy(nr_myszy, lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
        VALUES(dane(j).nr, dane(j).lowca, dane(j).zjadacz, dane(j).waga_myszy, dane(j).data_zlowienia, dane(j).data_wydania);
    END LOOP;
    
        
    pom := 1;
    i:=1;
    END LOOP; 
    EXCEPTION 
    WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE(SQLERRM); 
END;

ROLLBACK;

select count(*) as"cos" from Myszy;

show errors;
