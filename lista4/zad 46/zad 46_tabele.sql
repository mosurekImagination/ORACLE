DROP TABLE ObjKoty;
DROP TABLE ObjPlebs;
DROP TABLE ObjELita;
DROP TABLE ObjKonta;

CREATE TABLE ObjKoty OF Koty (
    CONSTRAINT check_imie CHECK(imie IS NOT NULL),
    CONSTRAINT check_plec CHECK(plec IN ('M','D')),
    CONSTRAINT koty_pk PRIMARY KEY(pseudo),
    w_stadku_od DEFAULT (SYSDATE)
);

CREATE TABLE ObjPlebs OF Plebs (
    CONSTRAINT plebs_PK PRIMARY KEY(nr_plebsu),
    kot SCOPE IS ObjKoty
);

CREATE TABLE ObjElita OF Elita(
    CONSTRAINT elita_pk PRIMARY KEY(nr_czlonka_elity),
    kot SCOPE IS ObjKoty,
    sluga SCOPE IS ObjPlebs
);

CREATE TABLE ObjKonta OF Konta (
    CONSTRAINT konto_pk PRIMARY KEY(nr_konta),
    wlasciciel SCOPE IS ObjElita,
    CONSTRAINT check_dw CHECK(data_wprowadzenia IS NOT NULL)
);


    
    