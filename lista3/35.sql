SET SERVEROUTPUT ON
DECLARE
    pseudonim VARCHAR2(20) := '&pseudo';
    imie VARCHAR2(20);
    p_r NUMBER;
    m NUMBER;

BEGIN
    SELECT 
        (przydzial_myszy + NVL(myszy_extra, 0)) * 12,
        EXTRACT(month FROM w_stadku_od),
        imie
    INTO 
        p_r,
        m,
        imie
    FROM Kocury WHERE pseudo = pseudonim;
    
    IF (p_r > 700) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' calkowity roczny przydzial myszy >700');
    END IF;
    IF (INSTR(imie, 'A') > 0) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' Imie zawiera literę A');
    END IF;
    IF (m = 1) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' styczeń jest miesiacem przystapienia do stada');
    END IF;
    IF (NOT ((p_r > 700) OR INSTR(imie, 'A') > 0 OR m = 1)) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' Nie odpowiada kryteriom');
    END IF;
END;
