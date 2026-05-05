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

dados.colors = [0 0 1;
                1 0 0
                1 0 0];

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

dados.tab = Game_board(dados.n, dados.h);

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
    switch event.Key
        case 'uparrow'
            d.blocos.move(passo, 2, d.tab);
        case 'downarrow'
            d.blocos.move(-passo, 2, d.tab);
        case 'leftarrow'
            d.blocos.move(-passo, 1, d.tab);
        case 'rightarrow'
            d.blocos.move(passo, 1, d.tab);
        case 'escape'
            set(src, 'KeyPressFcn', '');
        case 'space'
            d.blocos = d.blocos.place(d.tab);
    end

    drawcube(src);

    set(src, 'UserData', d);


end

function atualizarTempo(fig_handle, t_obj)


end


function drawcube(fig_handle)
    d = get(fig_handle, 'UserData');
    ax = gca;
    cla(ax);
    
    for i = 1:d.n
        for j = 1:d.n
            for k = 1:d.h
                if d.tab.check(i, j, k)
                    for f = 1:6
                        patch(i + d.cell_x(f, :) - 1, j + d.cell_y(f, :) - 1, k + d.cell_z(f, :) - 1, d.colors(d.tab.color(i, j, k), :));
                    end
                end
            end
        end
    end

    for n = 1:d.blocos.len
        for f = 1:6
            patch(d.blocos.x(n) + d.cell_x(f, :) - 1, d.blocos.y(n) + d.cell_y(f, :) - 1, d.blocos.z(n) + d.cell_z(f, :) - 1, d.blocos.color);
        end
    end
    set(fig_handle, 'UserData', d);

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