classdef Game < handle
    properties
        Height_;
        Width_;
        Map_;

        PecaAtiva_;

        Clock_;
        ClockWait_;

    
        PosFutura_;
        Renderer_;
        InputHandler_;

        GameState_;

        WaitTime_;
        MenuOpt_;
        PauseMenuOpt_;
    end

    methods
        function this = Game(height, width)
            this.Height_ = height;
            this.Width_ = width;  
            this.Map_ = zeros(this.Width_, this.Width_, this.Height_+2);
            
            this.Clock_ = [];
            this.WaitTime_ = 3;
            this.ClockWait_ = [];

            this.MenuOpt_ = MenuOpt.Start;
            this.PauseMenuOpt_ = PauseMenuOpt.Continue;
            this.GameState_ = GameState.Menu;
            
            this.InputHandler_ = InputHandler(this);
            this.Renderer_ = Renderer(this);

            this.ConfigurarInterfaceMenu();
        end
    
        function ConfigurarInterfaceJogo(this)
            if isgraphics(this.Renderer_.Fig_)
                clf(this.Renderer_.Fig_);
                set(this.Renderer_.Fig_, 'Name', 'Tetris', ...
                                    'KeyPressFcn', @(src, event) this.InputHandler_.TecladoCallback(src, event));
            else
                this.Renderer_.Fig_ = figure('Name', 'Tetris', ...
                                    'ToolBar', 'none', ...
                                    'Menu', 'none', ...
                                    'WindowState', 'maximized', ...
                                    'NumberTitle', 'off', ...
                                    'KeyPressFcn', @(src, event) this.InputHandler_.TecladoCallback(src, event));
            end
            this.Renderer_.Eixos_ = axes('Parent', this.Renderer_.Fig_);
            set(this.Renderer_.Fig_, 'CurrentAxes', this.Renderer_.Eixos_);
            axis(this.Renderer_.Eixos_, 'equal');
            grid(this.Renderer_.Eixos_, 'on');
            view(this.Renderer_.Eixos_, 3);
            

            xlim(this.Renderer_.Eixos_, [0, this.Width_]); xlabel('x'); xticks(0:this.Width_);
            ylim(this.Renderer_.Eixos_, [0, this.Width_]); ylabel('y'); yticks(0:this.Width_);
            zlim(this.Renderer_.Eixos_, [0, this.Height_]); zlabel('z'); zticks(0:this.Height_);
        end

        function ConfigurarInterfaceMenu(this)
            if isgraphics(this.Renderer_.Fig_)
                clf(this.Renderer_.Fig_);
                set(this.Renderer_.Fig_, 'Name', 'Menu Tetris', ...
                                    'KeyPressFcn', @(src, event) this.InputHandler_.TecladoCallback(src, event));
            else
                this.Renderer_.Fig_ = figure('Name', 'Menu Tetris', ...
                                    'ToolBar', 'none', ...
                                    'Menu', 'none', ...
                                    'WindowState', 'maximized', ...
                                    'NumberTitle', 'off', ...
                                    'KeyPressFcn', @(src, event) this.InputHandler_.TecladoCallback(src, event));
            end
            this.MenuOpt_ = MenuOpt.Start;
            this.Renderer_.Eixos_ = axes('Parent', this.Renderer_.Fig_, 'Visible', 'off');
            set(this.Renderer_.Fig_, 'CurrentAxes', this.Renderer_.Eixos_);
            this.Renderer_.DrawMenu();
        end

        function ConfigurarInterfacPauseMenu(this)
            if isgraphics(this.Renderer_.Fig_)
                clf(this.Renderer_.Fig_);
                set(this.Renderer_.Fig_, 'Name', 'Paused', ...
                                    'KeyPressFcn', @(src, event) this.InputHandler_.TecladoCallback(src, event));
            else
                this.Renderer_.Fig_ = figure('Name', 'Paused', ...
                                    'ToolBar', 'none', ...
                                    'Menu', 'none', ...
                                    'WindowState', 'maximized', ...
                                    'NumberTitle', 'off', ...
                                    'KeyPressFcn', @(src, event) this.InputHandler_.TecladoCallback(src, event));
            end
            this.PauseMenuOpt_ = PauseMenuOpt.Continue;
            this.Renderer_.Eixos_ = axes('Parent', this.Renderer_.Fig_, 'Visible', 'off');
            set(this.Renderer_.Fig_, 'CurrentAxes', this.Renderer_.Eixos_);
            this.Renderer_.DrawPauseMenu();
        end

        function ChangeView(this, x)
            this.Renderer_.ChangeView(x);
        end

        function TryMoveBlock(this, direction, c)
            nova_pos = this.PecaAtiva_.PosicaoPivo_ + direction;
            colisao = this.check_colision(this.PecaAtiva_, nova_pos, c);
            if ~colisao
                this.PecaAtiva_.MoverPara(nova_pos);
            end
            this.Renderer_.DrawGame();
        end

        function colisao = check_colision(this, Peca, nova_pos, c)
            colisao = false;
            for n = 1:size(Peca.Shape_, 1)
                bloco = Peca.Shape_(n, :) + nova_pos;
                if bloco(c) < 1 || bloco(c) > this.Width_
                    colisao = true;
                elseif this.Map_(bloco(1), bloco(2), min(bloco(3), this.Height_)) ~= 0
                    colisao = true;
                end
             end
        end

        function WaitTick(this)
            if this.GameState_ == GameState.Wait
                this.Renderer_.DrawWaitTime();
            end
            if this.WaitTime_ <= 0
                this.GameState_ = GameState.Playing;
                this.WaitTime_ = 3;
            end
            if this.GameState_ ~= GameState.Wait
                return;
            end
        end

        function ClockTick(this)
            if this.GameState_ ~= GameState.Playing
                return;
            end


            nova_pos = this.PecaAtiva_.PosicaoPivo_ + [0, 0, -1];
            

            colocou_no_chao = false;
            for n = 1:size(this.PecaAtiva_.Shape_, 1)
                bloco = this.PecaAtiva_.Shape_(n, :) + nova_pos;

                if bloco(3) < 1 || this.Map_(bloco(1), bloco(2), min(bloco(3), this.Height_)) ~= 0
                    colocou_no_chao = true;
                    break;
                end
            end

            if ~colocou_no_chao

                this.PecaAtiva_.MoverPara(nova_pos);
            else

                forma = this.PecaAtiva_.Shape_;
                pos = this.PecaAtiva_.PosicaoPivo_;
                tipo = this.PecaAtiva_.Tipo_;
                
                for n = 1:size(forma, 1)
                    bloco = forma(n, :) + pos;
                    if bloco(3) <= this.Height_
                        this.Map_(bloco(1), bloco(2), bloco(3)) = tipo;
                    end
                end
                

                for k = this.Height_:-1:1

                    if all(this.Map_(:, :, k), 'all')

                        for l = k:this.Height_-1
                            this.Map_(:, :, l) = this.Map_(:, :, l+1);
                        end
                        this.Map_(:, :, this.Height_) = 0;
                        

                        stop(this.Clock_);
                        this.Clock_.Period = max(0.1, this.Clock_.Period - 0.1);
                        start(this.Clock_);
                    end
                end
                

                this.PecaAtiva_ = PecaAtiva([3, 3, this.Height_], this);
                

                pos_nova = this.PecaAtiva_.PosicaoPivo_;
                for n = 1:size(this.PecaAtiva_.Shape_, 1)
                    b = this.PecaAtiva_.Shape_(n, :) + pos_nova;
                    if this.Map_(b(1), b(2), min(b(3), this.Height_)) ~= 0
                        this.GameOver();
                        return;
                    end
                end
            end            
            this.Renderer_.DrawGame();
        end

        function FreeFall(this)
            if this.GameState_ ~= GameState.Playing
                return;
            end
            
            colocou_no_chao = false;
            while ~colocou_no_chao
                nova_pos = this.PecaAtiva_.PosicaoPivo_ + [0, 0, -1];
                for n = 1:size(this.PecaAtiva_.Shape_, 1)
                    bloco = this.PecaAtiva_.Shape_(n, :) + nova_pos;
                    if bloco(3) < 1 || this.Map_(bloco(1), bloco(2), min(bloco(3), this.Height_)) ~= 0
                        colocou_no_chao = true;
                        break;
                    end
                end
                
                if ~colocou_no_chao
                    this.PecaAtiva_.MoverPara(nova_pos);
                end
            end
            
            this.ClockTick();
        end
        
        function StartGame(this)
            this.PecaAtiva_ = PecaAtiva([floor(this.Width_/2), floor(this.Width_/2), this.Height_], this);

            t_antigos = timerfind;
            if ~isempty(t_antigos)
                stop(t_antigos);
                delete(t_antigos);
            end

            this.Clock_ = timer('ExecutionMode', 'fixedRate', 'Period',...
                1, 'TimerFcn', @(src, event) this.ClockTick());
            this.ClockWait_ = timer('ExecutionMode', 'fixedRate', 'Period',...
                1, 'TimerFcn', @(src, event) this.WaitTick());


            set(this.Renderer_.Fig_, 'DeleteFcn', @(~,~) delete(this));
            
            start(this.Clock_);
            start(this.ClockWait_);
        end

        function GameOver(this)
            this.GameState_ = GameState.GameOver;
            stop(this.Clock_);
            this.Renderer_.DrawGameOver();
        end


        function delete(this)
            t_antigos = timerfind; 
            delete(this.Renderer_.Fig_);
            if ~isempty(this.Clock_)
                if isvalid(this.Clock_)
                    stop(this.Clock_);
                    delete(this.Clock_);
                end
            end
            if ~isempty(this.ClockWait_)
                if isvalid(this.ClockWait_)
                    stop(this.ClockWait_);
                    delete(this.ClockWait_);
                end
            end
        end

    end
end