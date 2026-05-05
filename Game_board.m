classdef Game_board < handle
    %GAME_BOARD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        map;
        len;
        hei;
    end
    
    methods
        function tab = Game_board(n, h)
            %GAME_BOARD Construct an instance of this class
            %   Detailed explanation goes here
            tab.len = n;
            tab.hei = h;
            tab.map = zeros(n, n, h);
        end
        
        function add_block(tab, x, y, z, type)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            tab.map(x, y, z) = type;
        end

        function h = get_height(tab, x, y)
            for i = tab.hei:-1:1
                if tab.map(x, y, i) ~= 0
                    break;
                end
            end
            h = i;
        end

        function value = check(tab, x, y, z)
            if tab.map(x(:), y(:), z(:)) ~= 0
                value = 1;
            else 
                value = 0;
            end
        end

        function t = color(tab, x, y, z)
            t = tab.map(x, y, z);
        end
    end
end

