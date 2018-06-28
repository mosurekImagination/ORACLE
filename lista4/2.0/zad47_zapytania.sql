-- wykorzystanie referencji
	
	-- plebs nie sługa
	SELECT pseudo FROM O_Kocury
    WHERE pseudo NOT IN(
  		SELECT DEREF(sluga).kocur.pseudo FROM O_Elita
    ) AND pseudo NOT IN(
  		SELECT DEREF(kocur).pseudo FROM O_Elita
    );
-- grupowanie

	--ILOSC WPISOW POSIADACZY KONT
	SELECT DEREF(konto.elita).kocur.pseudo, COUNT(*) FROM KontaR konto GROUP BY DEREF(konto.elita).kocur.pseudo;
	
-- podzapytanie
	-- status kocurów
	SELECT 
		pseudo,
		CASE WHEN O_Kocury.pseudo IN(SELECT DEREF(kocur).pseudo FROM O_Elita) THEN 'elita'
        WHEN O_Kocury.pseudo IN(SELECT DEREF(kocur).pseudo FROM O_PLebs) THEN 'plebs'
		ELSE 'brak' END as "status"
	FROM O_Kocury;

-- metoda
	--pierwszy szef kocura
	SELECT
		pseudo,
		CASE WHEN kocur.DajSzefa() IS NOT NULL THEN kocur.DajSzefa().pseudo
		ELSE ' ' END as "szef 1"
	FROM O_Kocury kocur
