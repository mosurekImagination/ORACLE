SET SERVEROUTPUT ON;
SET AUTOCOMMIT OFF;
DECLARE
zmian NUMBER := 0;
suma NUMBER :=0;
nowy_przydzial NUMBER:=0;
BEGIN
    <<wszystkie>>LOOP
        FOR kot IN (SELECT pseudo, imie, przydzial_myszy, max_myszy
            FROM Kocury NATURAL JOIN FUNKCJE
            ORDER BY 3 ASC)
                     
        LOOP
            SELECT SUM(przydzial_myszy) INTO suma FROM Kocury;
            IF suma > 1050 THEN
                DBMS_OUTPUT.put_line('Calk. przydzial w stadku ' || suma || ' Zmian - '  || zmian);
                EXIT wszystkie;
            END IF;
            DBMS_OUTPUT.put_line(kot.przydzial_myszy || ' ' || kot.max_myszy);
            IF kot.przydzial_myszy < kot.max_myszy THEN
                nowy_przydzial := LEAST(kot.przydzial_myszy * 1.1, kot.max_myszy);
                UPDATE Kocury SET przydzial_myszy = nowy_przydzial WHERE pseudo = kot.pseudo;
                zmian:= zmian + 1;
            END IF;
        END LOOP;  
    END LOOP;   
END;

SELECT imie, NVL(przydzial_myszy,0) "Myszki po podwyzce" FROM Kocury;

ROLLBACK;