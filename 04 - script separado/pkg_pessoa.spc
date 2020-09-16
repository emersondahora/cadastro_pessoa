CREATE OR REPLACE PACKAGE pkg_pessoa IS
  /**
	 * VARI�VEL DE EXEPTION DEFINIDA PELO USU�RIO
	**/
  EXCEPT_USER EXCEPTION;
  
	/**
	 * Record padr�o de retorno
	 *   num_retorno: n�mero indicando Sucesso (1) ou Falha (0) da opera��o;
	 *   des_retorno: Mensagem de falha, ou definida pelo usu�rio, ou SQLERRM da falha;
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
	 * Fun��o para cadastrar ou editar uma pessoa
	 * @param rPessoaIn: RECORD com as informa��es da pessoa (VER tab_pessoa)
	 * @param lTelefone: Lista de telefones da pessoa
	 * @return recRetorno
	 **/
  FUNCTION fCadastrarEditarPessoa(rPessoaIn tab_pessoa%ROWTYPE
                                , lTelefone tTelefone) RETURN recRetorno;

 
	/**
	 * Fun��o para retornar a idade de uma pessoa cadastrada, buscando pelo CPF/CNPJ
	 * @param vCpfCnpj: CPF/CNPJ da pessoa cadastrdada
	 * @return NUMBER da idade da pessoa OU NULL quando a pessoa n�o for encontrada
	 **/
  FUNCTION fCalcularIdadePessoa(vCpfCnpj tab_pessoa.num_cpfcnpj%TYPE) RETURN NUMBER;
  
	/**
	 * Fun��o para aumentar o sal�rio atrav�s de um porcentagem informada
	 *   Se o vCpfCnpjIn for informado, o sistema ir� aumentar o sal�rio de uma pessoa espec�fica
	 *     Caso contr�rio ir� aumentar o sal�rio de todas as pessoas da base;
	 * @param nPorcentagemAumento: Valor da porcentagem a ser aumentada;
	 * @param vCpfCnpjIn: CPF/CNPJ da pessoa
	 **/
  FUNCTION fAumentarSalario(nPorcentagemAumento NUMBER
                          , vCpfCnpjIn tab_pessoa.num_cpfcnpj%TYPE DEFAULT NULL) RETURN recRetorno;

END pkg_pessoa;
/

