-- Zadanie 36
-- W zwi?zku z du?? wydajno?ci? w ?owieniu myszy SZEFUNIO postanowi?
-- wynagrodzi? swoich podw?adnych. Og?osi? wi?c, ?e podwy?sza
-- indywidualny przydzia? myszy ka?dego kota o 10%
-- poczynaj?c od kot�w o najni?szym przydziale.
-- Je?li w kt�rym? momencie suma wszystkich przydzia?�w przekroczy 1050,
-- ?aden inny kot nie dostanie podwy?ki.
-- Je?li przydzia? myszy po podwy?ce przekroczy maksymaln? warto??
-- nale?n? dla pe?nionej funkcji (relacja Funkcje),
-- przydzia? myszy po podwy?ce ma by? r�wny tej warto?ci.
-- Napisa? blok PL/SQL z kursorem, kt�ry wyznacza sum? przydzia?�w
-- przed podwy?k? a realizuje to zadanie.
-- Blok ma dzia?a? tak d?ugo,
-- a? suma wszystkich przydzia?�w rzeczywi?cie przekroczy 1050
-- (liczba �obieg�w podwy?kowych� mo?e by? wi?ksza od 1
--                  a wi?c i podwy?ka mo?e by? wi?ksza ni? 10%).
-- Wy?wietli? na ekranie sum? przydzia?�w myszy
-- po wykonaniu zadania wraz z liczb? podwy?ek
-- (liczb? zmian w relacji Kocury).
-- Na ko?cu wycofa? wszystkie zmiany.

SET AUTOCOMMIT OFF;

DECLARE
  CURSOR kursor IS
    SELECT * FROM Kocury
    ORDER BY przydzial_myszy DESC
    FOR UPDATE OF przydzial_myszy;
  rekord kursor%ROWTYPE;
  update_count NUMBER DEFAULT 0;
  suma NUMBER DEFAULT 0;
  funkcja_max NUMBER DEFAULT 0;
  nju NUMBER DEFAULT 0;
BEGIN
  SELECT SUM(przydzial_myszy) INTO suma FROM Kocury;
  <<zewn>>LOOP
    OPEN kursor; -- otwarcie kursowa = poczatek zapytania

    LOOP
      IF suma > 1050 THEN
        DBMS_OUTPUT.put_line('Calk. przydzial w stadku ' || suma);
        DBMS_OUTPUT.put_line('Zmian - ' || update_count);
        EXIT zewn;
      END IF;
      
      FETCH kursor INTO rekord; -- pobiera pojedynczy rekord z kursora
      EXIT WHEN kursor%NOTFOUND; -- jesli nie ma juz wiecej elementow w kursorze
      
      SELECT max_myszy INTO funkcja_max FROM Funkcje WHERE funkcja=rekord.funkcja;
      
      nju := NVL(rekord.przydzial_myszy, 0) * 1.1;
      IF nju > funkcja_max THEN
        nju := funkcja_max;
      END IF;
      
      UPDATE Kocury SET przydzial_myszy=nju WHERE pseudo=rekord.pseudo;

      update_count := update_count + 1;
      
      SELECT SUM(przydzial_myszy) INTO suma FROM Kocury;
      
    END LOOP;
    
    CLOSE kursor;
  END LOOP;
END;

SELECT imie, NVL(przydzial_myszy,0) "Myszki po podwyzce" FROM Kocury;

ROLLBACK;