-- Zadanie 37
-- Napisać blok, który powoduje wybranie w pętli kursorowej FOR pięciu kotów
-- o najwyższym całkowitym przydziale myszy. Wynik wyświetlić na ekranie.

DECLARE
  bylo BOOLEAN DEFAULT FALSE;
  empty_rezult EXCEPTION;
  nr NUMBER DEFAULT 1;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Nr    Pseudonim    Zjada');
  DBMS_OUTPUT.PUT_LINE('------------------------');
  
  FOR kot IN (
    SELECT
      pseudo,
      NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) zjada
    FROM kocury ORDER BY zjada DESC
  ) LOOP
    bylo := TRUE;
    DBMS_OUTPUT.PUT_LINE(LPAD(nr,4) || '  ' || RPAD(kot.pseudo,9) || '    ' || LPAD(kot.zjada,5) );
    nr := nr + 1;
    EXIT WHEN nr > 5;
  END LOOP;
  IF NOT bylo THEN RAISE empty_rezult; END IF;
EXCEPTION
  WHEN empty_rezult THEN DBMS_OUTPUT.PUT_LINE('Straszny błąd! Nie ma kotow');
  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);
END;
