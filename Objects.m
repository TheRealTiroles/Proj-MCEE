classdef Objects < handle
    properties
        position_;
        color_;
    end

    methods(Abstract)
        function this = Objects(initialCoords, color)
            this.position_ = initialCoords;
            this.color_ = color;
        end
    end
    methods(Sealed)
        function SetPosition(this, Coords)
            this.position_ = Coords;
        end
        function Coords = getPosition(this)
            Coords = this.position_;
        end
    end
end