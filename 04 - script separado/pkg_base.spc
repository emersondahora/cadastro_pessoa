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

