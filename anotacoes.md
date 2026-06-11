# Anotações

O mais importante ao se trabalhar com o Laia é não perder a cabeça.

Objetivo do trabalho: Fazer um robo que passe a primeira fase do jogo Arkanoid.

Passos para isso:

- Rodar o jogo - Ok
- Fazer o robo iniciar a partida apertando start - Ok
- Identificar a bolinha - Ok
- Identificar a plataforma
- Identificar blocos
- Opcionalmente Identificar outros elementos
- Fazer o robo movimentar a plataforma
- Calcular a tragetória da bolinha
- Fazer o robo movimentar a plataforma para interceptar a bolinha
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
