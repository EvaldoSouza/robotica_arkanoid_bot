clear;
warning off;

pkg load retro_games;
pkg load image;

jogo = load_rom('roms/arkanoid.nes');
i = 0;

while i<18234500

    i++;
    jogo.step(5);
    if i == 5
        jogo.set_input(botao("START"));
        jogo.step(5);
    else
        jogo.set_input(botao());

    endif

    jogo.step(5);


    img = jogo.get_image();
    imshow(img);
    drawnow;
    pause(0.1);
endwhile
