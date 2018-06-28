-- Zadanie 38
-- Napisać blok, który zrealizuje zad. 19 w sposób uniwersalny
-- (bez konieczności uwzględniania wiedzy o liczbie przełożonych kota
-- usytuowanego najniżej w hierarchii). Daną wejściową ma być maksymalna 
-- liczba wyświetlanych przełożonych.

DECLARE
  curr_level NUMBER DEFAULT 1;
  max_level NUMBER DEFAULT 0;
  n_level NUMBER DEFAULT &n;
  kot kocury%ROWTYPE;
BEGIN

  SELECT
    MAX(level)-1 INTO max_level
  FROM Kocury
  CONNECT BY PRIOR pseudo = szef
  START WITH szef IS NULL;

  IF n_level > max_level THEN
    n_level := max_level;
  END IF;
  
  DBMS_OUTPUT.PUT(RPAD('Imie', 10));
  
  FOR i IN 1..n_level LOOP
    DBMS_OUTPUT.PUT('  |  ' || RPAD('Szef ' || i, 10));
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE(' ');
  DBMS_OUTPUT.PUT('----------');
  FOR i IN 1..n_level LOOP
    DBMS_OUTPUT.PUT(' --- ----------');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(' ');

  FOR rekord IN (
    SELECT * FROM Kocury
    WHERE funkcja IN ('KOT', 'MILUSIA')
  ) LOOP
    curr_level := 1;
    DBMS_OUTPUT.PUT(RPAD(rekord.imie, 10));
    kot := rekord;
    WHILE curr_level <= n_level LOOP
      IF kot.szef IS NULL THEN
        DBMS_OUTPUT.PUT('  |  ' || RPAD(' ', 10));
      ELSE
        SELECT * INTO kot FROM Kocury WHERE pseudo=kot.szef;
        DBMS_OUTPUT.put('  |  ' || RPAD(kot.imie, 10));
      END IF;
      curr_level := curr_level + 1;    
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(' ');
  END LOOP;
END;