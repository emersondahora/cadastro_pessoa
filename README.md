# Instruções de instalação do Script

Os scripts encontram-se na pasta "01 - script" devem usar o prompt oracle, ou ferramenta similar, e para execução dos códigos e devem ser executados na seguinte ordem:
* 01 - script_DDL.sql
* 02 - script_dominio.sql

# Blocos anônimos

Na pasta "02 - blocos anonimos" encontram-se os blocos montados para utilizar as funções do projeto:
* **01 - Cadastrar pessoa.sql** - Cadastro e Edição da Pessoa
* **02 - Calcular Idade.sql** - Função para calcular o dado da pessoa
* **03 - aumentar_salario.sql** - Função para aumentar o salário
* **04 - view_pessoa.sql** - Utilização da VIEW __vw_pessoa__
 
# Testes
Na pasta "03 - testes" encontram-se testes realizados utilizando a ferramenta PL/SQL
* **01 - Cadastrar pessoa.sql** - Cadastro e Edição da Pessoa
* **02 - Calcular Idade.sql** - Função para calcular o dado da pessoa
* **03 - aumentar_salario.sql** - Função para aumentar o salário

# Script separado
Na pasta "04 - script separado" constam os script DDL separado por elemento, para facilitar na visualização dos objeto criado.

* **tab_estado_civil.tab** - Tabela de domínio de Estado Civil
* **tab_pessoa.tab** - Tabela principal de Pessoa
* **tab_pessoa_telefone.tab** - Tabela com os telefones da pessoa
* **seq_pessoa.seq** - Sequence para PK da tabela tab_pessoa
* **pkg_base.spc** - Packge Spect Base - Com a declaração das funções gerais
* **pkg_base.bdy** - Packge Body Base - Com a implementação das funções gerais
* **pkg_pessoa.spc** - Packge Spect Pessoa - Com a declaração das funções específicas de pessoas
* **pkg_pessoa.bdy** - Packge Body Pessoa - Com a implementação das funções específicas de pessoas
* **trgincpessoa.trg** - Trigger responsável por gerar o autoincrement da prk_pessoa
* **vw_pessoa.vw** - View do desafio
