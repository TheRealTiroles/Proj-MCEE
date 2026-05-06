clear classes; 
close all;
clc;

t_antigos = timerfind;
if ~isempty(t_antigos)
    stop(t_antigos);
    delete(t_antigos);
end

altura = 10;
largura = 5;

MeuTetris3D = Game(altura, largura);