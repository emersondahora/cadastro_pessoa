CREATE OR REPLACE FORCE VIEW VW_PESSOA AS
SELECT INITCAP(pes.des_nome_razaosoc) des_nome
     , pkg_base.fFormatarCPFCNPJ(pes.num_cpfcnpj) num_cpfcnpj
     , pkg_base.fCalcularIdade(pes.dat_nascimento_criacao) idade
     , TRIM(TO_CHAR(pes.num_salario * 12, 'L999G999G999G999D99MI')) as num_salario_anual
     , des_telefones
  FROM tab_pessoa pes
  LEFT JOIN (SELECT frk_pessoa
                  , LISTAGG(pkg_base.fFormatarTelefone(des_telefone), ', ' )
                     WITHIN GROUP( ORDER BY des_telefone )  des_telefones
               FROM tab_pessoa_telefone
              GROUP BY frk_pessoa)
         ON prk_pessoa = frk_pessoa;

