create or replace package pkg_base is
  /**
   * Fun��o para remover a mascara de dados num�ricos 
	 * @param vValorMascarado: Valor a ser removida a m�scara
	 * @return VARCHAR2
   **/
  FUNCTION fRemoverMascaraNumerico(vValorMascarado VARCHAR2) RETURN VARCHAR2;
	
  /**
	 * Fun��o para formatar um CPF/CNPJ informado
	 * @param vCPFCNPJ: CPF/CNPJ para ser formatado
	 * @return VARCHAR2 com o CPF/CNPJ formatado
	 **/  
  FUNCTION fFormatarCPFCNPJ(vCPFCNPJ VARCHAR2) RETURN VARCHAR2;
	
  /** 
	 * Fun��o para formatar n�meros de telefone
	 * @param vTelefone: N�mero do telefone
	 * @return VARCHAR2 com telefone formatado
	 **/  
  FUNCTION fFormatarTelefone(vTelefone VARCHAR2) RETURN VARCHAR2;

  /**
	 * Fun��o para calcular a idade entre uma data informada e a data atual
	 * @param vData: Data a ser calculada
	 * @return NUMBER contendo a idade calculada 
	 **/
  FUNCTION fCalcularIdade(vData DATE) RETURN NUMBER;


end pkg_base;
/

