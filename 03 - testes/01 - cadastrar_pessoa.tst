PL/SQL Developer Test script 3.0
20
DECLARE
  rPessoa tab_pessoa%ROWTYPE;
  rRetorno pkg_pessoa.recRetorno;
BEGIN
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
14
tip_pessoa
1
F
5
num_cpfcnpj
1
03.948.198/0001-28
5
des_nome_razaosoc
1
Teste CNPJ
5
dat_nascimento_criacao
1
10/06/2005
5
des_rg
0
5
tip_sexo
0
5
num_salario
1
4000
5
des_observacao
1
Teste primário
5
cod_retorno
1
1
5
des_retorno
0
5
des_email
1
emersondahora@gmail.com
5
frk_estado_civil
1
1
5
telefone1
1
61999288886
5
telefone2
1
6133757932
5
0
