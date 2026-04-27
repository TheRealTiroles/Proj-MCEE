classdef T_block < Objects
    properties
        mainNode;
        blockPositions = [
            0,  0, 0;  % Centro
           -1,  0, 0;  % Esquerda
            1,  0, 0;  % Direita
            0,  1, 0   % Cima
            ];
    end

    methods
        function obj = T_block(inputArg1,inputArg2)
            %T_BLOCK Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end