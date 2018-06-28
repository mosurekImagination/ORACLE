
SET AUTOCOMMIT OFF;

DECLARE
  numer_bandy bandy.nr_bandy%TYPE DEFAULT &nr;
  nazwa_bandy bandy.nazwa%TYPE DEFAULT '&nazwa';
  teren_bandy bandy.teren%TYPE DEFAULT '&teren';
  ile NUMBER DEFAULT 0;
  blad STRING(256);
  ZLY_NUMER EXCEPTION;
  ZLA_WARTOSC EXCEPTION;
BEGIN
  IF numer_bandy <= 0 THEN
    RAISE ZLY_NUMER;
  END IF;
  
  blad := '';
  
  SELECT count(nr_bandy) INTO ile FROM bandy WHERE nr_bandy = numer_bandy;
  IF ile > 0 THEN
    blad := TO_CHAR(numer_bandy);
  END IF;
  
  SELECT count(nazwa) INTO ile FROM bandy WHERE nazwa = nazwa_bandy;
  IF ile > 0 THEN
    IF LENGTH(blad) > 0 THEN
      blad := blad || ', ' || nazwa_bandy;
    ELSE
      blad := nazwa_bandy;
    END IF;
  END IF;
  
  SELECT count(teren) INTO ile FROM bandy WHERE teren = teren_bandy;
  IF ile > 0 THEN
    IF LENGTH(blad) > 0 THEN
      blad := blad || ', ' || teren_bandy;
    ELSE
      blad := teren_bandy;
    END IF;
  END IF;

  IF LENGTH(blad) > 0 THEN
    RAISE ZLA_WARTOSC;
  END IF;

  INSERT INTO bandy (nr_bandy, nazwa, teren)
  VALUES (numer_bandy, nazwa_bandy, teren_bandy);
  
EXCEPTION
  WHEN ZLY_NUMER THEN DBMS_OUTPUT.PUT_LINE('Numer musi byc > 0');
  WHEN ZLA_WARTOSC THEN DBMS_OUTPUT.PUT_LINE(blad || ': Juz istnieje');
END;

ROLLBACK;
SET AUTOCOMMIT OFF;
