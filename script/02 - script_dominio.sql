prompt PL/SQL Developer Export Tables for user UNBOX_TEST@XE
prompt Created by emers on terça-feira, 15 de setembro de 2020
set feedback off
set define off

prompt Loading TAB_ESTADO_CIVIL...
insert into TAB_ESTADO_CIVIL (prk_estado_civil, des_estado_civil)
values (1, 'Solteiro(a)');
insert into TAB_ESTADO_CIVIL (prk_estado_civil, des_estado_civil)
values (2, 'Casado(a)');
insert into TAB_ESTADO_CIVIL (prk_estado_civil, des_estado_civil)
values (3, 'Viúvo(a)');
insert into TAB_ESTADO_CIVIL (prk_estado_civil, des_estado_civil)
values (4, 'Separado(a) judicialmente');
insert into TAB_ESTADO_CIVIL (prk_estado_civil, des_estado_civil)
values (5, 'Divorciado(a)');
commit;
prompt 5 records loaded

set feedback on
set define on
prompt Done
