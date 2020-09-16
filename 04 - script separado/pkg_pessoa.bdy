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

