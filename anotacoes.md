# Anotações

O mais importante ao se trabalhar com o Laia é não perder a cabeça.

Objetivo do trabalho: Fazer um robo que passe a primeira fase do jogo Arkanoid.

Passos para isso:

- Rodar o jogo - Ok
- Fazer o robo iniciar a partida apertando start - Ok
- Identificar a bolinha - Ok
- Identificar a plataforma - Ok
- Calcular a tragetória da bolinha
- Fazer o robo movimentar a plataforma
- Fazer o robo movimentar a plataforma para interceptar a bolinha
- Identificar blocos
- Opcionalmente Identificar outros elementos
- Fazer o robo mirar nos blocos restantes

Detalhes: A plataforma muda de cor e forma dependendo do power up.
Pode ser interessante criar uma heuristica para os power ups, mas é coisa pro final, apenas mantenha em mente

A porra do octave fica crashando com segfault. Provavelmente é um bug no meu código, mas não consegui achar ainda. Ou pode ser a estrutura de arquivos, que tá muito grande, desgraça
é muito sistemática, não sei se aguenta um projeto grande.

A area do paddle, com um brightness de 0.8:

Component 38:
  Area:         28
  BoundingBox:  [X: 95.5, Y: 210.5, W: 18.0, H: 6.0]
  Aspect Ratio: 3.00 (W/H)
  Centroid:     [X: 104.5, Y: 212.1]

Terminei de localizar o paddle, vamos gastar alguns minutos pensando na próxima parte.
A questão do movimento é interessante. Fazer o robo se movimentar é relativamente simples. Por outro lado, não tenho ideia de como fazer ele se movimentar em direção a bolinha.
Acho que vou no mais difícil primeiro. Mas para fazer o mais difícil é preciso que o robo se movimente.
É só input de botão. Ele precisa saber para onde se mover, isso é mais importante. Se ele sabe para onde tem que ir, vai ser trivial de mover ele para lá!
Identificar blocos fica para uma segunda parte, não é importante para o processo agora.
Certo, vamos calcular a trajetória da bolinha, ou algo assim.
Como posso fazer isso?
Minha primeira ideia é fazer a geometria da parada. Pega dois frames, calcula a reta da bolinha até ela acertar a parede, e então calcula o angule de reflexão, traçando outra linha
Quais outras opções que eu tenho?
Posso fazer uma estimativa de quadrante? O que é isso?
É simular como um humano joga. Ao invés de ter uma predição exata, faz uma estimativa de onde será melhor estar. A vantagem disso é poder levar em conta incertezas? Ou não?
Minha ideia para isso é traçar uma linha do paddle até a bolinha, e gerar a linha bolinha parede. A refração dela na parede gera um espaço onde o paddle deve estar, sem precisar...
Pera. Se eu traçar uma reta entre a bolinha e o chão, eu posso excluir tudo o que tiver na direção do movimento da bolinha?
Mas primeiro, eu tenho que saber a direção da bolinha!
Vamos pensar direito, vai. Quebra o problema em partes.
Primeiro, eu preciso saber a direção em que a bolinha está se movendo. A primeira forma que eu pensei de fazer isso é comparando dois frames, e traçando um vetor com a bolinha.
Segundo, eu preciso saber se ela bateu em algo. Como ainda não estou detectando objetos colidiveis, tem que ser baseado nos frames. Se em dois frames diferentes a bolinha não estiver em uma reta, ela bateu e quicou em algo. A interseção pode me dar onde ela bateu. Mas eu estou falando de frames, pode ser que a diferença seja pequena, ou mesmo que eu pegue o momento da colisão.Se o vetor de direção dela mudou, quer dizer que bateu. Se eu expandir os dois vetores, vão se cruzar, e eu tenho o ponto de colisão.
Terceiro, preciso definir se vai bater na parede. Pode ser que ela bata em algo antes, mas não é um problema agora, vamos por partes. Eu sei a posição das paredes. Extende o vetor até
cruzar com a parede.
Quarto, o rebote. Aqui eu não sei o que fazer. Eu sei que tem uma matemática para esses angulos de refração, mas não tenho idea de qual é. Porém não é difícil descobrir.
Certo, descobrindo. Se a parede for um espelho perfeito, chamasse "reflexão especular", e o angulo de entrada é exatamente o mesmo de saída! Ele só inverte o sentido do movimento!
