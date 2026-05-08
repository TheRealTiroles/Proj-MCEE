classdef InputHandler < handle
    properties

        Game_;

    end

    methods
        function this = InputHandler(game)

            this.Game_ = game;

        end

        function InputHandlerGame(this, event)
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
                case 'escape'
                    this.Game_.GameState_ = GameState.Paused;
            end
            this.Game_.Renderer_.DrawPecaAtiva();
        end

        function InputHandlerPaused(this, event)

            switch event.Key
                case 'escape'
                    this.Game_.GameState_ = GameState.Wait;
            end

        end

        function InputHandlerMenu(this, event)
            opcoes = enumeration('MenuOpt');
            indice_atual = find(opcoes == this.Game_.MenuOpt_);
            switch event.Key
                case 'return'
                    switch this.Game_.MenuOpt_
                        case MenuOpt.Start
                            this.Game_.GameState_ = GameState.Playing;
                            this.Game_.ConfigurarInterfaceJogo();
                        case MenuOpt.Statistics
                        case MenuOpt.Settings
                        case MenuOpt.Quit
                            delete(this.Game_);
                    end
                case 'uparrow'
                    if indice_atual < 2
                        this.Game_.MenuOpt_ = opcoes(find(opcoes == this.Game_.MenuOpt_) + 3);
                    else
                        this.Game_.MenuOpt_ = opcoes(find(opcoes == this.Game_.MenuOpt_) - 1);
                    end
                    this.Game_.Renderer_.DrawMenu();
                case 'downarrow'
                    if indice_atual > 3
                        this.Game_.MenuOpt_ = opcoes(find(opcoes == this.Game_.MenuOpt_) - 3);
                    else
                        this.Game_.MenuOpt_ = opcoes(find(opcoes == this.Game_.MenuOpt_) + 1);
                    end
                    this.Game_.Renderer_.DrawMenu();
            end
        end

        function TecladoCallback(this, ~, event)
            if this.Game_.GameState_ == GameState.Playing
                this.InputHandlerGame(event);
            
            elseif this.Game_.GameState_ == GameState.Paused
                this.InputHandlerPaused(event);

            elseif this.Game_.GameState_ == GameState.Menu
                this.InputHandlerMenu(event);
            end
            
        end
    end
end