CREATE TABLE angajat (
    angajat_id   NUMBER(2) NOT NULL,
    librarie_id  NUMBER(3) NOT NULL,
    nume_angajat VARCHAR2(20) NOT NULL
)
LOGGING;

ALTER TABLE angajat
    ADD CONSTRAINT angajat_nume_ck CHECK ( length(nume_angajat) > 1 );

ALTER TABLE angajat ADD CONSTRAINT angajat_pk PRIMARY KEY ( angajat_id );

CREATE TABLE client (
    client_id       NUMBER(2) NOT NULL,
    nume_client     VARCHAR2(30),
    cnp_client      VARCHAR2(13) NOT NULL,
    nr_card         VARCHAR2(16) NOT NULL,
    telefon         VARCHAR2(10),
    adresa          VARCHAR2(30),
    card_fidelitate NUMBER
)
LOGGING;

ALTER TABLE client
    ADD CONSTRAINT client_nume_ck CHECK ( length(nume_client) > 1 );

ALTER TABLE client
    ADD CONSTRAINT client_cnp_ck CHECK ( length(cnp_client) = 13 );

ALTER TABLE client
    ADD CONSTRAINT client_nr_card_ck CHECK ( length(nr_card) = 16 );

ALTER TABLE client
    ADD CONSTRAINT client_telefon_ck CHECK ( length(telefon) = 10 );

ALTER TABLE client
    ADD CONSTRAINT client_adresa_ck CHECK ( length(adresa) > 1 );

ALTER TABLE client ADD CONSTRAINT client_pk PRIMARY KEY ( client_id );

ALTER TABLE client ADD CONSTRAINT client_cnp_client_uk UNIQUE ( cnp_client );

ALTER TABLE client ADD CONSTRAINT client_nr_card_uk UNIQUE ( nr_card );

ALTER TABLE client ADD CONSTRAINT client_telefon_uk UNIQUE ( telefon );

CREATE TABLE detalii_angajat (
    angajat_id  NUMBER(2) NOT NULL,
    cnp_angajat VARCHAR2(13) NOT NULL,
    adresa      VARCHAR2(30) NOT NULL,
    telefon     VARCHAR2(10) NOT NULL,
    email       VARCHAR2(30) NOT NULL
)
LOGGING;

ALTER TABLE detalii_angajat
    ADD CONSTRAINT detalii_angajat_cnp_ck CHECK ( length(cnp_angajat) = 13 );

ALTER TABLE detalii_angajat
    ADD CONSTRAINT detalii_angajat_adresa_ck CHECK ( length(adresa) > 1 );

ALTER TABLE detalii_angajat
    ADD CONSTRAINT detalii_angajat_telefon_ck CHECK ( length(telefon) = 10 );

ALTER TABLE detalii_angajat
    ADD CONSTRAINT detalii_angajat_email_ck CHECK ( REGEXP_LIKE ( email,
                                                                  '[a-z0-9._%-]+@[a-z0-9._%-]+\.[a-z]{2,4}' ) );

CREATE UNIQUE INDEX detalii_angajat__idx ON
    detalii_angajat (
        angajat_id
    ASC )
        LOGGING;

ALTER TABLE detalii_angajat ADD CONSTRAINT detalii_angajat_pk PRIMARY KEY ( angajat_id );

ALTER TABLE detalii_angajat ADD CONSTRAINT detalii_angajat_cnp_uk UNIQUE ( cnp_angajat );

ALTER TABLE detalii_angajat ADD CONSTRAINT detalii_angajat_telefon_uk UNIQUE ( telefon );

CREATE TABLE detalii_vanzare (
    produse_produs_id   NUMBER(3) NOT NULL,
    vanzare_nr_bon      NUMBER(3) NOT NULL,
    cantitate_cumparata NUMBER(2) NOT NULL,
    pret_final          FLOAT(10) NOT NULL
)
LOGGING;

ALTER TABLE detalii_vanzare ADD CONSTRAINT detalii_vanzare_cant_cmp_ck CHECK ( cantitate_cumparata < 20 );

ALTER TABLE detalii_vanzare ADD CONSTRAINT produse_vanzare_fk_pk PRIMARY KEY ( produse_produs_id,
                                                                               vanzare_nr_bon );

CREATE TABLE furnizori (
    furnizor_id   NUMBER(3) NOT NULL,
    nume_furnizor VARCHAR2(30) NOT NULL,
    adresa        VARCHAR2(20) NOT NULL,
    email         VARCHAR2(30) NOT NULL
)
LOGGING;

ALTER TABLE furnizori
    ADD CONSTRAINT furnizori_nume_ck CHECK ( length(nume_furnizor) > 1 );

ALTER TABLE furnizori
    ADD CONSTRAINT furnizori_adresa_ck CHECK ( length(adresa) > 1 );

ALTER TABLE furnizori
    ADD CONSTRAINT furnizori_email_ck CHECK ( REGEXP_LIKE ( email,
                                                            '[a-z0-9._%-]+@[a-z0-9._%-]+\.[a-z]{2,4}' ) );

ALTER TABLE furnizori ADD CONSTRAINT furnizori_pk PRIMARY KEY ( furnizor_id );

CREATE TABLE librarie (
    librarie_id NUMBER(3) NOT NULL,
    adresa      VARCHAR2(30) NOT NULL,
    telefon     VARCHAR2(10) NOT NULL,
    email       VARCHAR2(30)
)
LOGGING;

ALTER TABLE librarie ADD CONSTRAINT librarie_pk PRIMARY KEY ( librarie_id );

ALTER TABLE librarie ADD CONSTRAINT librarie_telefon_uk UNIQUE ( telefon );

CREATE TABLE produse (
    produs_id             NUMBER(3) NOT NULL,
    nume_produs           VARCHAR2(30) NOT NULL,
    pret                  FLOAT(10) NOT NULL,
    cantitate_disponibila NUMBER(2) NOT NULL,
    furnizor_id           NUMBER(3) NOT NULL
)
LOGGING;

ALTER TABLE produse
    ADD CONSTRAINT produse_nume_ck CHECK ( length(nume_produs) > 1 );

ALTER TABLE produse ADD CONSTRAINT produse_pret_ck CHECK ( pret > 0 );

ALTER TABLE produse ADD CONSTRAINT produse_cantitate_disp_ck CHECK ( cantitate_disponibila >= 0 );

ALTER TABLE produse ADD CONSTRAINT produse_pk PRIMARY KEY ( produs_id );

CREATE TABLE vanzare (
    nr_bon     NUMBER(3) NOT NULL,
    data       DATE NOT NULL,
    angajat_id NUMBER(2) NOT NULL,
    client_id  NUMBER(2) NOT NULL,
    nr_card    VARCHAR2(16) NOT NULL
)
LOGGING;

ALTER TABLE vanzare
    ADD CONSTRAINT vanzare_nr_card_ck CHECK ( length(nr_card) = 16 );

ALTER TABLE vanzare ADD CONSTRAINT vanzare_pk PRIMARY KEY ( nr_bon );

ALTER TABLE detalii_angajat
    ADD CONSTRAINT angajat_detalii_angajat_fk FOREIGN KEY ( angajat_id )
        REFERENCES angajat ( angajat_id )
    NOT DEFERRABLE;

ALTER TABLE vanzare
    ADD CONSTRAINT angajat_vanzare_fk FOREIGN KEY ( angajat_id )
        REFERENCES angajat ( angajat_id )
    NOT DEFERRABLE;

ALTER TABLE vanzare
    ADD CONSTRAINT client_vanzare_fk FOREIGN KEY ( client_id )
        REFERENCES client ( client_id )
    NOT DEFERRABLE;

ALTER TABLE produse
    ADD CONSTRAINT furnizori_produse_fk FOREIGN KEY ( furnizor_id )
        REFERENCES furnizori ( furnizor_id )
    NOT DEFERRABLE;

ALTER TABLE angajat
    ADD CONSTRAINT librarie_angajat_fk FOREIGN KEY ( librarie_id )
        REFERENCES librarie ( librarie_id )
    NOT DEFERRABLE;

ALTER TABLE detalii_vanzare
    ADD CONSTRAINT produse_vanzare_fk_produse_fk FOREIGN KEY ( produse_produs_id )
        REFERENCES produse ( produs_id )
    NOT DEFERRABLE;

ALTER TABLE detalii_vanzare
    ADD CONSTRAINT produse_vanzare_fk_vanzare_fk FOREIGN KEY ( vanzare_nr_bon )
        REFERENCES vanzare ( nr_bon )
    NOT DEFERRABLE;

CREATE OR REPLACE TRIGGER trg_Angajat_nume 
    BEFORE INSERT OR UPDATE ON Angajat 
    FOR EACH ROW 
BEGIN
	IF(INSTR(:new.nume_angajat, ' ')=0)
	THEN
		RAISE_APPLICATION_ERROR(-20950, 'Forma numelui nu este corecta!');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_Client_cnp 
    BEFORE INSERT OR UPDATE ON Client 
    FOR EACH ROW 
BEGIN
	IF( ADD_MONTHS( TO_DATE(  substr(:new.cnp_client, 6, 2) ||'.'||substr(:new.cnp_client, 4, 2) || '.' || case when substr(:new.cnp_client, 2, 2) > 21 then 19 || substr(:new.cnp_client, 2, 2) else 20||substr(:new.cnp_client, 2, 2) end, 'DD-MM-YYYY'), 168) > TRUNC(SYSDATE)) 
	THEN 
		RAISE_APPLICATION_ERROR(-20950, 'Clientul nu are varsta necesara pentru a cumpara din librarie!');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_Client_nume 
    BEFORE INSERT OR UPDATE ON Client 
    FOR EACH ROW 
BEGIN
	IF(INSTR(:new.nume_client, ' ')=0)
	THEN
		RAISE_APPLICATION_ERROR(-20950, 'Forma numelui nu este corecta!');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_Detalii_angajat_cnp 
    BEFORE INSERT OR UPDATE ON Detalii_angajat 
    FOR EACH ROW 
BEGIN
	IF( ADD_MONTHS( TO_DATE(  substr(:new.cnp_angajat, 6, 2) ||'.'||substr(:new.cnp_angajat, 4, 2) || '.' || case when substr(:new.cnp_angajat, 2, 2) > 21 then 19 || substr(:new.cnp_angajat, 2, 2) else 20||substr(:new.cnp_angajat, 2, 2) end, 'DD-MM-YYYY'), 216) > TRUNC(SYSDATE)) 
	THEN 
		RAISE_APPLICATION_ERROR(-20950, 'Angajatul nu are varsta necesara pentru a lucra in librarie!');
	END IF;
END; 
/

CREATE OR REPLACE TRIGGER trg_Detalii_vanzare_reduceri 
    BEFORE INSERT OR UPDATE ON Detalii_vanzare 
    FOR EACH ROW 
BEGIN
	declare
	   p  produse.pret%type;
	   idp  detalii_vanzare.produse_produs_id%type;
	   bon  detalii_vanzare.vanzare_nr_bon%type;
	   idx  produse.produs_id%type;
	   idc  vanzare.client_id%type;
	   c    client.card_fidelitate%type;
	   d    vanzare.data%type;
	   cnt  detalii_vanzare.cantitate_cumparata%type;
	   cntd  produse.cantitate_disponibila%type;
	begin
	    idp := :new.produse_produs_id;
	    bon := :new.vanzare_nr_bon;
	    cnt := :new.cantitate_cumparata;
	    select pret into p from produse where idp=produse.produs_id;

	    select client_id into idc from vanzare where bon=vanzare.nr_bon;
	    select card_fidelitate into c from client where idc=client.client_id;
	    
	    select cantitate_disponibila into cntd from produse where idp=produse.produs_id;
	    
	    select data into d from vanzare where bon=vanzare.nr_bon;
	    
	    select produs_id into idx from produse where nume_produs='XEROX';
	    if( idp != idx)
	    then
	        p := p * cnt;
	        :new.pret_final := p;
	        update produse set cantitate_disponibila = cntd - cnt where idp=produse.produs_id;
	    else
	        p := p * cnt;
	        :new.pret_final := p;
	    end if;
	    if(c = 1)
	    then
	        p := p - p * 0.2;
	        if(p = 0)
	        then
	            RAISE_APPLICATION_ERROR(-20950, 'Pretul nu poate fi mai mic sau egal ca 0');
	            :new.pret_final := 1;
	        else
	            :new.pret_final := p;
	        end if;
	    else
	        :new.pret_final := p;
	    end if;
	    
	    if( to_char(d, 'dd-mm') = to_char(to_date('01.06.2021', 'dd-mm-yyyy'), 'dd-mm'))
	    then
	        p := p - p * 0.5;
	        if(p = 0)
	        then
	            RAISE_APPLICATION_ERROR(-20950, 'Pretul nu poate fi mai mic sau egal ca 0');
	            :new.pret_final := 1;
	        else
	            :new.pret_final := p;
	        end if;
	    else
	        :new.pret_final := p;
	    end if;
	    
	end;
END; 
/

CREATE OR REPLACE TRIGGER trg_Vanzare_data 
    BEFORE INSERT OR UPDATE ON Vanzare 
    FOR EACH ROW 
BEGIN
	IF(:new.data > SYSDATE)
	THEN
		RAISE_APPLICATION_ERROR(-20950, 'Data bonului e incorecta!');
	END IF;
END; 
/

CREATE SEQUENCE angajat_angajat_id_seq START WITH 20 MINVALUE 20 MAXVALUE 30 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER angajat_angajat_id_trg BEFORE
    INSERT ON angajat
    FOR EACH ROW
    WHEN ( new.angajat_id IS NULL )
BEGIN
    :new.angajat_id := angajat_angajat_id_seq.nextval;
END;
/

CREATE SEQUENCE client_client_id_seq START WITH 10 MINVALUE 10 MAXVALUE 20 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER client_client_id_trg BEFORE
    INSERT ON client
    FOR EACH ROW
    WHEN ( new.client_id IS NULL )
BEGIN
    :new.client_id := client_client_id_seq.nextval;
END;
/

CREATE SEQUENCE furnizori_furnizor_id_seq START WITH 100 INCREMENT BY 10 MINVALUE 100 MAXVALUE 200 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER furnizori_furnizor_id_trg BEFORE
    INSERT ON furnizori
    FOR EACH ROW
    WHEN ( new.furnizor_id IS NULL )
BEGIN
    :new.furnizor_id := furnizori_furnizor_id_seq.nextval;
END;
/

CREATE SEQUENCE librarie_librarie_id_seq START WITH 100 INCREMENT BY 20 MINVALUE 100 MAXVALUE 200 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER librarie_librarie_id_trg BEFORE
    INSERT ON librarie
    FOR EACH ROW
    WHEN ( new.librarie_id IS NULL )
BEGIN
    :new.librarie_id := librarie_librarie_id_seq.nextval;
END;
/

CREATE SEQUENCE produse_produs_id_seq START WITH 100 INCREMENT BY 15 MINVALUE 100 MAXVALUE 250 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER produse_produs_id_trg BEFORE
    INSERT ON produse
    FOR EACH ROW
    WHEN ( new.produs_id IS NULL )
BEGIN
    :new.produs_id := produse_produs_id_seq.nextval;
END;
/

CREATE SEQUENCE vanzare_nr_bon_seq START WITH 100 INCREMENT BY 15 MINVALUE 100 MAXVALUE 250 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER vanzare_nr_bon_trg BEFORE
    INSERT ON vanzare
    FOR EACH ROW
    WHEN ( new.nr_bon IS NULL )
BEGIN
    :new.nr_bon := vanzare_nr_bon_seq.nextval;
END;
/
