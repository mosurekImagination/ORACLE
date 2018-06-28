
SET SERVEROUTPUT ON;

DROP TYPE Koty;
DROP TYPE Plebs;
DROP TYPE Elita;
DROP TYPE Konta;

CREATE OR REPLACE TYPE Koty AS OBJECT (
    imie VARCHAR2(15),
    plec VARCHAR2(1),
    pseudo VARCHAR2(15),
    szef VARCHAR2(15),
    w_stadku_od DATE,
    przydzial_myszy NUMBER(3),
    myszy_extra NUMBER(3),
    
    MAP MEMBER FUNCTION Porownaj RETURN VARCHAR2,
    MEMBER FUNCTION getPlec RETURN VARCHAR2,
    MEMBER FUNCTION czyWczesniejOd(innyKot Koty) RETURN BOOLEAN,
    MEMBER FUNCTION getRocznyPrzeydzialMyszy RETURN NUMBER,
    MEMBER FUNCTION getPseudo RETURN VARCHAR2,
    MEMBER FUNCTION getPrzydzialMyszy RETURN NUMBER,
    MEMBER FUNCTION getImie RETURN VARCHAR2,
    MEMBER FUNCTION getOdKiedyWStadku RETURN DATE
);

CREATE OR REPLACE TYPE BODY Koty AS
    MAP MEMBER FUNCTION Porownaj  RETURN VARCHAR2 IS
        BEGIN
            RETURN pseudo;
        END;
    MEMBER FUNCTION getPlec RETURN VARCHAR2 IS
        BEGIN
            RETURN plec;
        END;
    MEMBER FUNCTION czyWczesniejOd(innyKot Koty) RETURN BOOLEAN IS
        BEGIN
            RETURN w_stadku_od < innyKot.w_stadku_od;
        END;
    MEMBER FUNCTION getRocznyPrzeydzialMyszy RETURN NUMBER IS
        BEGIN
            RETURN (NVL(przydzial_myszy,0) + NVL(myszy_extra,0))*12;
        END;
    MEMBER FUNCTION getPrzydzialMyszy RETURN NUMBER IS
        BEGIN
            RETURN (NVL(przydzial_myszy,0) + NVL(myszy_extra,0));
        END;
    MEMBER FUNCTION getImie RETURN VARCHAR2 IS
        BEGIN
            RETURN imie;
        END;
    MEMBER FUNCTION getOdKiedyWStadku RETURN DATE IS
        BEGIN
            RETURN w_stadku_od;
        END;
    MEMBER FUNCTION getPseudo RETURN VARCHAR2 IS
        BEGIN
            RETURN pseudo;
        END;        
END;

CREATE OR REPLACE TYPE Plebs AS OBJECT (
    nr_plebsu NUMBER,
    kot REF Koty,
    
    MAP MEMBER FUNCTION PorownajPoPseudo RETURN VARCHAR2,
    MEMBER FUNCTION getKot RETURN Koty   
);

CREATE OR REPLACE TYPE BODY Plebs AS
    MAP MEMBER FUNCTION PorownajPoPseudo RETURN VARCHAR2 IS
        temp_kot Koty;
        BEGIN
            SELECT DEREF(kot) INTO temp_kot FROM DUAL;
            RETURN temp_kot.pseudo;
        END;
    MEMBER FUNCTION getKot RETURN Koty IS
        temp_kot Koty;
        BEGIN
            SELECT DEREF(kot) INTO temp_kot FROM DUAL;
            RETURN temp_kot;
        END;
END;

CREATE OR REPLACE TYPE Elita AS OBJECT (
    nr_czlonka_elity NUMBER,
    kot REF Koty,
    sluga REF Plebs,
    
    MAP MEMBER FUNCTION PorownajPoPseudo RETURN VARCHAR2,
    MEMBER FUNCTION getKot RETURN Koty,
    MEMBER FUNCTION getSluga RETURN Plebs,
    MEMBER FUNCTION getPrzydzialMyszy RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY Elita AS
    MAP MEMBER FUNCTION PorownajPoPseudo RETURN VARCHAR2 IS
        temp_kot Koty;
        BEGIN
            SELECT DEREF(kot) INTO temp_kot FROM DUAL;
            RETURN temp_kot.pseudo;
        END;
    MEMBER FUNCTION getKot RETURN Koty IS
        temp_kot Koty;
        BEGIN
            SELECT DEREF(kot) INTO temp_kot FROM DUAL;
            RETURN temp_kot;
        END;
    MEMBER FUNCTION getSluga RETURN Plebs IS
        temp_sluga Plebs;
        BEGIN
            SELECT DEREF(sluga) INTO temp_sluga FROM DUAL;
            RETURN temp_sluga;
        END;
    MEMBER FUNCTION getPrzydzialMyszy RETURN NUMBER IS
        temp_kot Koty;
        BEGIN
            SELECT DEREF(kot) INTO temp_kot FROM DUAL;
            RETURN temp_kot.getRocznyPrzeydzialMyszy();
        END;
    
END;

CREATE OR REPLACE TYPE Konta AS OBJECT (
    nr_konta NUMBER,
    wlasciciel REF Elita,
    data_wprowadzenia DATE,
    data_usuniecia DATE,
    
    MAP MEMBER FUNCTION PorownajPoKoncie RETURN NUMBER,
    MEMBER FUNCTION getWlasciciel RETURN Elita,
    MEMBER FUNCTION getDataDodania RETURN VARCHAR2,
    MEMBER FUNCTION CzyUsunieta RETURN Boolean
);

CREATE OR REPLACE TYPE BODY Konta AS
    MAP MEMBER FUNCTION PorownajPoKoncie RETURN NUMBER IS
        BEGIN
            RETURN nr_konta;
        END;
    MEMBER FUNCTION getWlasciciel RETURN Elita IS
        temp_wlasciciel Elita;
        BEGIN 
            SELECT DEREF(wlasciciel) INTO temp_wlasciciel FROM DUAL;
            RETURN temp_wlasciciel;
        END;
    MEMBER FUNCTION getDataDodania RETURN VARCHAR2 IS
        BEGIN
            RETURN 'Mysz dodana '||data_wprowadzenia;
        END;
    MEMBER FUNCTION CzyUsunieta RETURN Boolean IS
        BEGIN
            RETURN data_usuniecia IS NOT NULL;
        END;        
END;


show errors;



