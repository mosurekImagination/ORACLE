-- zad 48

SET SERVEROUTPUT ON

DROP TABLE Myszy;

DECLARE
    createQuery VARCHAR2(1000);
    BEGIN
                createQuery :='
                CREATE TABLE Myszy(
                nr_myszy NUMBER(10) CONSTRAINT myszy_pk PRIMARY KEY,
                lowca VARCHAR(15) CONSTRAINT lowca_fk REFERENCES Kocury(pseudo),
                zjadacz VARCHAR(15) CONSTRAINT zjadacz_fk REFERENCES Kocury(pseudo),
                waga_myszy NUMBER(2) NOT NULL CONSTRAINT wm_cnstr CHECK(waga_myszy BETWEEN 3 AND 33),
                data_zlowienia DATE NOT NULL,
                data_wydania DATE)';
                EXECUTE IMMEDIATE createQuery;
                COMMIT;
    END;
    



   

