
--- select pt a vedea pretul final pe fiecare bon
select vanzare_nr_bon, sum(pret_final) from detalii_vanzare group by vanzare_nr_bon order by vanzare_nr_bon asc; 

--- selectare toti clientii care detin card de fideliatate
select * from client where card_fidelitate=1;

--- selectare toti clientii care au realizat cumparaturi pe 1 iunie
select * from client where nume_client in (select nume_client from client c join vanzare v on (v.client_id=c.client_id) where to_char(data, 'dd-mm')=to_char(to_date('01.06.2021', 'dd-mm-yyyy'), 'dd-mm'));


--- selectare pret cel mai mare al unei achizitii
select max(b.pret) as "Maxim" from (select vanzare_nr_bon as nr_bon, sum(pret_final) as pret from detalii_vanzare group by vanzare_nr_bon) b;

--- stergem din tabela client clientii al caror nume incepe cu M : mai intai stergem din tabelele vanzare si detalii_vanzare, intrucat tabela vanzare este copilul tabelei client iar tabela detalii_vanzare este copilul tabelei vanzare
delete from detalii_vanzare where vanzare_nr_bon in (select nr_bon from vanzare where client_id in (select client_id from client where nume_client like 'M%'));
delete from vanzare where client_id in (select client_id from client where nume_client like 'M%');
delete from client where nume_client like 'M%';
select * from client;

--- stergem bonul cu numarul 115
delete from detalii_vanzare where vanzare_nr_bon=115;
delete from vanzare where nr_bon=115;
select * from vanzare;
select * from detalii_vanzare;


---facem update in tabela furnizori la adresa de email a furnizorlui cu numele 'Pelikan'
update furnizori set email='pelikanNew@yahoo.com' where nume_furnizor='Pelikan';
select * from furnizori;


--- facem update la valoarea pretului unei foi la xerox, se scumpeste cu 10%
update produse set pret=pret+pret*0.1 where nume_produs='XEROX';
select * from produse;

--- selectam informatii angajatului cu numele 'Ana Maria'
select * from detalii_angajat d join angajat a on(a.angajat_id=d.angajat_id) where a.nume_angajat='Ana Maria';

--- facem update la adresa angajatului cu angajat_id 20
update detalii_angajat set adresa='Bld. General Dascalescu' where angajat_id=20;
select * from detalii_angajat;

--- selectam bonurile pe care se afla xerox
select * from vanzare where nr_bon in (select vanzare_nr_bon from detalii_vanzare where produse_produs_id = (select produs_id from produse where nume_produs='XEROX'));

--- in cazul in care furnizorul cu numele 'Pelikan' nu mai distribuie produse librariei, produsele trebuie eliminate incepand din tabela detalii_vanzare, apoi tabela produse, si in final
--- furnizorul este eliminat din tabela furnizori
delete from detalii_vanzare where produse_produs_id = (select produs_id from produse where furnizor_id=(select furnizor_id from furnizori where nume_furnizor='Pelikan'));
delete from vanzare where nr_bon=205;
delete from produse where furnizor_id=(select furnizor_id from furnizori where nume_furnizor='Pelikan'); 
delete from furnizori where nume_furnizor='Pelikan';

select * from furnizori;
select * from detalii_vanzare;
select * from produse;


--- alegem cumparatorul cu varsta cea mai mare
select (to_char(sysdate, 'YYYY') - case when max(substr(cnp_client, 2, 2)) > 21 then 19||''||max(substr(cnp_client, 2, 2)) else 20||''||max(substr(cnp_client, 2, 2)) end)||' ani' as "Cel mai in varsta client" from client;

--- selectare pret maxim de pe fiecare bon
select vanzare_nr_bon, max(pret_final) as "Produs cel mai scump" from detalii_vanzare group by vanzare_nr_bon;

--- care este cel mai ieftin produs din magazin, in afara de xerox
select * from produse where pret = (select min(pret) from produse where nume_produs<>'XEROX');

--- selectare vanzare realizata de angajat a carui varsta este 21 de ani
select * from vanzare 
    where angajat_id in (select angajat_id from detalii_angajat where to_char(sysdate, 'YYYY') - case when substr(cnp_angajat, 2, 2) > 21 then 19||''||substr(cnp_angajat, 2, 2) else 20||''||substr(cnp_angajat, 2, 2) end = 21);

--- adaugam in tabela vanzare suma totala pe fiecare bon
alter table vanzare add(pret_final varchar(30));
select * from vanzare;
update vanzare set pret_final=(select b.pret from (select vanzare_nr_bon, sum(pret_final) as pret from detalii_vanzare group by vanzare_nr_bon) b where b.vanzare_nr_bon=nr_bon);
select * from vanzare;

--- adaugare varsta angajat la tabela detalii_angajat
alter table detalii_angajat add(varsta number(2));
update detalii_angajat set varsta=(select to_char(sysdate, 'YYYY') - case when substr(b.cnp_angajat, 2, 2) > 21 then 19||''||substr(b.cnp_angajat, 2, 2) else 20||''||substr(b.cnp_angajat, 2, 2) end from (select angajat_id as ida, cnp_angajat from detalii_angajat) b where b.ida=angajat_id);
select * from detalii_angajat;



---- validari
update client set nume_client='Ana' where client_id=11;
update client set telefon='072345' where client_id=11;
update detalii_angajat set cnp_angajat='6190228270016' where angajat_id=20;
update client set cnp_client='6200630270016' where client_id=13;
update detalii_vanzare set cantitate_cumparata=20 where vanzare_nr_bon=115;
update produse set cantitate_disponibila=-2 where produs_id=100;
update angajat set nume_angajat='Maria' where angajat_id=21;