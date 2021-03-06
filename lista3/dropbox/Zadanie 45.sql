-- Zadanie 45
-- Tygrys zauważył dziwne zmiany wartości swojego prywatnego przydziału myszy
-- (patrz zadanie 42).
-- 
-- Nie niepokoiły go zmiany na plus ale te na minus były,
-- jego zdaniem, niedopuszczalne.
-- Zmotywował więc jednego ze swoich szpiegów do działania 
-- i dzięki temu odkrył niecne praktyki Miluś (zadanie 42).
-- Polecił więc swojemu informatykowi skonstruowanie mechanizmu zapisującego
-- w relacji Dodatki_extra (patrz Wykłady - cz. 2) dla każdej z Miluś -10
-- (minus dziesięć) myszy dodatku extra przy zmianie na plus któregokolwiek
-- z przydziałów myszy Miluś, wykonanej przez innego operatora niż on sam.
--
-- Zaproponować taki mechanizm, w zastępstwie za informatyka Tygrysa.
-- W rozwiązaniu wykorzystać funkcję LOGIN_USER zwracającą nazwę użytkownika
-- aktywującego wyzwalacz oraz elementy dynamicznego SQL'a.

DROP TABLE Dodatki_extra;
CREATE TABLE Dodatki_extra (
 id_dodatku NUMBER(2) GENERATED BY DEFAULT ON NULL AS IDENTITY
  CONSTRAINT dx_pk PRIMARY KEY,
 pseudo VARCHAR2(15) CONSTRAINT dx_fk_k REFERENCES Kocury(pseudo),
 dodatek_extra NUMBER(3) NOT NULL
);

CREATE OR REPLACE TRIGGER Zad455
AFTER UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  IF  :new.przydzial_myszy > :old.przydzial_myszy
  AND :new.funkcja = 'MILUSIA'
  AND LOGIN_USER != 'TYGRYS' THEN
    EXECUTE IMMEDIATE '
      BEGIN
      FOR kot IN (SELECT K.pseudo as pseudo, D.dod_extra as dodatek FROM Kocury K LEFT JOIN Dodatki_extra D ON K.pseudo = D.pseudo WHERE funkcja = ''MILUSIA'')
      LOOP
        IF (kot.dodatek IS NULL) THEN
          INSERT INTO Dodatki_extra(pseudo, dod_extra)
          VALUES (kot.pseudo, -10);
        ELSE
          UPDATE Dodatki_extra SET dod_extra = kot.dodatek -10 WHERE pseudo = kot.pseudo;
        END IF;
        
      END LOOP;
    END;';
    COMMIT;
  END IF;
END;