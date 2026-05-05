classdef Blocos
    %BLOCOS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pos;
        color;
        ori;
        type;
        len;
    end
    
    methods
        function obj = Blocos(p)
            %BLOCOS Construct an instance of this class
            %   Detailed explanation goes here
            obj.type = randi(2);
            obj.ori = zeros(1, 2);
            switch obj.type
                case 1
                    obj.color = [0 0 1];
                    obj.len = 1;
                case 2
                    obj.color = [1 0 0];
                    obj.len = 2;
                    obj.ori(randi(2)) = randi([0 1]) * 2 - 1;
            end

            if any(obj.ori)
                if obj.pos(1) + obj.ori(1) > 5 || obj.pos(1) + obj.ori(1) < 1 || ...
                   obj.pos(2) + obj.ori(2) > 5 || obj.pos(2) + obj.ori(2) < 1
                    obj.ori = -obj.ori;
                end
            end
            
            obj.pos = [p(1) + obj.ori(1), p(2) + obj.ori(2), p(3)];


        end
        
        function move(obj, passo, coord, n)
            if obj
            
        end
    end
end

