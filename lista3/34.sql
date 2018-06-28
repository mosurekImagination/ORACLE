SET SERVEROUTPUT ON
DECLARE
    funkcjaString VARCHAR2(20) := '&funkcja';
    ile NUMBER;
BEGIN
    SELECT COUNT(*) INTO ile FROM Funkcje WHERE funkcja = funkcjaString;
    IF (ile > 0) THEN
        DBMS_OUTPUT.PUT_LINE('Znaleziono funkcję ' || funkcjaString);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono funkcji');
    END IF;
END;
