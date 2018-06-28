CREATE OR REPLACE PACKAGE procedury_49 AS
    FUNCTION wyplata_inner(koty_temp generator.TABELA_KOCUROW, myszy_temp generator.TABELA_MYSZY, sroda_wydania DATE) RETURN generator.MYSZY_PARA;
    PROCEDURE wyplata(data DATE);
    PROCEDURE dodaj_myszy_kota(pseudo Kocury.pseudo%TYPE);
END procedury_49;

CREATE OR REPLACE PACKAGE BODY procedury_49 AS
    FUNCTION wyplata_inner(koty_temp generator.TABELA_KOCUROW, myszy_temp generator.TABELA_MYSZY, sroda_wydania DATE) RETURN generator.MYSZY_PARA IS
        index_myszy NUMBER := 1;
        index_myszy_pop Number;
        iter NUMBER :=1;
        koty generator.TABELA_KOCUROW;
        myszy generator.TABELA_MYSZY;
        myszy_po_rozdzieleniu generator.MYSZY_PARA;
    BEGIN
        koty := koty_temp; -- copy table modify on parameter is not allowed
        myszy := myszy_temp; -- copy table

        <<myszy_loop>> LOOP
            index_myszy_pop := index_myszy;
            FOR index_kocury IN 1..koty.COUNT LOOP
                EXIT myszy_loop WHEN index_myszy > myszy.COUNT;
                IF(koty(index_kocury).przydzial > 0) THEN
                    myszy(index_myszy).zjadacz := koty(index_kocury).pseudo;
                    myszy(index_myszy).data_wydania := sroda_wydania;
                    koty(index_kocury).przydzial := koty(index_kocury).przydzial  - 1;
                    index_myszy := index_myszy + 1;
                END IF;
            END LOOP;
            EXIT myszy_loop WHEN index_myszy_pop = index_myszy; -- Nie przydzielono myszy żadnemu kotu, ale myszy jeszcze są.
        END LOOP;

        FOR i IN 1..(index_myszy-1) LOOP
            myszy_po_rozdzieleniu.przydzielone(iter) := myszy(i);
            iter := iter+1;
        END LOOP;
        iter := 1;

        FOR i IN (index_myszy)..myszy.COUNT LOOP
            myszy_po_rozdzieleniu.nieprzydzielone(iter) := myszy(i);
            iter := iter+1;
        END LOOP;

    RETURN myszy_po_rozdzieleniu;
    END wyplata_inner;

    PROCEDURE wyplata(data DATE) IS
        sroda_wydania DATE;
        pseduo_select_string VARCHAR(2048) := 'SELECT pseudo, (NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) przydzial, w_stadku_od FROM Kocury k WHERE k.w_stadku_od < :data ORDER BY przydzial';
        kocury_tabela generator.TABELA_KOCUROW;
        myszy_tabela generator.TABELA_MYSZY;
        myszy_select_string VARCHAR(2048) := 'SELECT * FROM Myszy m WHERE m.data_zlowienia < :data AND m.zjadacz IS NULL ORDER BY m.data_zlowienia';
        rozdzielone_myszy generator.MYSZY_PARA;
    BEGIN
        sroda_wydania := (next_day(last_day(data)-7, 'środa'));
        EXECUTE IMMEDIATE myszy_select_string BULK COLLECT INTO myszy_tabela USING sroda_wydania; 
        EXECUTE IMMEDIATE pseduo_select_string BULK COLLECT INTO kocury_tabela USING sroda_wydania;
        rozdzielone_myszy := wyplata_inner(kocury_tabela, myszy_tabela, sroda_wydania);


        FORALL i IN 1..(rozdzielone_myszy.przydzielone.COUNT) SAVE EXCEPTIONS
            UPDATE Myszy m
            SET 
               m.zjadacz =  rozdzielone_myszy.przydzielone(i).zjadacz,
               m.data_wydania = rozdzielone_myszy.przydzielone(i).data_wydania
            WHERE 
                m.nr_myszy = rozdzielone_myszy.przydzielone(i).nr_myszy;
    END wyplata;
    
    PROCEDURE dodaj_myszy_kota(pseudo Kocury.pseudo%TYPE) IS
        myszy_tabela generator.TABELA_MYSZY;
        myszy_kota_select VARCHAR(200);
    BEGIN
        myszy_kota_select := 'SELECT nr_myszy, lowca, null zjadacz, waga_myszy, data_zlowienia, null data_wydania FROM Myszy_Kota_' || pseudo;
        DBMS_OUTPUT.PUT_LINE(myszy_kota_select);
        EXECUTE IMMEDIATE myszy_kota_select BULK COLLECT INTO myszy_tabela;
        FOR i IN 1..myszy_tabela.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('lowca: ' || myszy_tabela(i).lowca || ', zjadacz: ' ||
                myszy_tabela(i).zjadacz || ', waga: ' ||
                myszy_tabela(i).waga_myszy || ', data_zlow: ' ||
                myszy_tabela(i).data_zlowienia || ', data_wyd: ' ||
                myszy_tabela(i).data_wydania);
        END LOOP;
        FORALL i IN 1..myszy_tabela.COUNT SAVE EXCEPTIONS
            INSERT INTO Myszy (lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania)
            VALUES 
            (
                myszy_tabela(i).lowca,
                myszy_tabela(i).zjadacz,
                myszy_tabela(i).waga_myszy,
                myszy_tabela(i).data_zlowienia,
                myszy_tabela(i).data_wydania
            );
    END dodaj_myszy_kota;
END procedury_49;