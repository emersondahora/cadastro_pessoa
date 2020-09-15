prompt PL/SQL Developer Export User Objects for user UNBOX_TEST@XE
prompt Created by emers on terÃ§a-feira, 15 de setembro de 2020
set define off
spool script_DDL.log

prompt
prompt Creating table TAB_ESTADO_CIVIL
prompt ===============================
prompt
create table TAB_ESTADO_CIVIL
(
  prk_estado_civil NUMBER not null,
  des_estado_civil VARCHAR2(200)
)
;
comment on table TAB_ESTADO_CIVIL
  is 'Tabela domínio de estados civis';
comment on column TAB_ESTADO_CIVIL.prk_estado_civil
  is 'Chave Primária do estado civil';
comment on column TAB_ESTADO_CIVIL.des_estado_civil
  is 'Descrição do estado civil';
alter table TAB_ESTADO_CIVIL
  add constraint PK_ESTADO_CIVIL primary key (PRK_ESTADO_CIVIL);

prompt
prompt Creating table TAB_PESSOA
prompt =========================
prompt
create table TAB_PESSOA
(
  prk_pessoa             NUMBER not null,
  tip_pessoa             VARCHAR2(2) not null,
  num_cpfcnpj            VARCHAR2(20) not null,
  des_nome_razaosoc      VARCHAR2(200) not null,
  dat_nascimento_criacao DATE not null,
  des_rg                 VARCHAR2(20),
  tip_sexo               VARCHAR2(2),
  num_salario            NUMBER(10,2),
  des_observacao         VARCHAR2(200),
  des_email              VARCHAR2(200) not null,
  frk_estado_civil       NUMBER
)
;
comment on table TAB_PESSOA
  is 'Tabela de armazenamento das Pessoas Fisica/Jurídica';
comment on column TAB_PESSOA.prk_pessoa
  is 'Chave primária da tabela de pessoa';
comment on column TAB_PESSOA.tip_pessoa
  is 'Tipo de Pessoa: F - Pessoa Física; J - Pessoa Jurídica';
comment on column TAB_PESSOA.num_cpfcnpj
  is 'CPF/CNPJ da pessoa';
comment on column TAB_PESSOA.des_nome_razaosoc
  is 'Nome ou Razao Social da pessoa';
comment on column TAB_PESSOA.dat_nascimento_criacao
  is 'Data de Nascimento da Pessoa Física ou Data de Criação da pessoa jurídica';
comment on column TAB_PESSOA.des_rg
  is 'RG';
comment on column TAB_PESSOA.tip_sexo
  is 'Sexo - M - Masculino; F - Feminino';
comment on column TAB_PESSOA.num_salario
  is 'Valor do salário da pessoa';
comment on column TAB_PESSOA.des_observacao
  is 'Observação da pessoa';
comment on column TAB_PESSOA.des_email
  is 'E-mail';
comment on column TAB_PESSOA.frk_estado_civil
  is 'Estado Civil (Ver tab_estado_civil)';
alter table TAB_PESSOA
  add constraint PK_PESSOA primary key (PRK_PESSOA);
alter table TAB_PESSOA
  add constraint UK_PESSOA unique (NUM_CPFCNPJ);
alter table TAB_PESSOA
  add constraint FK_PESSOA_ESTADO_CIVIL foreign key (FRK_ESTADO_CIVIL)
  references TAB_ESTADO_CIVIL (PRK_ESTADO_CIVIL);
alter table TAB_PESSOA
  add constraint CH_PESSOA_SEXO
  check (TIP_SEXO IN('M', 'F'));
alter table TAB_PESSOA
  add constraint CH_PESSOA_TIPO
  check (TIP_PESSOA IN('F', 'J'));

prompt
prompt Creating table TAB_PESSOA_TELEFONE
prompt ==================================
prompt
create table TAB_PESSOA_TELEFONE
(
  frk_pessoa   NUMBER,
  des_telefone VARCHAR2(20)
)
;
comment on table TAB_PESSOA_TELEFONE
  is 'Tabela de armazenamento dos telefones da pessoa';
comment on column TAB_PESSOA_TELEFONE.frk_pessoa
  is 'Chave Estrangeira da TAB_PESSOA';
comment on column TAB_PESSOA_TELEFONE.des_telefone
  is 'Telefone';
create index IDX_PESSOA_TELEFONE on TAB_PESSOA_TELEFONE (FRK_PESSOA);
alter table TAB_PESSOA_TELEFONE
  add constraint FK_PESSOA_TELEFONE foreign key (FRK_PESSOA)
  references TAB_PESSOA (PRK_PESSOA);

prompt
prompt Creating sequence SEQ_PESSOA
prompt ============================
prompt
create sequence SEQ_PESSOA
minvalue 1
maxvalue 9999999999999999999999999999
start with 41
increment by 1
cache 20;

prompt
prompt Creating package PKG_BASE
prompt =========================
prompt
create or replace package pkg_base is
  /**
   * Função para remover a mascara de dados numéricos 
	 * @param vValorMascarado: Valor a ser removida a máscara
	 * @return VARCHAR2
   **/
  FUNCTION fRemoverMascaraNumerico(vValorMascarado VARCHAR2) RETURN VARCHAR2;
	
  /**
	 * Função para formatar um CPF/CNPJ informado
	 * @param vCPFCNPJ: CPF/CNPJ para ser formatado
	 * @return VARCHAR2 com o CPF/CNPJ formatado
	 **/  
  FUNCTION fFormatarCPFCNPJ(vCPFCNPJ VARCHAR2) RETURN VARCHAR2;
	
  /** 
	 * Função para formatar números de telefone
	 * @param vTelefone: Número do telefone
	 * @return VARCHAR2 com telefone formatado
	 **/  
  FUNCTION fFormatarTelefone(vTelefone VARCHAR2) RETURN VARCHAR2;

  /**
	 * Função para calcular a idade entre uma data informada e a data atual
	 * @param vData: Data a ser calculada
	 * @return NUMBER contendo a idade calculada 
	 **/
  FUNCTION fCalcularIdade(vData DATE) RETURN NUMBER;


end pkg_base;
/

prompt
prompt Creating view VW_PESSOA
prompt =======================
prompt
CREATE OR REPLACE FORCE VIEW VW_PESSOA AS
SELECT INITCAP(pes.des_nome_razaosoc) des_nome
     , pkg_base.fFormatarCPFCNPJ(pes.num_cpfcnpj) num_cpfcnpj
     , pkg_base.fCalcularIdade(pes.dat_nascimento_criacao) idade
     , TRIM(TO_CHAR(pes.num_salario * 12, 'L999G999G999G999D99MI')) as num_salario_anual
     , des_telefones
  FROM tab_pessoa pes
  LEFT JOIN (SELECT frk_pessoa
                  , LISTAGG(pkg_base.fFormatarTelefone(des_telefone), ', ' )
                     WITHIN GROUP( ORDER BY des_telefone )  des_telefones
               FROM tab_pessoa_telefone
              GROUP BY frk_pessoa)
         ON prk_pessoa = frk_pessoa;

prompt
prompt Creating package PKG_PESSOA
prompt ===========================
prompt
CREATE OR REPLACE PACKAGE pkg_pessoa IS
  /**
	 * VARIÁVEL DE EXEPTION DEFINIDA PELO USUÁRIO
	**/
  EXCEPT_USER EXCEPTION;
  
	/**
	 * Record padrão de retorno
	 *   num_retorno: número indicando Sucesso (1) ou Falha (0) da operação;
	 *   des_retorno: Mensagem de falha, ou definida pelo usuário, ou SQLERRM da falha;
	 **/
  TYPE recRetorno IS RECORD (
       num_retorno NUMBER, --// 1 - Sucesso; 0 - Erro;
       des_retorno VARCHAR2(200) --// Mensagem em caso de falha
  );
  
	/**
	 * TYPE de lista de telefones 
	 **/
  TYPE tTelefone IS TABLE OF tab_pessoa_telefone.des_telefone%TYPE;

  /**
	 * Função para cadastrar ou editar uma pessoa
	 * @param rPessoaIn: RECORD com as informações da pessoa (VER tab_pessoa)
	 * @param lTelefone: Lista de telefones da pessoa
	 * @return recRetorno
	 **/
  FUNCTION fCadastrarEditarPessoa(rPessoaIn tab_pessoa%ROWTYPE
                                , lTelefone tTelefone) RETURN recRetorno;

 
	/**
	 * Função para retornar a idade de uma pessoa cadastrada, buscando pelo CPF/CNPJ
	 * @param vCpfCnpj: CPF/CNPJ da pessoa cadastrdada
	 * @return NUMBER da idade da pessoa OU NULL quando a pessoa não for encontrada
	 **/
  FUNCTION fCalcularIdadePessoa(vCpfCnpj tab_pessoa.num_cpfcnpj%TYPE) RETURN NUMBER;
  
	/**
	 * Função para aumentar o salário através de um porcentagem informada
	 *   Se o vCpfCnpjIn for informado, o sistema irá aumentar o salário de uma pessoa específica
	 *     Caso contrário irá aumentar o salário de todas as pessoas da base;
	 * @param nPorcentagemAumento: Valor da porcentagem a ser aumentada;
	 * @param vCpfCnpjIn: CPF/CNPJ da pessoa
	 **/
  FUNCTION fAumentarSalario(nPorcentagemAumento NUMBER
                          , vCpfCnpjIn tab_pessoa.num_cpfcnpj%TYPE DEFAULT NULL) RETURN recRetorno;

END pkg_pessoa;
/

prompt
prompt Creating package body PKG_BASE
prompt ==============================
prompt
create or replace package body pkg_base is


  /**
   * Função para remover a mascara de dados numéricos 
   * @param vValorMascarado: Valor a ser removida a máscara
	 * @return VARCHAR2
   **/
  FUNCTION fRemoverMascaraNumerico(vValorMascarado VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REGEXP_REPLACE(vValorMascarado, '[^0-9]', '');
  END fRemoverMascaraNumerico;
  
  /**
	 * Função para formatar um CPF/CNPJ informado
	 * @param vCPFCNPJ: CPF/CNPJ para ser formatado
	 * @return VARCHAR2 com o CPF/CNPJ formatado
	 **/  
  FUNCTION fFormatarCPFCNPJ(vCPFCNPJ VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE 
      WHEN LENGTH(vCPFCNPJ) = 11 
        THEN REGEXP_REPLACE(vCPFCNPJ,
                           '([[:digit:]]{3})([[:digit:]]{3})([[:digit:]]{3})([[:digit:]]{2})',
                           '\1.\2.\3-\4') 
      WHEN LENGTH(vCPFCNPJ)  = 14 
        THEN REGEXP_REPLACE(vCPFCNPJ,
                            '([[:digit:]]{2})([[:digit:]]{3})([[:digit:]]{3})([[:digit:]]{4})([[:digit:]]{2})',
                            '\1.\2.\3/\4-\5') 
        ELSE vCPFCNPJ
      END;
  END fFormatarCPFCNPJ;
  
  /** 
	 * Função para formatar números de telefone
	 * @param vTelefone: Número do telefone
	 * @return VARCHAR2 com telefone formatado
	 **/  
  FUNCTION fFormatarTelefone(vTelefone varchar2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE 
      WHEN LENGTH(vTelefone) = 11 
        THEN REGEXP_REPLACE(vTelefone,
                           '([[:digit:]]{2})([[:digit:]]{1})([[:digit:]]{4})([[:digit:]]{4})',
                           '(\1) \2 \3-\4') 
      WHEN LENGTH(vTelefone)  = 10 
        THEN REGEXP_REPLACE(vTelefone,
                            '([[:digit:]]{2})([[:digit:]]{4})([[:digit:]]{4})',
                            '(\1) \2-\3') 
        ELSE vTelefone
      END;
  END fFormatarTelefone;

  /**
	 * Função para calcular a idade entre uma data informada e a data atual
	 * @param vData: Data a ser calculada
	 * @return NUMBER contendo a idade calculada 
	 **/
  FUNCTION fCalcularIdade(vData DATE) 
    RETURN NUMBER IS
  BEGIN
    RETURN trunc((months_between(sysdate, vData))/12);
  END fCalcularIdade;

end pkg_base;
/

prompt
prompt Creating package body PKG_PESSOA
prompt ================================
prompt
CREATE OR REPLACE PACKAGE BODY pkg_pessoa IS

  /**
	 * Função para buscar a PK da pessoa cadastrada através do CPF/CNPJ
	 * @param vCPFCNPJ: CPF/CNPJ da pessoa
	 * @return tab_pessoa.prk_pessoa%TYPE contendo a chave da pessoa quando encontrado ou NULL quando não encontrado
	 **/
  FUNCTION fBuscarPessoa(vCPFCNPJ tab_pessoa.num_cpfcnpj%TYPE) return tab_pessoa.prk_pessoa%TYPE is
    prkPessoa tab_pessoa.prk_pessoa%TYPE;
  BEGIN
    SELECT prk_pessoa
      INTO prkPessoa
      FROM tab_pessoa
     WHERE num_cpfcnpj = vCPFCNPJ;
     return prkPessoa;
  EXCEPTION
    WHEN OTHERS THEN
      return null;
  END fBuscarPessoa;

  /**
	 * Função para cadastrar ou editar uma pessoa
	 * @param rPessoaIn: RECORD com as informações da pessoa (VER tab_pessoa)
	 * @param lTelefone: Lista de telefones da pessoa
	 * @return recRetorno
	 **/
  FUNCTION fCadastrarEditarPessoa(rPessoaIn tab_pessoa%ROWTYPE
                                , lTelefone tTelefone) return recRetorno is
    rRetorno recRetorno;
    rPessoa tab_pessoa%ROWTYPE:= rPessoaIn;
    vTelefone tab_pessoa_telefone.des_telefone%TYPE;
  BEGIN
    rPessoa.Num_Cpfcnpj := pkg_base.fRemoverMascaraNumerico(rPessoa.Num_Cpfcnpj);
    
		--// Validações de dados
    IF NVL(rPessoa.tip_pessoa, 'N') NOT IN('F','J') THEN
      rRetorno.des_retorno := 'Tipo de pessoa inválido';
      RAISE EXCEPT_USER;
    ELSIF LENGTH(rPessoa.Num_Cpfcnpj) NOT IN(11,14) THEN
      rRetorno.des_retorno := 'CPF/CNPJ inválido';
      RAISE EXCEPT_USER;
    ELSIF rPessoa.Des_Nome_Razaosoc IS NULL THEN
      rRetorno.des_retorno := 'Informe o nome/razão social';
      RAISE EXCEPT_USER;
    ELSIF rPessoa.Dat_Nascimento_Criacao IS NULL THEN
      rRetorno.des_retorno := 'Informe a data de nacimento/data de criação da empresa';
      RAISE EXCEPT_USER;
    ELSIF INSTR(rPessoa.Des_Email, '@') = 0 THEN
      rRetorno.des_retorno := 'E-mail inválido';
      RAISE EXCEPT_USER;
    END IF;
    
		--// Busca a PK da pessoa
    rPessoa.prk_pessoa := fBuscarPessoa(rPessoa.num_cpfcnpj);
    
		--// Caso não encontre a PK realiza o insert da pessoa na base
    IF rPessoa.prk_pessoa IS NULL THEN 
      INSERT INTO tab_pessoa (tip_pessoa, num_cpfcnpj, des_nome_razaosoc, dat_nascimento_criacao, des_rg, tip_sexo, num_salario, des_observacao, frk_estado_civil, des_email)
           values (rPessoa.tip_pessoa, rPessoa.num_cpfcnpj, rPessoa.des_nome_razaosoc, rPessoa.dat_nascimento_criacao, rPessoa.des_rg, rPessoa.tip_sexo, rPessoa.num_salario, rPessoa.des_observacao, rPessoa.frk_estado_civil, rPessoa.des_email)
        returning prk_pessoa into rPessoa.prk_pessoa;
		--// Caso encontre a PK realiza o update da pessoa na base
    ELSE
      UPDATE tab_pessoa 
         SET tip_pessoa = rPessoa.tip_pessoa
           , num_cpfcnpj = rPessoa.num_cpfcnpj
           , des_nome_razaosoc = rPessoa.des_nome_razaosoc
           , dat_nascimento_criacao = rPessoa.dat_nascimento_criacao
           , des_rg = rPessoa.des_rg
           , tip_sexo = rPessoa.tip_sexo
           , num_salario = rPessoa.num_salario
           , des_observacao = rPessoa.des_observacao
           , frk_estado_civil = rPessoa.frk_estado_civil
           , des_email = rPessoa.des_email
       WHERE prk_pessoa = rPessoa.prk_pessoa;
			 
			--// Limpa os telefones da pessoa
      DELETE FROM tab_pessoa_telefone
        WHERE frk_pessoa = rPessoa.prk_pessoa;
    END IF;
    
		--// Insere os telefones de contado da pessoa
    IF lTelefone.COUNT > 0 THEN
      FOR nIndex IN 1..lTelefone.COUNT
      LOOP
        vTelefone := pkg_base.fRemoverMascaraNumerico(lTelefone(nIndex));
        IF vTelefone IS NULL THEN
         rRetorno.des_retorno := 'Telefone inválido';
         RAISE EXCEPT_USER;
        END IF;
        INSERT INTO tab_pessoa_telefone ( frk_pessoa, des_telefone)
          VALUES(rPessoa.Prk_Pessoa, vTelefone);
      END LOOP;
    END IF;
    rRetorno.num_retorno := 1;
    COMMIT;
    return rRetorno;
  EXCEPTION
     WHEN EXCEPT_USER THEN
        ROLLBACK;
        rRetorno.num_retorno := 0;
        return rRetorno;
     WHEN OTHERS THEN
        ROLLBACK;
        rRetorno.num_retorno := 0;
        rRetorno.des_retorno := SQLERRM;
        return rRetorno;
  END fCadastrarEditarPessoa;
    
	/**
	 * Função para retornar a idade de uma pessoa cadastrada, buscando pelo CPF/CNPJ
	 * @param vCpfCnpj: CPF/CNPJ da pessoa cadastrdada
	 * @return NUMBER da idade da pessoa OU NULL quando a pessoa não for encontrada
	 **/
  FUNCTION fCalcularIdadePessoa(vCpfCnpj tab_pessoa.num_cpfcnpj%TYPE) 
    RETURN NUMBER IS
    nIdade NUMBER;
  BEGIN
    SELECT pkg_base.fCalcularIdade(pes.dat_nascimento_criacao)
      INTO nIdade
      FROM tab_pessoa pes
     WHERE num_cpfcnpj = pkg_base.fRemoverMascaraNumerico(vCpfCnpj);
    RETURN nIdade;
  EXCEPTION 
    WHEN OTHERS THEN
      RETURN NULL;
  END fCalcularIdadePessoa;
   
	/**
	 * Função para aumentar o salário através de um porcentagem informada
	 *   Se o vCpfCnpjIn for informado, o sistema irá aumentar o salário de uma pessoa específica
	 *     Caso contrário irá aumentar o salário de todas as pessoas da base;
	 * @param nPorcentagemAumento: Valor da porcentagem a ser aumentada;
	 * @param vCpfCnpjIn: CPF/CNPJ da pessoa
	 **/
  FUNCTION fAumentarSalario(nPorcentagemAumento NUMBER
                          , vCpfCnpjIn tab_pessoa.num_cpfcnpj%TYPE DEFAULT NULL) RETURN recRetorno IS
    vNumCpfCnpj tab_pessoa.num_cpfcnpj%TYPE:= pkg_base.fRemoverMascaraNumerico(vCpfCnpjIn);
    rRetorno recRetorno;
  BEGIN
    IF nPorcentagemAumento IS NULL THEN
      rRetorno.des_retorno := 'Porcentagem de aumento inválido';
      RAISE EXCEPT_USER;
    END IF;
    
    UPDATE tab_pessoa pes
       SET pes.num_salario = num_salario * (1+nPorcentagemAumento/100)
     WHERE num_cpfcnpj = NVL(vNumCpfCnpj, num_cpfcnpj);
     
		--// Verifica se não houve alteração de salário e se o CPF/CNPJ foi informado, 
		--//   indicando que o CPF/CNPJ não existe na base
    IF SQL%rowcount = 0 AND vNumCpfCnpj IS NOT NULL THEN
      rRetorno.des_retorno := 'Pessoa não encontrada';
      RAISE EXCEPT_USER;
    END IF;
    
    COMMIT;
    rRetorno.num_retorno := 1;
    RETURN rRetorno;
  EXCEPTION
     WHEN EXCEPT_USER THEN
        ROLLBACK;
        rRetorno.num_retorno := 0;
        return rRetorno;
     WHEN OTHERS THEN
       ROLLBACK;
       rRetorno.num_retorno:=0;
       rRetorno.des_retorno:= SQLERRM;
       RETURN rRetorno;
  END fAumentarSalario;
END pkg_pessoa;
/

prompt
prompt Creating trigger TRGINCPESSOA
prompt =============================
prompt
create or replace trigger trgIncPessoa
    before insert on tab_pessoa
  for each row
begin
  :new.prk_pessoa := seq_pessoa.nextval;
end;
/


prompt Done
spool off
set define on
