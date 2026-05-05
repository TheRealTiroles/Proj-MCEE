classdef Blocos < handle
    %BLOCOS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x;
        y;
        z;
        color;
        type;
        len;
    end
    
    methods
        function obj = Blocos(p)
            %BLOCOS Construct an instance of this class
            %   Detailed explanation goes here
            obj.type = randi(4);
            switch obj.type
                case 1
                    obj.x = p(1);
                    obj.y = p(2);
                    obj.z = p(3);
                    obj.color = [0 0 1];
                    obj.len = 1;
                case 2
                    obj.y = [p(2); p(2)];
                    obj.z = [p(3); p(3)];
                    if p(1) + 1 > 5
                        obj.x = [p(1); p(1) - 1];
                    else
                        obj.x = [p(1); p(1) + 1];
                    end
                    obj.color = [1 0 0];
                    obj.len = 2;
                case 3
                    obj.x = [p(1); p(1)];
                    obj.z = [p(3); p(3)];
                    if p(2) + 1 > 5
                        obj.y = [p(2); p(2) - 1];
                    else
                        obj.y = [p(2); p(2) + 1];
                    end
                    obj.color = [1 0 0];
                    obj.len = 2;
                case 4
                    obj.x = [p(1); p(1)];
                    obj.y = [p(2); p(2)];
                    obj.z = [p(3); p(3) + 1];
                    obj.color = [0 1 0];
                    obj.len = 2;
            end  
        end
        
        function move(obj, passo, dir, tab)
            switch dir
                case 1
                    if (obj.x + passo > 0 & obj.x + passo < 6)
                        disp(~tab.check(obj.x(:) + passo, obj.y(:), obj.z(:)));
                        if ~tab.check(obj.x(:) + passo, obj.y(:), obj.z(:))
                            obj.x = obj.x + passo;
                        end
                    end
                case 2
                    if (obj.y + passo > 0 & obj.y + passo < 6) 
                        disp(~tab.check(obj.x, obj.y + passo, obj.z));
                        if ~tab.check(obj.x, obj.y + passo, obj.z)
                            obj.y = obj.y + passo;
                        end
                    end
            end
        end

        function new_obj = place(obj, tab)
            dif_h = obj.z(1) - tab.get_height(obj.x, obj.y);
            obj.z = obj.z - dif_h;
            new_obj = obj.add_to_map(tab);
        end

        function new_obj = add_to_map(obj, tab)
            for i = 1:obj.len
                tab.add_block(obj.x(i), obj.y(i), obj.z(i), obj.type);
            end

            new_obj = Blocos([obj.x(1) obj.y(1) 10]);
        end
    end
end

