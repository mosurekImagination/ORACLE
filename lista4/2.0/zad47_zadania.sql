-- LISTA 2

-- ZAD 26
	SELECT
	  FUNKCJA,
	  ROUND(AVG(kocur.CalkowiteSpozycie()))
	FROM O_Kocury kocur
	WHERE FUNKCJA <> 'SZEFUNIO'
	GROUP BY FUNKCJA
	HAVING ROUND(AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))) >= ALL (
	  SELECT ROUND(AVG(kocur.CalkowiteSpozycie()))
	  FROM O_Kocury kocur
	  WHERE funkcja != 'SZEFUNIO'
	  GROUP BY funkcja
	)
	       OR ROUND(AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))) <= ALL (
	  SELECT ROUND(AVG(kocur.CalkowiteSpozycie()))
	  FROM O_Kocury kocur
	  WHERE funkcja != 'SZEFUNIO'
	  GROUP BY funkcja
	);
-- ZAD 19c
	--19c

	SELECT *
	FROM (
	  SELECT
	    CONNECT_BY_ROOT IMIE    imie,
	    CONNECT_BY_ROOT FUNKCJA fu,
	    TO_CHAR(level - 1)      poziom,
	    IMIE                    szefunio
	  FROM O_Kocury kocur
	  WHERE CONNECT_BY_ROOT PSEUDO <> PSEUDO
	  CONNECT BY PRIOR VALUE(kocur).DajSzefa().pseudo = pseudo
	  START WITH FUNKCJA = 'MILUSIA' OR FUNKCJA = 'KOT')
	  PIVOT
	  (
	    MAX(szefunio)
	    FOR poziom
	    IN ('1' "szef 1",
	      '2' "szef 2",
	      '3' "szef 3")
	  );

-- LISTA 3

-- ZAD 37
	SET SERVEROUTPUT ON
	DECLARE
	    i NUMBER :=1;
	BEGIN
	    DBMS_OUTPUT.PUT_LINE(RPAD('nr', 5, ' ') || RPAD('Pseudonim', 12, ' ') || 'zjada');
	    DBMS_OUTPUT.PUT_LINE(RPAD('_', 22, '_'));

	    FOR re IN (SELECT kot.pseudo, kot.CalkowiteSpozycie() as zjada
	            FROM O_Kocury kot
	            ORDER BY 2 DESC)
	                     
	    LOOP
	        DBMS_OUTPUT.PUT_LINE(RPAD(i, 5, ' ') || RPAD(re.pseudo, 12, ' ') || LPAD(re.zjada, 5, ' '));
	        i:=i+1;
	        EXIT WHEN i = 6;
	    END LOOP;
	END;
-- ZAD 35
	SET SERVEROUTPUT ON
	DECLARE
	    pseudonim VARCHAR2(20) := '&pseudo';
	    imie VARCHAR2(20);
	    p_r NUMBER;
	    m NUMBER;

	BEGIN
	    SELECT 
	        kot.CalkowiteSpozycie() * 12,
	        kot.MiesiacWstapienia(),
	        kot.imie
	    INTO 
	        p_r,
	        m,
	        imie
	    FROM O_Kocury kot WHERE pseudo = pseudonim;
	    
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