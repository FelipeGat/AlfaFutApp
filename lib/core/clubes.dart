/// Lista dos 20 clubes ficticios. Mesma lista do backend (config/clubes.php).
/// Os SVGs sao servidos pelo Laravel em /images/brasoes/*.svg
class Clube {
  const Clube({required this.codigo, required this.nome, required this.brasao, required this.cor});
  final String codigo;
  final String nome;
  final String brasao; // path relativo: images/brasoes/01-...svg
  final String cor;
}

const kClubes = <Clube>[
  Clube(codigo: 'aguia-dourada', nome: 'Aguia Dourada FC', brasao: 'images/brasoes/01-aguia-dourada.svg', cor: 'dourado'),
  Clube(codigo: 'leoes-da-vila', nome: 'Leoes da Vila', brasao: 'images/brasoes/02-leoes-da-vila.svg', cor: 'vermelho'),
  Clube(codigo: 'raios-do-norte', nome: 'Raios do Norte', brasao: 'images/brasoes/03-raios-do-norte.svg', cor: 'azul'),
  Clube(codigo: 'tigres-fc', nome: 'Tigres FC', brasao: 'images/brasoes/04-tigres-fc.svg', cor: 'laranja'),
  Clube(codigo: 'coroa-real', nome: 'Coroa Real', brasao: 'images/brasoes/05-coroa-real.svg', cor: 'roxo'),
  Clube(codigo: 'estrela-solitaria', nome: 'Estrela Solitaria', brasao: 'images/brasoes/06-estrela-solitaria.svg', cor: 'azul-escuro'),
  Clube(codigo: 'trovao-fc', nome: 'Trovao FC', brasao: 'images/brasoes/07-trovao-fc.svg', cor: 'cinza'),
  Clube(codigo: 'falcoes-negros', nome: 'Falcoes Negros', brasao: 'images/brasoes/08-falcoes-negros.svg', cor: 'preto'),
  Clube(codigo: 'lobos-brancos', nome: 'Lobos Brancos', brasao: 'images/brasoes/09-lobos-brancos.svg', cor: 'branco'),
  Clube(codigo: 'dragoes-vermelhos', nome: 'Dragoes Vermelhos', brasao: 'images/brasoes/10-dragoes-vermelhos.svg', cor: 'vermelho-escuro'),
  Clube(codigo: 'oncas-do-sul', nome: 'Oncas do Sul', brasao: 'images/brasoes/11-oncas-do-sul.svg', cor: 'verde'),
  Clube(codigo: 'vingadores-fc', nome: 'Vingadores FC', brasao: 'images/brasoes/12-vingadores-fc.svg', cor: 'azul-marinho'),
  Clube(codigo: 'corais-marinhos', nome: 'Corais Marinhos', brasao: 'images/brasoes/13-corais-marinhos.svg', cor: 'turquesa'),
  Clube(codigo: 'tubaroes-praia', nome: 'Tubaroes da Praia', brasao: 'images/brasoes/14-tubaroes-praia.svg', cor: 'azul-claro'),
  Clube(codigo: 'ursos-do-vale', nome: 'Ursos do Vale', brasao: 'images/brasoes/15-ursos-do-vale.svg', cor: 'marrom'),
  Clube(codigo: 'touros-bravos', nome: 'Touros Bravos', brasao: 'images/brasoes/16-touros-bravos.svg', cor: 'bordo'),
  Clube(codigo: 'esquadrao-aco', nome: 'Esquadrao de Aco', brasao: 'images/brasoes/17-esquadrao-aco.svg', cor: 'metalico'),
  Clube(codigo: 'fenix-fc', nome: 'Fenix FC', brasao: 'images/brasoes/18-fenix-fc.svg', cor: 'laranja-fogo'),
  Clube(codigo: 'cavaleiros', nome: 'Cavaleiros do Campo', brasao: 'images/brasoes/19-cavaleiros.svg', cor: 'prata'),
  Clube(codigo: 'panteras-negras', nome: 'Panteras Negras', brasao: 'images/brasoes/20-panteras-negras.svg', cor: 'rosa-pink'),
];
