DECLARE
  rResult pkg_pessoa.recRetorno;
BEGIN
  rResult := pkg_pessoa.fAumentarSalario(:nPorcentagemAumento, :vCpfCnpj);

  :num_retorno := rResult.num_retorno;
  :des_retorno := rResult.des_retorno;
END;