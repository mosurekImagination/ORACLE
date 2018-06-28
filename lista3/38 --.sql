SET SERVEROUTPUT ON
DECLARE
    n NUMBER := &liczbaPrzelozonych;
    szef VARCHAR2(20);
    tempSzef Kocury.szef%TYPE;
    tempImie Kocury.imie%TYPE;
    TYPE tabela_szefow IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;
    k NUMBER := 0;
    koty tabela_szefow;
    max_level NUMBER;
BEGIN
    SELECT
        max(level) INTO max_level
    FROM
        Kocury
    WHERE
        PSEUDO != CONNECT_BY_ROOT(PSEUDO) -- wywalamy połączenia kota z samym sobą
    CONNECT BY PRIOR  -- do danego kota dołączamy kolejnego którego pseudonim jest równy wartości szef danego kota
        SZEF = PSEUDO
    START WITH -- zaczynamy budować drzew, w zasadzie listę od wybranych kotów spełniających :
        FUNKCJA = 'KOT' OR FUNKCJA = 'MILUSIA'
    Group By 
        1
    ;
    max_level := LEAST(max_level-1, n);
    DBMS_OUTPUT.PUT(RPAD('IMIE', 15, ' '));
    FOR i in 1..max_level
    LOOP
        DBMS_OUTPUT.PUT(RPAD('|  SZEF ' || i, 15, ' '));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');

    DBMS_OUTPUT.PUT_LINE(RPAD('_', 15*(max_level + 1), '_'));
    FOR kot IN (SELECT *
            FROM Kocury
            WHERE  funkcja  IN ('KOT', 'MILUSIA'))  
    LOOP    
        tempSzef := kot.szef;
        tempImie := kot.imie;
        koty(k) := RPAD(kot.imie, 15, ' ');
        FOR i IN 1..max_level              
        LOOP
            IF tempSzef IS NOT NULL THEN
                SELECT imie, szef INTO tempImie, tempSzef FROM Kocury WHERE pseudo = tempSzef;
            ELSE
                tempImie := '';
            END IF;
            koty(k) := koty(k) || RPAD('|  ' || tempImie, 15, ' ');
            --EXIT WHEN tempSzef IS NULL;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(koty(k));
        k := k + 1;
    END LOOP;
    
END;
