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

