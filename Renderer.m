classdef Renderer < handle
    properties
        window;
    end

    methods 
        function this = Renderer(handlerObj)
            this.window = figure('KeyPressFcn', @(~, evento) handlerObj.ReadInputs(evento));
        end
    end
    methods(Static)
        function drawFrame(game)
            
            
        end
    end
end