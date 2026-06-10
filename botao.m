function input = botao(varargin)

    % vetor vazio:
    % [start select up down left right a b]
    input = zeros(1,8);

    for i = 1:length(varargin)

        nome = upper(varargin{i});

        switch nome

            case "START"
                input(1) = 1;

            case "SELECT"
                input(2) = 1;

            case "UP"
                input(3) = 1;

            case "DOWN"
                input(4) = 1;

            case "LEFT"
                input(5) = 1;

            case "RIGHT"
                input(6) = 1;

            case "A"
                input(7) = 1;

            case "B"
                input(8) = 1;

        endswitch

    endfor

endfunction
