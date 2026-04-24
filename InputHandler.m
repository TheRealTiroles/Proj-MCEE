classdef InputHandler
    methods
        function ReadInputs(~, evento)
            pressed_Key = evento.Key;

            disp(["Tecla pressionada: " pressed_Key]);

        end
    end
end