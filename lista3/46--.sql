DROP TABLE WYKROCZENIA_PRZEDZIALOW;
CREATE TABLE WYKROCZENIA_PRZEDZIALOW (
 kto VARCHAR(15) NOT NULL,
 data DATE DEFAULT (SYSDATE),
 pseudo VARCHAR2(15) CONSTRAINT wp_fk_k REFERENCES Kocury(pseudo) NOT NULL,
 operacja VARCHAR2(15) NOT NULL
);


CREATE OR REPLACE TRIGGER blokada_funkcji
FOR INSERT OR UPDATE ON KOCURY
COMPOUND TRIGGER 
    f_min NUMBER := 0;
    f_max NUMBER := 0;
    operacja STRING(20);
    query VARCHAR2(1000); 
 BEFORE EACH ROW IS BEGIN 
    IF INSERTING THEN
        operacja := 'INSERT';
    ELSE
        operacja := 'UPDATE'; 
    END IF;
        
    SELECT min_myszy, max_myszy INTO f_min, f_max FROM FUNKCJE WHERE FUNKCJE.funkcja = :new.funkcja;

    DBMS_OUTPUT.put_line('FUNKCJA' || :old.funkcja);
    IF :new.przydzial_myszy < f_min THEN
        query := 'INSERT INTO WYKROCZENIA_PRZEDZIALOW(kto, komu, operacja) VALUES (:login_user, :pseudo, :operacja)';
        EXECUTE IMMEDIATE query USING LOGIN_USER, :new.pseudo, operacja;
        DBMS_OUTPUT.put_line('Przydzial myszy za maly');
        :new.przydzial_myszy := f_min;
    END IF;
    IF :new.przydzial_myszy > f_max THEN
        query := 'INSERT INTO WYKROCZENIA_PRZEDZIALOW(kto, komu, operacja) VALUES (:login_user, :pseudo, :operacja)';
        EXECUTE IMMEDIATE query USING LOGIN_USER, :new.pseudo, operacja;
        :new.przydzial_myszy := f_max;
        DBMS_OUTPUT.put_line('Przydzial myszy za du¿y');
    END IF;
    END BEFORE EACH ROW;

END;

--UTILS
SET AUTOCOMMIT OFF;

SET SERVEROUTPUT ON;
SELECT * FROM Funkcje;

SELECT * FROM Kocury WHERE pseudo = 'PLACEK';

UPDATE Kocury SET przydzial_myszy = 20 WHERE pseudo = 'PLACEK';

SELECT * FROM WYKROCZENIA_PRZEDZIALOW;
SELECT * FROM Kocury WHERE pseudo = 'PLACEK';