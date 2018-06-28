SET SERVEROUTPUT ON
DECLARE
    i NUMBER :=1;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('nr', 5, ' ') || RPAD('Pseudonim', 12, ' ') || 'zjada');
    DBMS_OUTPUT.PUT_LINE(RPAD('_', 22, '_'));

    FOR re IN (SELECT pseudo, przydzial_myszy + NVL(myszy_extra, 0) as zjada
            FROM Kocury
            ORDER BY 2 DESC)
                     
    LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(i, 5, ' ') || RPAD(re.pseudo, 12, ' ') || LPAD(re.zjada, 5, ' '));
        i:=i+1;
        EXIT WHEN i = 6;
    END LOOP;
END;
