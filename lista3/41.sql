CREATE OR REPLACE TRIGGER kolejny_numer_bandy
BEFORE INSERT ON Bandy
FOR EACH ROW
BEGIN
  SELECT MAX(nr_bandy) + 1 INTO :new.nr_bandy FROM Bandy;
END;

SET SERVEROUTPUT ON;
SET AUTOCOMMIT OFF;
DECLARE 
    nowy_numer NUMBER;
BEGIN
  dodaj_bande(44, 'Zdobywcy', 'wszechswiat');
  SELECT nr_bandy INTO nowy_numer FROM Bandy WHERE nazwa='Zdobywcy';
  DBMS_OUTPUT.PUT_LINE(nowy_numer);
END;

ROLLBACK;
SET AUTOCOMMIT ON;