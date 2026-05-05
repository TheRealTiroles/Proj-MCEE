
close all;

dados.n = 5;
dados.h = 10;

t_antigos = timerfind;
if ~isempty(t_antigos)
    stop(t_antigos);
    delete(t_antigos);
end
fig = figure('KeyPressFcn', @keyboardCallback);
xlim([0, dados.n]); xlabel('x'); xticks(0:dados.n);
ylim([0, dados.n]); ylabel('y'); yticks(0:dados.n);
zlim([0, dados.h]); zlabel('z'); zticks(0:dados.h);
grid on;
view(3);


pos_ini = [1, 1, dados.h];

dados.blocos = Blocos(pos_ini);

dados.cell_x = [0 0 0 0
           0 1 1 0
           0 0 1 1
           0 0 1 1
           0 1 1 0
           1 1 1 1];


dados.cell_y = [0 1 1 0
           0 0 0 0
           0 1 1 0
           0 1 1 0
           1 1 1 1
           0 1 1 0];

dados.cell_z = [0 0 1 1
           0 0 1 1
           0 0 0 0
           1 1 1 1
           0 0 1 1
           0 0 1 1];

dados.map = zeros(dados.n^2, 4);

set(fig, 'UserData', dados);

drawcube(fig);

t = timer('ExecutionMode', 'fixedRate', 'Period', 1);
t.TimerFcn = @(obj, event) atualizarTempo(fig, obj); 

% Importante: O delete do timer deve estar no fecho da figura
set(fig, 'DeleteFcn', @(~,~) stop_and_delete_safe(t));

start(t);

function keyboardCallback(src, event)
    d = get(src, 'UserData');
    passo = 1;
    num_bloco = size(d.blocos, 1)
    pos_bloco = d.blocos(num_bloco).pos(1) + d.n*(d.blocos(num_bloco).pos(2) - 1);
    dif = d.blocos(num_bloco).pos(3) - (d.map(pos_bloco, 4) + 1);
    switch event.Key
        case 'uparrow'
            d.blocos(num_bloco).move(passo, 2);
            disp('Ok2');
        case 'downarrow'
            d.blocos(num_bloco).move(-passo, 2);
        case 'leftarrow'
            d.blocos(num_bloco).move(-passo, 1);
        case 'rightarrow'
            d.blocos(num_bloco).move(passo, 1);
        case 'escape'
            set(src, 'KeyPressFcn', '');
        case 'space'
            d.blocos(num_bloco).place(dif);
    end

    drawcube(src);

    %{
    % Recupera os dados guardados na figura
    d = get(src, 'UserData');
    passo = 1;
    num_bloco = size(d.pos, 1);
    pos_bloco = d.pos(num_bloco, 1) + d.n*(d.pos(num_bloco, 2) - 1);
    dif = d.pos(num_bloco, 3) - (d.map(pos_bloco, 4) + 1);

    % Verifica qual tecla foi pressionada
    switch event.Key
        case 'uparrow',    if d.pos(num_bloco, 2)<d.n d.pos(num_bloco, 2) = d.pos(num_bloco, 2) + passo; end
        case 'downarrow',  if d.pos(num_bloco, 2)>1 d.pos(num_bloco, 2) = d.pos(num_bloco, 2) - passo; end
        case 'leftarrow',  if d.pos(num_bloco, 1)>1 d.pos(num_bloco, 1) = d.pos(num_bloco, 1) - passo; end
        case 'rightarrow', if d.pos(num_bloco, 1)<d.n d.pos(num_bloco, 1) = d.pos(num_bloco, 1) + passo; end
        case 'escape'
            set(src, 'KeyPressFcn', '');
        case 'space'
            d.pos(num_bloco, 3) = d.pos(num_bloco, 3)-dif;

    end
    
    if d.pos(num_bloco, 3) <= d.map(pos_bloco, 4) + 1
        d.map(pos_bloco, :) = d.map(pos_bloco, :) + 1;
        d.pos = [d.pos; d.pos(num_bloco, 1) d.pos(num_bloco, 2) d.h];
    end

    if all(d.map)
        [I, J] = find(d.pos(:, 3) > 1);
        d.pos = d.pos(I, :);
        d.pos(1:end-1, 3) = d.pos(1:end-1, 3) - 1;
        d.map = d.map - 1;
    end
    % Guarda os novos dados e redesenha
    set(src, 'UserData', d);
    drawcube(src);
    %}
end

function atualizarTempo(fig_handle, t_obj)
    %{
        if ishandle(fig_handle)
        d = get(fig_handle, 'UserData');
        num_bloco = size(d.pos, 1);
        pos_bloco = d.pos(num_bloco, 1) + d.n*(d.pos(num_bloco, 2) - 1);
        if d.pos(num_bloco, 3) <= d.map(pos_bloco, 4) + 1
            d.map(pos_bloco, :) = d.map(pos_bloco, :) + 1;
            d.pos = [d.pos; d.pos(num_bloco, 1) d.pos(num_bloco, 2) d.h];
        else
            d.pos(num_bloco, 3) = d.pos(num_bloco, 3) - 1;
        end

        if all(d.map)
            [I, J] = find(d.pos(:, 3) > 1);
            d.pos = d.pos(I, :);
            d.pos(1:end-1, 3) = d.pos(1:end-1, 3) - 1;
            d.map = d.map - 1;
        end

        if d.map(pos_bloco, 4) == 9
            stop_and_delete_safe(t_obj);
            set(fig_handle, 'KeyPressFcn', '');
            close(fig_handle);
        end
  
        set(fig_handle, 'UserData', d);
    end
    drawcube(fig_handle);
    %}

end


function drawcube(fig_handle)
    d = get(fig_handle, 'UserData');
    ax = gca;
    cla(ax);
    num_bloco = size(d.blocos, 1);
    pos_bloco = d.blocos(num_bloco).pos(1) + d.n*(d.blocos(num_bloco).pos(2) - 1);
    if d.blocos(num_bloco).pos(3) <= d.map(pos_bloco, 4) + 1
        d.blocos = [d.blocos; Blocos([d.blocos(num_bloco).pos(1:2), d.h])];
    end
    for i = 1:num_bloco
        t_bloco_aux_x = d.cell_x;
        t_bloco_aux_y = d.cell_y;
        I = find(t_bloco_aux_x == 1);
        t_bloco_aux_x(I) = t_bloco_aux_x(I) + d.blocos(i).ori(1);
        I = find(t_bloco_aux_y == 1);
        t_bloco_aux_y(I) = t_bloco_aux_y(I) + d.blocos(i).ori(2);
        for j = 1:6
            patch(d.blocos(i).pos(1) + t_bloco_aux_x(j, :) - 1, d.blocos(i).pos(2) + t_bloco_aux_y(j, :) - 1, ...
                d.blocos(i).pos(3) + d.cell_z(j, :) - 1, d.blocos(i).color);
        end
    end

    set(fig_handle, 'UserData', d);


    %{
    d = get(fig_handle, 'UserData');
    ax = gca;
    cla(ax); % Limpa o desenho anterior para não deixar rasto
    f = size(d.x, 1);
    num_bloco = size(d.pos, 1);
    for j = 1:num_bloco
        for i = 1:f
            patch(d.pos(j, 1) + d.x(i, :) - 1,d.pos(j, 2) + d.y(i, :) - 1,d.pos(j, 3) + d.z(i, :) - 1,[0 0 1]);
        end
    end
    pos_bloco = d.pos(num_bloco, 1) + d.n*(d.pos(num_bloco, 2)-1);
    patch(d.pos(num_bloco, 1) + d.x(3, :) - 1,d.pos(num_bloco, 2) + d.y(3, :) - 1, d.map(pos_bloco, :), [0 0 0]);
    %}
end

function stop_and_delete_safe(t_obj)
    try
        if isvalid(t_obj)
            stop(t_obj);
            delete(t_obj);
        end
    catch
    end
end
