-- Zadanie 40
-- Zdefiniować wyzwalacz, który zapewni,
-- że numer nowej bandy będzie zawsze większy o 1
-- od najwyższego numeru istniejącej już bandy.
--
-- Sprawdzić działanie wyzwalacza wykorzystując procedurę z zadania 40.

CREATE OR REPLACE TRIGGER zad40
BEFORE INSERT ON Bandy
FOR EACH ROW
BEGIN
  SELECT MAX(nr_bandy) + 1 INTO :new.nr_bandy FROM Bandy;
END;


SET AUTOCOMMIT OFF;

BEGIN
  nowa_banda(77, 'BLE', 'BLE BLE');
END;

SELECT nr_bandy FROM Bandy WHERE nazwa='BLE';

ROLLBACK;
SET AUTOCOMMIT ON;