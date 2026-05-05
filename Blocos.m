classdef Blocos < handle
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
            
            obj.pos = p;

            if any(obj.ori)
                if obj.pos(1) + obj.ori(1) > 5 || obj.pos(1) + obj.ori(1) < 1 || ...
                   obj.pos(2) + obj.ori(2) > 5 || obj.pos(2) + obj.ori(2) < 1
                    obj.ori = -obj.ori;
                end
            end
            
        end
        
        function move(obj, passo, dir)
            if passo == obj.ori(dir)
                if obj.pos(dir) + obj.ori(dir) + passo <= 5 && obj.pos(dir) + obj.ori(dir) + passo > 0
                    obj.pos(dir) = obj.pos(dir) + passo;
                end
            else
                if obj.pos(dir) + passo <= 5 && obj.pos(dir) + passo > 0
                    obj.pos(dir) = obj.pos(dir) + passo;
                end
            end
        end

        function place(obj, h)
            obj.pos(3) = obj.pos(3) - h;
        end
    end
end

