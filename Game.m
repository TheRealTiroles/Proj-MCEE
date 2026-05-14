classdef Game < handle
    properties
        Height_;
        Width_;
        Map_;
        Score_;

        PecaAtiva_;

        Clock_;
        ClockWait_;
        Theme_;

    
        PosFutura_;
        Renderer_;
        InputHandler_;

        GameState_;

        WaitTime_;
        MenuOpt_;
        PauseMenuOpt_;

        SettingsOpt_;
        SettingsWidth_;
        SettingsHeight_;
        SettingsDifficulty_;
    end

    methods
        function this = Game(height, width)
            this.Height_ = height;
            this.Width_ = width;  
            this.Map_ = zeros(this.Width_, this.Width_, this.Height_+2);
            this.Score_ = 0;
            
            this.Clock_ = [];
            this.WaitTime_ = 3;
            this.ClockWait_ = [];

            [a, fs] = audioread("resources/audio/Tetris - Main Theme (Synthwave Version).mp3");
            this.Theme_ = audioplayer(a, fs);

            this.PecaAtiva_ = PecaAtiva.empty(1, 0);

            this.MenuOpt_ = MenuOpt.Start;
            this.PauseMenuOpt_ = PauseMenuOpt.Continue;
            this.SettingsOpt_ = SettingsOpt.Width;
            this.SettingsWidth_ = width;
            this.SettingsHeight_ = height;
            this.SettingsDifficulty_ = 1;
            this.GameState_ = GameState.Menu;
            
            this.InputHandler_ = InputHandler(this);
            this.Renderer_ = Renderer(this);

            this.ConfigurarInterfaceMenu();
        end

        function ResetGame(this)
            this.Map_ = zeros(this.Width_, this.Width_, this.Height_+2);
            stop(this.Theme_);
        end
    
        function ConfigurarInterfaceJogo(this)
            this.Renderer_.SetupGameInterface(this.SettingsDifficulty_ ~= 3);
        end

        function ConfigurarInterfaceMenu(this)
            this.Renderer_.SetupMenuInterface();
            this.MenuOpt_ = MenuOpt.Start;
            this.Renderer_.DrawMenu();
        end

        function ConfigurarInterfacPauseMenu(this)
            pause(this.Theme_);
            this.Renderer_.SetupPauseMenuInterface();
            this.PauseMenuOpt_ = PauseMenuOpt.Continue;
            this.Renderer_.DrawPauseMenu();
        end

        function ConfigurarInterfaceSettings(this)
            this.Renderer_.SetupSettingsInterface();
            this.SettingsOpt_ = SettingsOpt.Width;
            this.Renderer_.DrawSettings();
        end

        function ChangeView(this, x)
            this.Renderer_.ChangeView(x);
        end

        function TryMoveBlock(this, direction, c)
            nova_pos = this.PecaAtiva_(1).PosicaoPivo_ + direction;
            colisao = this.check_colision(this.PecaAtiva_(1), nova_pos, c);
            if ~colisao
                this.PecaAtiva_(1).MoverPara(nova_pos);
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
                resume(this.Theme_);
                this.WaitTime_ = 3;
            end
            if this.GameState_ ~= GameState.Wait
                return;
            end
        end

        function colocou_no_chao = CheckPosou(this, nova_pos)
            colocou_no_chao = false;
            for n = 1:size(this.PecaAtiva_(1).Shape_, 1)
                bloco = this.PecaAtiva_(1).Shape_(n, :) + nova_pos;

                if bloco(3) < 1 || this.Map_(bloco(1), bloco(2), min(bloco(3), this.Height_)) ~= 0
                    colocou_no_chao = true;
                    this.incrementScore(0);
                    break;
                end
            end
        end

        function deleteFullLayers(this)

            for k = this.Height_:-1:1

                if all(this.Map_(:, :, k), 'all')
                    
                    for l = k:this.Height_-1
                        this.Map_(:, :, l) = this.Map_(:, :, l+1);
                    end
                    this.Map_(:, :, this.Height_) = 0;
                    
                    this.incrementScore(1);
                    if this.SettingsDifficulty_ ~= 1
                        stop(this.Clock_);
                        this.Clock_.Period = max(0.1, this.Clock_.Period - 0.1);
                        start(this.Clock_);
                    end
                end
            end

        end

        function checkIfGameLost(this)

            for n = 1:size(this.PecaAtiva_(1).Shape_, 1)
                b = this.PecaAtiva_(1).Shape_(n, :) + this.PecaAtiva_(1).PosicaoPivo_;
                if this.Map_(b(1), b(2), min(b(3), this.Height_)) ~= 0
                    this.GameOver();
                    return;
                end
            end

        end

        function ClockTick(this)
            if this.GameState_ ~= GameState.Playing
                return;
            end

            z_movimento = -1;
            if this.SettingsDifficulty_ == 1
                z_movimento = 0;
            end
            nova_pos = this.PecaAtiva_(1).PosicaoPivo_ + [0, 0, z_movimento];

            colocou_no_chao = this.CheckPosou(nova_pos);

            if ~colocou_no_chao

                this.PecaAtiva_(1).MoverPara(nova_pos);
            else

                forma = this.PecaAtiva_(1).Shape_;
                pos = this.PecaAtiva_(1).PosicaoPivo_;
                tipo = this.PecaAtiva_(1).Tipo_;
                
                for n = 1:size(forma, 1)
                    bloco = forma(n, :) + pos;
                    if bloco(3) <= this.Height_
                        this.Map_(bloco(1), bloco(2), bloco(3)) = tipo;
                    end
                end
                
                this.deleteFullLayers();

                this.PecaAtiva_(1:3) = this.PecaAtiva_(2:4);
                this.PecaAtiva_(4) = PecaAtiva([floor(this.Width_/2), floor(this.Width_/2), this.Height_], this);

                this.checkIfGameLost();
                
            end            
            this.Renderer_.DrawGame();
        end

        function FreeFall(this)
            if this.GameState_ ~= GameState.Playing
                return;
            end
            
            colocou_no_chao = false;
            while ~colocou_no_chao
                nova_pos = this.PecaAtiva_(1).PosicaoPivo_ + [0, 0, -1];
                colocou_no_chao = this.CheckPosou(nova_pos);
                
                if ~colocou_no_chao
                    this.PecaAtiva_(1).MoverPara(nova_pos);
                end
            end
            
            forma = this.PecaAtiva_(1).Shape_;
            pos = this.PecaAtiva_(1).PosicaoPivo_;
            tipo = this.PecaAtiva_(1).Tipo_;
            
            for n = 1:size(forma, 1)
                bloco = forma(n, :) + pos;
                if bloco(3) <= this.Height_
                    this.Map_(bloco(1), bloco(2), bloco(3)) = tipo;
                end
            end
            
            this.deleteFullLayers();

            this.PecaAtiva_(1:3) = this.PecaAtiva_(2:4);
            this.PecaAtiva_(4) = PecaAtiva([floor(this.Width_/2), floor(this.Width_/2), this.Height_], this);

            this.checkIfGameLost();
            this.Renderer_.DrawGame();
        end

        function incrementScore(this, tetris)
            increment = 1;
            
            if tetris
                increment = 10;
            end

            switch this.SettingsDifficulty_
                case 1
                    increment = increment * 1;
                case 2
                    increment = increment * 1.5;
                case 3
                    increment = increment * 2;
            end

            switch this.PecaAtiva_(1).Tipo_
                case 1
                    this.Score_ = this.Score_ + increment*10;
                case {2, 3, 4}
                    this.Score_ = this.Score_ + increment*20;
                case {5, 6, 7}
                    this.Score_ = this.Score_ + increment*30;
                case 8
                    this.Score_ = this.Score_ + increment*80;
            end
            disp(this.Score_);
        end
        
        function StartGame(this)
            this.PecaAtiva_ = PecaAtiva.empty(1, 0);
            for i = 1:4
                this.PecaAtiva_(i) = PecaAtiva([floor(this.Width_/2), floor(this.Width_/2), this.Height_], this);
            end
            
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
            play(this.Theme_);
            
        end

        function GameOver(this)
            this.GameState_ = GameState.GameOver;
            stop(this.Clock_);
            this.Renderer_.DrawGameOver();
            this.Map_ = zeros(this.Width_, this.Width_, this.Height_+2);
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