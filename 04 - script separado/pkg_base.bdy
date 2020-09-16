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

