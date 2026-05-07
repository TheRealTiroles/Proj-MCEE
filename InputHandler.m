classdef InputHandler < handle
    properties

        Game_;

    end

    methods
        function this = InputHandler(game)

            this.Game_ = game;

        end


        function TecladoCallback(this, ~, event)
            if this.Game_.GameState_ ~= GameState.Playing
                return;
            end
            
            fprintf(event.Key)
            
            switch event.Key
                case 'uparrow'
                   this.Game_.TryMoveBlock([0 1 0], 2);
                case 'downarrow'
                    this.Game_.TryMoveBlock([0 -1 0], 2);
                case 'rightarrow'
                    this.Game_.TryMoveBlock([1 0 0], 1);
                case 'leftarrow'
                    this.Game_.TryMoveBlock([-1 0 0], 1);
                case 'space'
                    this.Game_.FreeFall();
                    return;
                case '1'
                    this.Game_.ChangeView(1);
                case '2'
                    this.Game_.ChangeView(2);
                case '3'
                   this.Game_.ChangeView(3);
                case '4'
                    this.Game_.ChangeView(4);
            end
            this.Game_.Renderer_.DrawPecaAtiva();
        end
    end
end