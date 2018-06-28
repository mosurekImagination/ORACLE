DECLARE 
BEGIN FOR i in 1..5 
  LOOP 
    insert into myszy 
    values(i+145738, 'TYGRYS', null, 26, '2018-01-21', null); 
  END LOOP;
END; 

DECLARE 
BEGIN FOR i in 1..10
  LOOP 
    insert into LYSY 
    values(i, 3,TO_DATE('2018-01-17', 'yyyy-mm-dd')); 
  END LOOP;
END; 

DECLARE 
BEGIN FOR i in 1..5
  LOOP 
    insert into RURA 
    values(i, 3,TO_DATE('2018-01-17', 'yyyy-mm-dd')); 
  END LOOP;
END; 

DECLARE 
BEGIN FOR i in 1..20
  LOOP 
    insert into ZOMBI 
    values(i, 3,TO_DATE('2018-01-17', 'yyyy-mm-dd')); 
  END LOOP;
END; 

select * from myszy order by nr_myszy desc;

delete from myszy;

SELECT COUNT(*) FROM MYSZY;

DECLARE 
BEGIN 
  WYPLATA(); 
END; 

DECLARE 
BEGIN
    PRZYJECIE_MYSZY_NA_STAN('ZOMBI',TO_DATE('2018-01-17', 'yyyy-mm-dd'));
END;

DECLARE 
BEGIN
    PRZYJECIE_MYSZY_NA_STAN('RURA',TO_DATE('2018-01-17', 'yyyy-mm-dd'));
END;
DECLARE 
BEGIN
    PRZYJECIE_MYSZY_NA_STAN('LYSY',TO_DATE('2018-01-17', 'yyyy-mm-dd'));
END;
SELECT * FROM LYSY WHERE data_zlowienia=TO_DATE('2018-01-17', 'yyyy-mm-dd');

rollback;

SELECT COUNT(*) FROM MYSZY;