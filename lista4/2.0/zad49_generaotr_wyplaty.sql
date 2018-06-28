-- Generator
-- Weź wszystkie koty
-- Dla każdego miesiąca
	-- Weź koty z danego miesiąca
	-- wywołaj procedurę która dla kotów z danego miesiaca
		-- policzy średnie spożycie
		-- policzy ile myszy trzeba dodać (całkowite spozycie)
		-- policzy ile trzeb złapać myszy/dzień
		-- dla każdego dnia doda odpowiednią ilość myszy biorąc cyklicznie po kolei koty z tabeli kotów
		-- nadwyżkę dać tygrysowi
	-- dokonać wypłaty myszy dla danego miesiąca
		-- wyplata (pobranie z bazy myszy z danego miesiąca, update bazy)
			--wyplata inner (dostaje tabele myszy) i rozdziela (modyfikuje tablice)
			 -- tablicę posortować już na początku działania generatora;


-- procedura która generuje relację MYSZY_KOTA_[PSEUDO] i dodaje kilka myszy złowionych
-- procedura która dla kilku pseudonimów generuje te relace, po czym wywołuje dodaj myszy kota do tabeli myszy

CREATE OR REPLACE PACKAGE generator AS
        min_waga_myszy constant number(2) := 15;
        max_waga_myszy constant number(2) := 25;
        TYPE KOCUR_TABLICOWY IS RECORD (pseudo Kocury.pseudo%TYPE, przydzial NUMBER, w_stadku_od DATE);
    TYPE TABELA_KOCUROW IS TABLE OF KOCUR_TABLICOWY INDEX BY BINARY_INTEGER;
    TYPE MYSZ_DO_DODANIA IS RECORD (nr_myszy NUMBER, lowca Kocury.pseudo%TYPE, zjadacz Kocury.pseudo%TYPE, waga_myszy NUMBER, data_zlowienia DATE, data_wydania DATE);
    TYPE TABELA_MYSZY IS TABLE OF MYSZ_DO_DODANIA INDEX BY BINARY_INTEGER;
    TYPE ZBIOR_MYSZY IS TABLE OF TABELA_MYSZY INDEX BY BINARY_INTEGER;
    TYPE MYSZY_PARA IS RECORD (przydzielone TABELA_MYSZY, nieprzydzielone TABELA_MYSZY);

    FUNCTION utworz_mysz(lowca Kocury.pseudo%TYPE, data_zlowienia DATE) RETURN MYSZ_DO_DODANIA;
		FUNCTION koty_sprzed_daty(koty TABELA_KOCUROW, data_do DATE) RETURN TABELA_KOCUROW;
		FUNCTION myszy_sprzed_daty(myszy1 TABELA_MYSZY, myszy2 TABELA_MYSZY, data_do DATE) RETURN MYSZY_PARA;
		FUNCTION calkowite_spozycie(koty TABELA_KOCUROW) RETURN NUMBER;
		FUNCTION rozdziel_myszy_w_miesiacu(koty TABELA_KOCUROW, data_pocz DATE) RETURN TABELA_MYSZY;
		FUNCTION nast_index(index_max NUMBER, index_aktualny NUMBER) RETURN NUMBER;
		FUNCTION wyplata_generator(wszsytkie_koty TABELA_KOCUROW, myszy_nieprzydzielone TABELA_MYSZY, myszy_nowe TABELA_MYSZY, data_pocz DATE) RETURN MYSZY_PARA;

    PROCEDURE utworz_myszy_kota(dzien DATE, pseudo Kocury.pseudo%TYPE, ile_myszy NUMBER);
      -- utworz tabele kota
      -- daj mu myszy

    PROCEDURE generuj(data_pocz DATE, data_kon DATE);
END generator;

CREATE OR REPLACE PACKAGE BODY generator AS
    FUNCTION utworz_mysz(lowca Kocury.pseudo%TYPE, data_zlowienia DATE) RETURN MYSZ_DO_DODANIA IS
        m MYSZ_DO_DODANIA;
    BEGIN
        m.lowca := lowca;
        m.waga_myszy := ROUND(DBMS_RANDOM.VALUE(min_waga_myszy, max_waga_myszy));
        m.data_zlowienia := data_zlowienia;
        m.zjadacz := NULL;
        m.data_wydania := NULL;
    RETURN m;
    END utworz_mysz;

    FUNCTION nast_index(index_max NUMBER, index_aktualny NUMBER) RETURN NUMBER IS
    BEGIN
        IF (index_aktualny = index_max) THEN
            RETURN 1;
        ELSE 
            RETURN index_aktualny +1;
        END IF;
    END;

    FUNCTION koty_sprzed_daty(koty TABELA_KOCUROW, data_do DATE) RETURN TABELA_KOCUROW IS
        koty_do_zwrotu TABELA_KOCUROW;
        ix NUMBER :=1;
    BEGIN
        FOR i IN 1..koty.COUNT LOOP
            IF koty(i).w_stadku_od <= data_do THEN
                koty_do_zwrotu(ix) := koty(i);
                ix := ix+1;
            END IF;
        END LOOP;
        RETURN koty_do_zwrotu;
    END koty_sprzed_daty;

    FUNCTION myszy_sprzed_daty(myszy1 TABELA_MYSZY, myszy2 TABELA_MYSZY, data_do DATE) RETURN MYSZY_PARA IS
        myszy_do_zwrotu MYSZY_PARA;
        pi NUMBER :=1;
        ni NUMBER :=1;
    BEGIN
        FOR i IN 1..myszy1.COUNT LOOP
            IF myszy1(i).data_zlowienia <= data_do THEN
                myszy_do_zwrotu.przydzielone(pi) := myszy1(i);
                pi := pi+1;
                
            ELSE
                myszy_do_zwrotu.nieprzydzielone(ni) := myszy1(i);
                ni := ni+1;
            END IF;
        END LOOP;

        FOR i IN 1..myszy2.COUNT LOOP
            IF myszy2(i).data_zlowienia <= data_do THEN
                myszy_do_zwrotu.przydzielone(pi) := myszy2(i);
                pi := pi+1;
            ELSE
                myszy_do_zwrotu.nieprzydzielone(ni) := myszy2(i);
                ni := ni+1;
            END IF;
        END LOOP;

        RETURN myszy_do_zwrotu;
    END myszy_sprzed_daty;
    
    FUNCTION calkowite_spozycie(koty TABELA_KOCUROW) RETURN NUMBER IS
        suma NUMBER :=0;
    BEGIN
        FOR i IN 1..koty.COUNT LOOP
            suma := suma + koty(i).przydzial;
        END LOOP;
        RETURN suma;
    END;

    FUNCTION wyplata_generator(wszsytkie_koty TABELA_KOCUROW, myszy_nieprzydzielone TABELA_MYSZY, myszy_nowe TABELA_MYSZY, data_pocz DATE) RETURN MYSZY_PARA IS
      sroda_wydania DATE;
      myszy_do_zwrotu MYSZY_PARA;
      myszy_po_wyplacie MYSZY_PARA;
      koty_do_wyplaty TABELA_KOCUROW;
      iter NUMBER;
    BEGIN
      sroda_wydania := (next_day(last_day(data_pocz)-7, 'środa')); --Obliczanie środy wyadania
      koty_do_wyplaty := koty_sprzed_daty(wszsytkie_koty, sroda_wydania);

      myszy_do_zwrotu := myszy_sprzed_daty(myszy_nieprzydzielone, myszy_nowe, sroda_wydania); -- podział na te które można przydzelić bo data sie zgadza
      myszy_po_wyplacie := procedury_49.wyplata_inner(koty_do_wyplaty, myszy_do_zwrotu.przydzielone, sroda_wydania); -- te które zostały lub nie, przydzielone w wyplacie
      myszy_do_zwrotu.przydzielone := myszy_po_wyplacie.przydzielone;
      DBMS_OUTPUT.PUT_LINE('ŁĄczenie MYSZ ' || myszy_do_zwrotu.nieprzydzielone.COUNT || '  ' || myszy_po_wyplacie.nieprzydzielone.COUNT);
      IF myszy_do_zwrotu.nieprzydzielone.COUNT = 0 THEN
        myszy_do_zwrotu.nieprzydzielone := myszy_po_wyplacie.nieprzydzielone;
      ELSE
          iter := myszy_do_zwrotu.nieprzydzielone.COUNT;
          FOR i IN 1..myszy_po_wyplacie.nieprzydzielone.COUNT LOOP
            myszy_do_zwrotu.nieprzydzielone(iter) := myszy_po_wyplacie.nieprzydzielone(i);
            iter := iter +1;
          END LOOP;
      END IF;

    RETURN myszy_do_zwrotu;
    END;

    FUNCTION rozdziel_myszy_w_miesiacu(koty TABELA_KOCUROW, data_pocz DATE) RETURN TABELA_MYSZY IS
        liczba_dni NUMBER;
        spozycie NUMBER;
        myszy TABELA_MYSZY;
        kot KOCUR_TABLICOWY;
        mi NUMBER := 1;
        ki NUMBER := 1;
        lapane_na_dzien NUMBER;
        aktualny_dzien DATE := data_pocz;
    BEGIN
        --temp
        liczba_dni := EXTRACT(DAY FROM last_day(data_pocz));
        spozycie := calkowite_spozycie(koty);
        lapane_na_dzien := spozycie/liczba_dni;
        IF ROUND(lapane_na_dzien) > lapane_na_dzien THEN
            lapane_na_dzien := ROUND(lapane_na_dzien);
        END IF;

        IF ROUND(lapane_na_dzien) < lapane_na_dzien THEN
            lapane_na_dzien := ROUND(lapane_na_dzien) +1;
        END IF;

        myszy(1) := utworz_mysz('TEST', '01-01-2010');
        <<main_loop>> FOR i IN 0..(liczba_dni-1) LOOP
            aktualny_dzien := data_pocz+i;

            FOR j IN 1..lapane_na_dzien LOOP
                kot := koty(ki);
                ki := nast_index(koty.COUNT, ki);
                IF kot.w_stadku_od > aktualny_dzien THEN
                  LOOP
                      kot := koty(ki);
                      ki := nast_index(koty.COUNT, ki);
                      EXIT WHEN kot.w_stadku_od <= aktualny_dzien;
                  END LOOP; 
                END IF;

                myszy(mi) := utworz_mysz(kot.pseudo, aktualny_dzien);
                mi := mi+1;
                EXIT main_loop WHEN mi = spozycie+1;
            END LOOP;
        END LOOP;
        RETURN myszy;
    END;

    PROCEDURE generuj(data_pocz DATE, data_kon DATE) IS
            wszystkie_koty TABELA_KOCUROW;
            wszystkie_myszy TABELA_MYSZY;
            mi NUMBER :=1;
            myszy_tymczasowe TABELA_MYSZY;
            myszy_z_wyplaty MYSZY_PARA;
            koty_miesiac TABELA_KOCUROW;
            data_aktualna DATE := data_pocz;
            lw NUMBER;
            suma_myszy NUMBER := 0;
            wybierz_koty_zapytanie VARCHAR(2048) :=  'SELECT pseudo, NVL(przydzial_myszy,0) + NVL(myszy_extra,0) przydzial, w_stadku_od FROM Kocury k ORDER BY 2';
    BEGIN
        -- pobranie kotow
        EXECUTE IMMEDIATE wybierz_koty_zapytanie BULK COLLECT INTO wszystkie_koty;
        LOOP 
          koty_miesiac := koty_sprzed_daty(wszystkie_koty, last_day(data_aktualna));
          myszy_tymczasowe := rozdziel_myszy_w_miesiacu(koty_miesiac, data_aktualna);
          suma_myszy := suma_myszy + myszy_tymczasowe.COUNT;
          myszy_z_wyplaty := wyplata_generator(wszystkie_koty, myszy_z_wyplaty.nieprzydzielone, myszy_tymczasowe, data_aktualna);
          FOR i IN 1..myszy_z_wyplaty.przydzielone.COUNT LOOP
            wszystkie_myszy(mi) := myszy_z_wyplaty.przydzielone(i);
            mi := mi+1;
          END LOOP;
          data_aktualna := last_day(data_aktualna) + 1;
          EXIT WHEN data_aktualna > data_kon;
      END LOOP;
      FOR i IN 1..myszy_z_wyplaty.nieprzydzielone.COUNT LOOP
        wszystkie_myszy(mi) := myszy_z_wyplaty.nieprzydzielone(i);
        mi := mi+1;
      END LOOP;

      DBMS_OUTPUT.PUT_LINE('WSZYSTKIE MYSZY: ' || wszystkie_myszy.COUNT || '  ' || suma_myszy);

       FORALL i IN 1..wszystkie_myszy.COUNT SAVE EXCEPTIONS
        INSERT INTO Myszy (lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania)
        VALUES 
        (
        wszystkie_myszy(i).lowca,
        wszystkie_myszy(i).zjadacz,
        wszystkie_myszy(i).waga_myszy,
        wszystkie_myszy(i).data_zlowienia,
        wszystkie_myszy(i).data_wydania
        );
        EXCEPTION
            WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE
            ('Pojawil sie wyjatek: '||SQLERRM);
            lw:=SQL%BULK_EXCEPTIONS.COUNT;
            FOR i IN 1..lw
            LOOP
            DBMS_OUTPUT.PUT_LINE('Blad '||i||': myszka '||
            SQL%BULK_EXCEPTIONS(i).error_index||' - '||
            SQL%BULK_EXCEPTIONS(i).error_code);
            END LOOP;
    END generuj;
   
    PROCEDURE utworz_myszy_kota(dzien DATE, pseudo Kocury.pseudo%TYPE, ile_myszy NUMBER) IS
    	query_create VARCHAR2(2048);
    	query_drop VARCHAR2(2048);
    	query_insert VARCHAR2(2048);
    	nazwa_tabeli VARCHAR2(100);
    	mysz MYSZ_DO_DODANIA;
		BEGIN
			nazwa_tabeli := 'Myszy_Kota_' || pseudo;
			query_drop := 'DROP TABLE ' || nazwa_tabeli;
		  query_create := '' ||
			' CREATE TABLE ' || nazwa_tabeli || ' ( ' ||
		  ' nr_myszy NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY CONSTRAINT myk_pk PRIMARY KEY, ' ||
		  ' lowca VARCHAR(15) CONSTRAINT myk_lo_fk REFERENCES Kocury(pseudo), ' ||
		  ' waga_myszy NUMBER  CONSTRAINT wmk_nn NOT NULL, CONSTRAINT myk_wm_ck CHECK(waga_myszy BETWEEN 15 AND 25), ' ||
		  ' data_zlowienia DATE CONSTRAINT dzk_nn NOT NULL) ' ;
		  DBMS_OUTPUT.PUT_LINE(query_create);
          BEGIN
            EXECUTE IMMEDIATE query_drop; 
            exception when others then null;
          END;
      DBMS_OUTPUT.PUT_LINE('create');
		  EXECUTE IMMEDIATE query_create;
      DBMS_OUTPUT.PUT_LINE('created');
		  
		  FOR i IN 1..ile_myszy LOOP
		  	mysz := utworz_mysz(pseudo, dzien);

		  	query_insert :=  '' ||
		  	' INSERT INTO ' || nazwa_tabeli || ' (lowca, waga_myszy, data_zlowienia)' ||
		  	' VALUES (' ||
		  		':lowca' || ',' ||
		  		':waga_myszy' || ',' ||
		  		':data_zlowienia' || 
		  	' )' ;
		  	EXECUTE IMMEDIATE query_insert using mysz.lowca, mysz.waga_myszy, mysz.data_zlowienia;
		  	
		  END LOOP;

    END utworz_myszy_kota;
END generator;

BEGIN
    generator.generuj('01-01-2004','01-01-2004');
END;
BEGIN
    generator.generuj('01-01-2004','15-01-2008');
END;

BEGIN
    GENERATOR.UTWORZ_MYSZY_KOTA('01-01-2018', 'TYGRYS', 10);
END;

BEGIN
    procedury_49.dodaj_myszy_kota('TYGRYS');
END;