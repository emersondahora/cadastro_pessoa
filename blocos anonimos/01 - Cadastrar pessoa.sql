DECLARE
  rPessoa tab_pessoa%ROWTYPE;
  rRetorno pkg_pessoa.recRetorno;
BEGIN
  rPessoa.prk_pessoa := :prk_pessoa;
  rPessoa.tip_pessoa := :tip_pessoa;
  rPessoa.num_cpfcnpj := :num_cpfcnpj;
  rPessoa.des_nome_razaosoc := :des_nome_razaosoc;
  rPessoa.dat_nascimento_criacao := :dat_nascimento_criacao;
  rPessoa.des_rg := :des_rg;
  rPessoa.tip_sexo := :tip_sexo;
  rPessoa.num_salario := :num_salario;
  rPessoa.des_observacao := :des_observacao;
  rPessoa.frk_estado_civil := :frk_estado_civil;
  rPessoa.des_email := :des_email;

  rRetorno := pkg_pessoa.fCadastrarEditarPessoa(rPessoa, pkg_pessoa.tTelefone(:telefone1, :telefone2) );
  
  :cod_retorno := rRetorno.num_retorno;
  :des_retorno := rRetorno.des_retorno;
END;