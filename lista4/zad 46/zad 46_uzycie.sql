--- zapytania

SELECT 
    kot.getImie() "Imie", 
    kot.getRocznyPrzeydzialMyszy() "Zjada rocznie" 
    FROM ObjKoty kot;
    
SELECT
    konto.getWlasciciel().getKot().getImie() "Imie wlasciciela",
    COUNT(*) "Ma na koncie myszy:"
    FROM ObjKonta konto
    GROUP BY konto.getWlasciciel();
    
    
--zad 18
SELECT
    kot1.getImie() "Imie", 
    kot1.getOdKiedyWStadku() "Poluje od"
    FROM ObjKoty kot1, ObjKoty kot2
    WHERE kot2.getImie() = 'Jacek' AND
            kot1.czyWczesniejOd(kot2) = 'TRUE'
    ORDER BY kot1.getOdKiedyWStadku() DESC;
    

--- ZAD 23

SELECT 
    kot.getImie() "Imie",
    kot.getRocznyPrzeydzialMyszy() "DAWKA ROCZNA",
    'powyzej 864' "DAWKA"
FROM ObjKoty kot
WHERE NVL(kot.myszy_extra,0) > 0 
    AND kot.getRocznyPrzeydzialMyszy() > 864
UNION
SELECT 
    kot.getImie() "Imie",
    kot.getRocznyPrzeydzialMyszy() "DAWKA ROCZNA",
    '864' "DAWKA"
FROM ObjKoty kot 
WHERE NVL(kot.myszy_extra,0) > 0 
    AND kot.getRocznyPrzeydzialMyszy() = 864
UNION
SELECT 
    kot.getImie() "Imie",
    kot.getRocznyPrzeydzialMyszy() "DAWKA ROCZNA",
    'ponizej 864' "DAWKA"
FROM ObjKoty kot 
WHERE NVL(kot.myszy_extra,0) > 0 
    AND kot.getRocznyPrzeydzialMyszy() < 864
ORDER BY "DAWKA ROCZNA" DESC;

-- zad 35
DECLARE
  calk_przydzial NUMBER;
  imie_kota ObjKoty.imie%TYPE;
  miesiac NUMBER;
BEGIN
  SELECT  kot.getImie(), EXTRACT(MONTH FROM kot.w_stadku_od), kot.getRocznyPrzeydzialMyszy() INTO imie_kota, miesiac, calk_przydzial  
  FROM ObjKoty kot 
  WHERE kot.pseudo = '&pseudo';
  IF calk_przydzial > 700 THEN
    DBMS_OUTPUT.PUT_LINE(imie_kota || ' calkowity roczny przydzial myszy > 700 ');
  ELSIF imie_kota LIKE '%A%' THEN
    DBMS_OUTPUT.PUT_LINE(imie_kota || ' zawiera litere A ');
  ELSIF miesiac = 1 THEN
    DBMS_OUTPUT.PUT_LINE(imie_kota || ' styczen jest miesiacem przystapienia do stada');
  ELSE 
    DBMS_OUTPUT.PUT_LINE(imie_kota || ' nie odpowiada kryteriom');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE(imie_kota || ' - ''nie odpowiada kryteriom''');    
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

--ZAD 37
DECLARE 
    CURSOR kursor IS
    SELECT k.pseudo, k.PrzydzialMyszy() zjada 
    FROM ObjKoty k ORDER BY zjada DESC;
    kot ObjKoty%rowtype;
    licznik NUMBER DEFAULT 1;
BEGIN
    FOR kot IN kursor LOOP
        DBMS_OUTPUT.PUT_LINE(licznik || '  ' || RPAD(kot.pseudo,9) || '    ' || LPAD(kot.zjada,5) );
        licznik := licznik + 1;
        EXIT WHEN licznik = 6;
    END LOOP;
END;

