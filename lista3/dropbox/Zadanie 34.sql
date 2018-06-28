-- Zadanie 34
-- Napisa? blok PL/SQL, który wybiera z relacji Kocury
-- koty o funkcji podanej z klawiatury. Jedynym efektem dzia?ania bloku
-- ma by? komunikat informuj?cy czy znaleziono, czy te? nie,
-- kota pe?ni?cego podan? funkcj?
-- (w przypadku znalezienia kota wy?wietli? nazw? odpowiedniej funkcji).

DECLARE
  liczba NUMBER;
  funk Funkcje.funkcja%TYPE;
BEGIN
  SELECT COUNT(pseudo), MIN(funkcja) INTO liczba, funk
  FROM Kocury
  WHERE funkcja = '&nazwa_funkcji';
  IF liczba > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Znaleziono kota pelniacego funkcje ' || funk);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono');
  END IF;
END;