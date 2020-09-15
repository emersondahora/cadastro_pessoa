PL/SQL Developer Test script 3.0
8
DECLARE
  rResult pkg_pessoa.recRetorno;
BEGIN
  rResult := pkg_pessoa.fAumentarSalario(:nPorcentagemAumento, :vCpfCnpj);

  :num_retorno := rResult.num_retorno;
  :des_retorno := rResult.des_retorno;
END;
4
nPorcentagemAumento
1
10
4
vCpfCnpj
1
01751446131
5
num_retorno
1
1
5
des_retorno
0
5
0
