create or replace trigger trgIncPessoa
    before insert on tab_pessoa
  for each row
begin
  :new.prk_pessoa := seq_pessoa.nextval;
end;
/

