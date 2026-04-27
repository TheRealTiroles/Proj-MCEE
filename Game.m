classdef Game < handle
    properties
        map;
        objects;
    end

    methods
        function this = Game(size)
            this.map = zeros(10, 10, size);
            this.objects = {};
        end
        function addObject(this, newObject)
            this.objects = {this.objects newObject};
        
        
        end

        function updatemap(this, newCoordsOcupied)



        end


        function deleteLayer(this, layer)
            this.map(:,:,layer) = 0;
        end

        function CheckLayers(this)
            
            layers = all(this.map == 1, 1:size(this.map));
            hasToCheck = true;

            while hasToCheck
                for i = 1:length(layers)
                    if layers(1, 1, i) == 1
                        this.map(:,:,i) = 0;
                        break
                    end
                end
                hasToCheck = false;
            end
        end
    end
end