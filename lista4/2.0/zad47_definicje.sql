-- Kocury
-- Worgowie_kocurow
-- elita
-- plebs
-- konto

DROP TYPE OT_KOCUR FORCE;
DROP TYPE OT_PLEBS FORCE;
DROP TYPE OT_ELITA FORCE;
DROP TYPE OT_KONTA FORCE;
DROP TYPE OT_WROGOWIE_KOCUROW;

--TYPY

--KOCURY
CREATE OR REPLACE TYPE OT_KOCUR AS OBJECT(
	imie                VARCHAR2(15),
	plec                VARCHAR2(1),
	pseudo              VARCHAR2(15),
	funkcja             VARCHAR2(10),
	szef                REF OT_KOCUR, 
	w_stadku_od         DATE,
	przydzial_myszy     NUMBER(3),
	myszy_extra         NUMBER(3),          
	nr_bandy            NUMBER(2),

	MAP MEMBER FUNCTION PorownajPseudo RETURN VARCHAR2,
	MEMBER FUNCTION CalkowiteSpozycie RETURN NUMBER,
	MEMBER FUNCTION DajSzefa RETURN OT_KOCUR,
	MEMBER FUNCTION DajPlec RETURN VARCHAR2,
	MEMBER FUNCTION MaSzefa RETURN BOOLEAN,
	MEMBER FUNCTION MiesiacWstapienia RETURN NUMBER
); 

CREATE OR REPLACE TYPE BODY OT_KOCUR AS
    MAP MEMBER FUNCTION PorownajPseudo RETURN VARCHAR2
     IS
     BEGIN
     RETURN pseudo;
    END;
    
    MEMBER FUNCTION CalkowiteSpozycie RETURN NUMBER
     IS
     BEGIN
     RETURN NVL(przydzial_myszy,0) + NVL(myszy_extra,0);
    END;
    
    MEMBER FUNCTION DajSzefa RETURN OT_KOCUR
     IS
     kocur_ref OT_KOCUR;
     BEGIN
     SELECT DEREF(szef) into kocur_ref FROM DUAL;
     RETURN kocur_ref;
    END;
    
    MEMBER FUNCTION MaSzefa RETURN BOOLEAN
     IS
     BEGIN
    RETURN szef IS NOT NULL;
    END;
    
    MEMBER FUNCTION DajPlec RETURN VARCHAR2
    AS
		slownie VARCHAR2;
    BEGIN
    	IF plec = 'M' THEN
        slownie := 'Kocor';
	    ELSE
	      slownie := 'Kotka';
	    END IF;
	    RETURN slownie;
    END;
    
    MEMBER FUNCTION MiesiacWstapienia RETURN NUMBER
     IS
     BEGIN
    RETURN EXTRACT (MONTH FROM w_stadku_od);
    END;
END;

--PLEBS
CREATE OR REPLACE TYPE OT_PLEBS AS OBJECT(
	nr_plebsu           NUMBER,
	kocur   REF            OT_KOCUR,

	MAP MEMBER FUNCTION PorownajPseudo RETURN VARCHAR2
); 

CREATE OR REPLACE TYPE BODY OT_PLEBS AS
    MAP MEMBER FUNCTION PorownajPseudo RETURN VARCHAR2
    IS
    kocur_ref OT_KOCUR;
    BEGIN
     	SELECT DEREF(kocur) into kocur_ref FROM DUAL;
     	RETURN kocur_ref.pseudo;
   	END;
END;

--ELITA
CREATE OR REPLACE TYPE OT_ELITA AS OBJECT(
	nr_elity              NUMBER,
  kocur   REF           OT_KOCUR,
  sluga REF             OT_PLEBS,

  MAP MEMBER FUNCTION PorownajPseudo RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY OT_ELITA AS
    MAP MEMBER FUNCTION PorownajPseudo RETURN VARCHAR2
    IS
    kocur_ref OT_KOCUR;
    BEGIN
     SELECT DEREF(kocur) into kocur_ref FROM DUAL;
     RETURN kocur_ref.pseudo;
    END;
END;

--KONTA
CREATE OR REPLACE TYPE OT_KONTO AS OBJECT(
	nr_wpisu              NUMBER,
  elita   REF            OT_ELITA,
  data_przyznania        DATE,
  data_oddania           DATE
);
--WROGOWIE_KOCUROW
CREATE OR REPLACE TYPE OT_WROGOWIE_KOCUROW AS OBJECT(
	nr_incydentu				NUMBER,
	kot 								REF OT_KOCUR,
	imie_wroga          VARCHAR2(15),
	data_incydentu      DATE,
	opis_incdentu       VARCHAR2(50)
);


--RELACJE



--KOCURY
CREATE TABLE O_Kocury OF OT_KOCUR (
	CONSTRAINT tk_im CHECK(imie IS NOT NULL),
  CONSTRAINT tk_pl CHECK (plec IN ('M', 'D')),
  CONSTRAINT tk_pk PRIMARY KEY (pseudo),
  szef SCOPE IS O_Kocury
)

--PLEBS
CREATE TABLE O_Plebs OF OT_PLEBS (
	kocur SCOPE IS O_Kocury,
  CONSTRAINT op_pk PRIMARY KEY (nr_plebsu)
)
--ELITA
CREATE TABLE O_Elita OF OT_ELITA (
	kocur SCOPE IS O_Kocury,
  sluga SCOPE IS O_Plebs,
  CONSTRAINT er_pk PRIMARY KEY (nr_elity)
)
--KONTA
CREATE TABLE O_Konta OF OT_KONTO (
	elita SCOPE IS O_Elita,
  CONSTRAINT kr_pk PRIMARY KEY (nr_wpisu)
)
--WROGOWIE_KOCUROW
CREATE TABLE O_Wrogowie_Kocurow OF OT_WROGOWIE_KOCUROW (
	kot SCOPE IS O_Kocury,
	CONSTRAINT wk_pk PRIMARY KEY (nr_incydentu)
)

--UZUPEŁNIENIE DANYCH

--KOCURY

INSERT INTO O_Kocury VALUES (OT_KOCUR('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1));
INSERT INTO O_Kocury VALUES (OT_KOCUR('MICKA','D','LOLA','MILUSIA',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='TYGRYS'),'2009-10-14',25,47,1));
INSERT INTO O_Kocury VALUES (OT_KOCUR('CHYTRY','M','BOLEK','DZIELCZY',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='TYGRYS'),'2002-05-05',50,NULL,1));
INSERT INTO O_Kocury VALUES (OT_KOCUR('KOREK','M','ZOMBI','BANDZIOR',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='TYGRYS'),'2004-03-16',75,13,3));
INSERT INTO O_Kocury VALUES (OT_KOCUR('BOLEK','M','LYSY','BANDZIOR',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='TYGRYS'),'2006-08-15',72,21,2));
INSERT INTO O_Kocury VALUES (OT_KOCUR('RUDA','D','MALA','MILUSIA',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='TYGRYS'),'2006-09-17',22,42,1));
INSERT INTO O_Kocury VALUES (OT_KOCUR('PUCEK','M','RAFA','LOWCZY',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='TYGRYS'),'2006-10-15',65,NULL,4));
INSERT INTO O_Kocury VALUES (OT_KOCUR('PUNIA','D','KURKA','LOWCZY',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='ZOMBI'),'2008-01-01',61,NULL,3));
INSERT INTO O_Kocury VALUES (OT_KOCUR('JACEK','M','PLACEK','LOWCZY',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='LYSY'),'2008-12-01',67,NULL,2));
INSERT INTO O_Kocury VALUES (OT_KOCUR('BARI','M','RURA','LAPACZ',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='LYSY'),'2009-09-01',56,NULL,2));
INSERT INTO O_Kocury VALUES (OT_KOCUR('LUCEK','M','ZERO','KOT',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='KURKA'),'2010-03-01',43,NULL,3));
INSERT INTO O_Kocury VALUES (OT_KOCUR('SONIA','D','PUSZYSTA','MILUSIA',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='ZOMBI'),'2010-11-18',20,35,3));
INSERT INTO O_Kocury VALUES (OT_KOCUR('LATKA','D','UCHO','KOT',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='RAFA'),'2011-01-01',40,NULL,4));
INSERT INTO O_Kocury VALUES (OT_KOCUR('DUDEK','M','MALY','KOT',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='RAFA'),'2011-05-15',40,NULL,4));
INSERT INTO O_Kocury VALUES (OT_KOCUR('ZUZIA','D','SZYBKA','LOWCZY',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='LYSY'),'2006-07-21',65,NULL,2));
INSERT INTO O_Kocury VALUES (OT_KOCUR('BELA','D','LASKA','MILUSIA',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='LYSY'),'2008-02-01',24,28,2));
INSERT INTO O_Kocury VALUES (OT_KOCUR('KSAWERY','M','MAN','LAPACZ',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='RAFA'),'2008-07-12',51,NULL,4));
INSERT INTO O_Kocury VALUES (OT_KOCUR('MELA','D','DAMA','LAPACZ',(SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='RAFA'),'2008-11-01',51,NULL,4));

--PLEBS

INSERT INTO O_Plebs VALUES (OT_PLEBS(1, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='SZYBKA'))); 
INSERT INTO O_Plebs VALUES (OT_PLEBS(2, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='KURKA'))); 
INSERT INTO O_Plebs VALUES (OT_PLEBS(3, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='MAN'))); 
INSERT INTO O_Plebs VALUES (OT_PLEBS(4, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='DAMA'))); 
INSERT INTO O_Plebs VALUES (OT_PLEBS(5, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='MALA')));
INSERT INTO O_Plebs VALUES (OT_PLEBS(6, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='PLACEK'))); 
INSERT INTO O_Plebs VALUES (OT_PLEBS(7, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='RURA'))); 
INSERT INTO O_Plebs VALUES (OT_PLEBS(8, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='ZERO'))); 
INSERT INTO O_Plebs VALUES (OT_PLEBS(9, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='PUSZYSTA'))); 
INSERT INTO O_Plebs VALUES (OT_PLEBS(10, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='UCHO'))); 
INSERT INTO O_Plebs VALUES (OT_PLEBS(11, (SELECT REF(kocur) FROM O_Kocury kocur WHERE kocur.pseudo='MALY')));

--ELITA
 
INSERT INTO O_Elita VALUES (OT_ELITA(1, (SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='TYGRYS'), (SELECT REF(sluga) FROM O_Plebs sluga WHERE sluga.kocur.pseudo = 'UCHO')));
INSERT INTO O_Elita VALUES (OT_ELITA(2, (SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='LOLA'), (SELECT REF(sluga) FROM O_Plebs sluga WHERE sluga.kocur.pseudo = 'MALA')));
INSERT INTO O_Elita VALUES (OT_ELITA(3, (SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='ZOMBI'), (SELECT REF(sluga) FROM O_Plebs sluga WHERE sluga.kocur.pseudo = 'RURA')));
INSERT INTO O_Elita VALUES (OT_ELITA(4, (SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='LYSY'), (SELECT REF(sluga) FROM O_Plebs sluga WHERE sluga.kocur.pseudo = 'ZERO')));
INSERT INTO O_Elita VALUES (OT_ELITA(5, (SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='BOLEK'), (SELECT REF(sluga) FROM O_Plebs sluga WHERE sluga.kocur.pseudo = 'PUSZYSTA')));
INSERT INTO O_Elita VALUES (OT_ELITA(6, (SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='RAFA'), (SELECT REF(sluga) FROM O_Plebs sluga WHERE sluga.kocur.pseudo = 'MALY')));
INSERT INTO O_Elita VALUES (OT_ELITA(7, (SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='LASKA'), (SELECT REF(sluga) FROM O_Plebs sluga WHERE sluga.kocur.pseudo = 'SZYBKA'))); 

--KONTA

 
INSERT INTO O_Konta VALUES (1, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=1), '2017-12-01', '2017-12-03'); 
INSERT INTO O_Konta VALUES (2, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=2), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (3, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=1), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (4, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=1), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (5, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=5), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (6, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=6), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (7, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=2), '2017-12-01', SYSDATE);
INSERT INTO O_Konta VALUES (8, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=3), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (9, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=2), '2017-12-01', SYSDATE); 
INSERT INTO O_Konta VALUES (10, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=7), '2017-12-01', SYSDATE); 
INSERT INTO O_Konta VALUES (11, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=2), '2017-12-01', NULL);
INSERT INTO O_Konta VALUES (12, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=2), '2017-12-01', NULL);
INSERT INTO O_Konta VALUES (13, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=3), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (14, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=7), '2017-12-01', '2017-12-03'); 
INSERT INTO O_Konta VALUES (15, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=7), '2017-12-01', SYSDATE); 
INSERT INTO O_Konta VALUES (16, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=2), '2017-12-01', SYSDATE);
INSERT INTO O_Konta VALUES (17, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=2), '2017-12-01', SYSDATE);
INSERT INTO O_Konta VALUES (18, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=1), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (19, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=1), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (20, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=5), '2017-12-01', NULL); 
INSERT INTO O_Konta VALUES (21, (SELECT REF(kot) FROM O_Elita kot WHERE kot.nr_elity=2), '2017-12-01', NULL);


--WROGOWIE_KOCUROW

INSERT INTO O_Wrogowie_Kocurow VALUES (1,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='TYGRYS'),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY');
INSERT INTO O_Wrogowie_Kocurow VALUES (2,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='ZOMBI'),'SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY');
INSERT INTO O_Wrogowie_Kocurow VALUES (3,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='BOLEK'),'KAZIO','2005-03-29','POSZCZUL BURKIEM');
INSERT INTO O_Wrogowie_Kocurow VALUES (4,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='SZYBKA'),'GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI');
INSERT INTO O_Wrogowie_Kocurow VALUES (5,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='MALA'),'CHYTRUSEK','2007-03-07','ZALECAL SIE');
INSERT INTO O_Wrogowie_Kocurow VALUES (6,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='TYGRYS'),'DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA');
INSERT INTO O_Wrogowie_Kocurow VALUES (7,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='BOLEK'),'DZIKI BILL','2007-11-10','ODGRYZL UCHO');
INSERT INTO O_Wrogowie_Kocurow VALUES (8,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='LASKA'),'DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA');
INSERT INTO O_Wrogowie_Kocurow VALUES (9,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='LASKA'),'KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK');
INSERT INTO O_Wrogowie_Kocurow VALUES (10,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='DAMA'),'KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY');
INSERT INTO O_Wrogowie_Kocurow VALUES (11,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='MAN'),'REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL');
INSERT INTO O_Wrogowie_Kocurow VALUES (12,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='LYSY'),'BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA');
INSERT INTO O_Wrogowie_Kocurow VALUES (13,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='RURA'),'DZIKI BILL','2009-09-03','ODGRYZL OGON');
INSERT INTO O_Wrogowie_Kocurow VALUES (14,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='PLACEK'),'BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA');
INSERT INTO O_Wrogowie_Kocurow VALUES (15,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='PUSZYSTA'),'SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI');
INSERT INTO O_Wrogowie_Kocurow VALUES (16,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='KURKA'),'BUREK','2010-12-14','POGONIL');
INSERT INTO O_Wrogowie_Kocurow VALUES (17,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='MALY'),'CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA');
INSERT INTO O_Wrogowie_Kocurow VALUES (18,(SELECT REF(kot) FROM O_Kocury kot WHERE kot.pseudo='UCHO'),'SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI');