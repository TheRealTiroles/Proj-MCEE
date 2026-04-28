% 1. Configuração inicial da cena
fig = figure('KeyPressFcn', @(src, event) disp(['Tecla: ', event.Key]));
ax = axes('XLim', [0 5], 'YLim', [0 5], 'ZLim', [0 10], 'XTick', 0:5, 'YTick', 0:5, 'ZTick', 0:10);
view(3);
grid on;
hold on;
axis equal;

% 2. Criar o "bloco" 3D (Cubo)
% Definimos a origem do bloco [x, y, z]
pos = [0 0 0]; 
lado = 1;

% Criamos o bloco usando a função 'patch' para ter faces sólidas
vertices = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1] * lado;
faces = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
bloco = patch('Vertices', vertices + pos, 'Faces', faces, 'FaceColor', 'red', 'EdgeColor', 'black');

disp('Use as Setas para X/Y e "w/s" para subir/descer (Z). "q" para sair.');

% 3. Loop de atualização
executando = true;
while executando
    tecla = get(fig, 'CurrentKey');
    
    % Lógica de movimento nos 3 eixos
    switch tecla
        case 'uparrow'    % Move para frente (Y)
            pos(2) = pos(2) + 1;
        case 'downarrow'  % Move para trás (Y)
            pos(2) = pos(2) - 1;
        case 'leftarrow'  % Move para esquerda (X)
            pos(1) = pos(1) - 1;
        case 'rightarrow' % Move para direita (X)
            pos(1) = pos(1) + 1;
        case 'w'          % Sobe (Z)
            pos(3) = pos(3) + 1;
        case 's'          % Desce (Z)
            pos(3) = pos(3) - 1;
        case 'q'          % Sair
            executando = false;
    end
    
    % Atualiza a posição dos vértices do bloco
    set(bloco, 'Vertices', vertices + pos);
    
    % Limpa a tecla para evitar movimento contínuo indesejado
    set(fig, 'CurrentKey', '');
    
    % Renderiza a mudança
    drawnow;
    pause(0.02);
end

close(fig);


