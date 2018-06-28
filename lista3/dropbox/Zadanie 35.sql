-- Zadanie 35
-- Napisa? blok PL/SQL, który wyprowadza na ekran nast?puj?ce informacje
-- o kocie o pseudonimie wprowadzonym z klawiatury
-- (w zale?no?ci od rzeczywistych danych):
--  -	'calkowity roczny przydzial myszy >700'
--  -	'imi? zawiera litere A'
--  -	'stycze? jest miesiacem przystapienia do stada'
--  -	'nie odpowiada kryteriom'.
-- Powy?sze informacje wymienione s? zgodnie z hierarchi? wa?no?ci.
-- Ka?d? wprowadzan? informacj? poprzedzi? imieniem kota.

DECLARE
  crpm NUMBER;
  imie Kocury.imie%TYPE;
  miesiac NUMBER;
  bylo BOOLEAN DEFAULT FALSE;
BEGIN
  SELECT
    imie,
    (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) * 12,
    EXTRACT(MONTH FROM w_stadku_od)
  INTO
    imie, crpm, miesiac
  FROM Kocury
  WHERE pseudo='&pseudo_kota';
  IF crpm > 700 THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''calkowity roczny przydzial myszy >700''');
    bylo := TRUE;
  END IF;
  IF imie LIKE '%A%' THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''imi? zawiera litere A''');  
    bylo := TRUE;
  END IF;
  IF miesiac = 1 THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''stycze? jest miesiacem przystapienia do stada''');    
    bylo := TRUE;
  END IF;
  IF NOT bylo THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''nie odpowiada kryteriom''');      
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE(imie || ' - ''nie odpowiada kryteriom''');    
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
