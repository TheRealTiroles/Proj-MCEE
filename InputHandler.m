classdef InputHandler < handle
    properties

        Game_;
        LastInput_;

    end

    methods
        function this = InputHandler(game)
            this.Game_ = game;
            this.LastInput_ = tic;
        end

        function InputHandlerGame(this, event)
            switch event.Key
                case 'uparrow'
                   [direction, axis] = this.Game_.Renderer_.GetMovementDirection('up');
                   this.Game_.TryMoveBlock(direction, axis);
                case 'downarrow'
                    [direction, axis] = this.Game_.Renderer_.GetMovementDirection('down');
                    this.Game_.TryMoveBlock(direction, axis);
                case 'rightarrow'
                    [direction, axis] = this.Game_.Renderer_.GetMovementDirection('right');
                    this.Game_.TryMoveBlock(direction, axis);
                case 'leftarrow'
                    [direction, axis] = this.Game_.Renderer_.GetMovementDirection('left');
                    this.Game_.TryMoveBlock(direction, axis);
                case 'a'
                    this.Game_.Renderer_.MoveAzimuth(-1);
                case 's'
                    this.Game_.Renderer_.MoveElevation(-1);
                case 'd'
                    this.Game_.Renderer_.MoveAzimuth(1);
                case 'w'
                    this.Game_.Renderer_.MoveElevation(1);
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
                    this.Game_.ConfigurarInterfacPauseMenu();
                    return;
            end
            this.Game_.Renderer_.DrawPecaAtiva();
        end

        function InputHandlerPaused(this, event)

            opcoes = enumeration('PauseMenuOpt');
            indice_atual = find(opcoes == this.Game_.PauseMenuOpt_);
            switch event.Key
                case 'return'
                    switch this.Game_.PauseMenuOpt_
                        case PauseMenuOpt.Continue
                            this.Game_.GameState_ = GameState.Wait;
                            this.Game_.ConfigurarInterfaceJogo();
                            set(this.Game_.Renderer_.Fig_, 'DeleteFcn', @(~,~) delete(this.Game_));
                            this.Game_.Renderer_.DrawGame();
                            
                        case PauseMenuOpt.Save
                        case PauseMenuOpt.Exit
                            this.Game_.GameState_ = GameState.Menu;
                            this.Game_.ConfigurarInterfaceMenu();
                            this.Game_.ResetGame();
                    end
                case 'uparrow'
                    if indice_atual == 1
                        this.Game_.PauseMenuOpt_ = opcoes(find(opcoes == this.Game_.PauseMenuOpt_) + 2);
                    else
                        this.Game_.PauseMenuOpt_ = opcoes(find(opcoes == this.Game_.PauseMenuOpt_) - 1);
                    end
                    this.Game_.Renderer_.DrawPauseMenu();
                case 'downarrow'
                    if indice_atual == 3
                        this.Game_.PauseMenuOpt_ = opcoes(find(opcoes == this.Game_.PauseMenuOpt_) - 2);
                    else
                        this.Game_.PauseMenuOpt_ = opcoes(find(opcoes == this.Game_.PauseMenuOpt_) + 1);
                    end
                    this.Game_.Renderer_.DrawPauseMenu();
            end

        end

        function InputHandlerMenu(this, event)
            opcoes = enumeration('MenuOpt');
            indice_atual = find(opcoes == this.Game_.MenuOpt_);
            switch event.Key
                case 'return'
                    switch this.Game_.MenuOpt_
                        case MenuOpt.Start
                            this.Game_.Height_ = this.Game_.SettingsHeight_;
                            this.Game_.Width_ = this.Game_.SettingsWidth_;
                            this.Game_.Map_ = zeros(this.Game_.Width_, this.Game_.Width_, this.Game_.Height_+2);
                            this.Game_.GameState_ = GameState.Playing;
                            this.Game_.ConfigurarInterfaceJogo();
                            this.Game_.StartGame();
                        case MenuOpt.Statistics
                        case MenuOpt.Settings
                            this.Game_.GameState_ = GameState.Settings;
                            this.Game_.ConfigurarInterfaceSettings();
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

        function InputHandlerGameOver(this, event)

            if ~isempty(event.Key)
                this.Game_.GameState_ = GameState.Menu;
                this.Game_.ConfigurarInterfaceMenu();
            end

        end

        function InputHandlerSettings(this, event)
            switch event.Key
                case 'return'
                    this.Game_.GameState_ = GameState.Menu;
                    this.Game_.ConfigurarInterfaceMenu();
                case 'uparrow'
                    opcoes = enumeration('SettingsOpt');
                    idx = find(opcoes == this.Game_.SettingsOpt_);
                    if idx > 1
                        this.Game_.SettingsOpt_ = opcoes(idx - 1);
                    else
                        this.Game_.SettingsOpt_ = opcoes(end);
                    end
                    this.Game_.Renderer_.DrawSettings();
                case 'downarrow'
                    opcoes = enumeration('SettingsOpt');
                    idx = find(opcoes == this.Game_.SettingsOpt_);
                    if idx < length(opcoes)
                        this.Game_.SettingsOpt_ = opcoes(idx + 1);
                    else
                        this.Game_.SettingsOpt_ = opcoes(1);
                    end
                    this.Game_.Renderer_.DrawSettings();
                case 'leftarrow'
                    if this.Game_.SettingsOpt_ == SettingsOpt.Width
                        this.Game_.SettingsWidth_ = max(5, this.Game_.SettingsWidth_ - 1);
                    elseif this.Game_.SettingsOpt_ == SettingsOpt.Height
                        this.Game_.SettingsHeight_ = max(10, this.Game_.SettingsHeight_ - 1);
                    else
                        this.Game_.SettingsDifficulty_ = max(1, this.Game_.SettingsDifficulty_ - 1);
                    end
                    this.Game_.Renderer_.DrawSettings();
                case 'rightarrow'
                    if this.Game_.SettingsOpt_ == SettingsOpt.Width
                        this.Game_.SettingsWidth_ = min(10, this.Game_.SettingsWidth_ + 1);
                    elseif this.Game_.SettingsOpt_ == SettingsOpt.Height
                        this.Game_.SettingsHeight_ = min(20, this.Game_.SettingsHeight_ + 1);
                    else
                        this.Game_.SettingsDifficulty_ = min(3, this.Game_.SettingsDifficulty_ + 1);
                    end
                    this.Game_.Renderer_.DrawSettings();
            end
        end

        function TecladoCallback(this, ~, event)
            tempo_decorrido = toc(this.LastInput_) * 1000;
            if tempo_decorrido < 100
                return;
            end
            this.LastInput_ = tic;
            
            if this.Game_.GameState_ == GameState.Playing
                this.InputHandlerGame(event);
            
            elseif this.Game_.GameState_ == GameState.Paused
                this.InputHandlerPaused(event);

            elseif this.Game_.GameState_ == GameState.Menu
                this.InputHandlerMenu(event);

            elseif this.Game_.GameState_ == GameState.Settings
                this.InputHandlerSettings(event);

            elseif this.Game_.GameState_ == GameState.GameOver
                this.InputHandlerGameOver(event);

            end
            
        end

        function MouseMotionCallback(this, ~, ~)
            if this.Game_.GameState_ == GameState.Menu
                this.UpdateMenuMouseHover();
            
            elseif this.Game_.GameState_ == GameState.Paused
                this.UpdatePauseMenuMouseHover();
            end
        end

        function UpdateMenuMouseHover(this)
            pt = get(this.Game_.Renderer_.Eixos_, 'CurrentPoint');
            mouse_x = pt(1, 1);
            mouse_y = pt(1, 2);
            
            opcoes = enumeration('MenuOpt');
            pos_y = [0.8, 0.6, 0.4, 0.2];
            center_x = 0.45;
            tolerance_y = 0.05;
            tolerance_x = 0.15;
            
            for i = 1:4
                if abs(mouse_y - pos_y(i)) < tolerance_y && abs(mouse_x - center_x) < tolerance_x
                    if this.Game_.MenuOpt_ ~= opcoes(i)
                        this.Game_.MenuOpt_ = opcoes(i);
                        this.Game_.Renderer_.DrawMenu();
                    end
                    return;
                end
            end
        end

        function UpdatePauseMenuMouseHover(this)
            pt = get(this.Game_.Renderer_.Eixos_, 'CurrentPoint');
            mouse_x = pt(1, 1);
            mouse_y = pt(1, 2);
            
            opcoes = enumeration('PauseMenuOpt');
            pos_y = [0.8, 0.6, 0.4, 0.2];
            center_x = 0.45;
            tolerance_y = 0.05;
            tolerance_x = 0.15;
            
            for i = 1:3
                if abs(mouse_y - pos_y(i)) < tolerance_y && abs(mouse_x - center_x) < tolerance_x
                    if this.Game_.PauseMenuOpt_ ~= opcoes(i)
                        this.Game_.PauseMenuOpt_ = opcoes(i);
                        this.Game_.Renderer_.DrawPauseMenu();
                    end
                    return;
                end
            end
        end

        function MouseCallBack(this, ~, ~)
            if this.Game_.GameState_ == GameState.Menu
                this.InputHandlerMenuMouse();
            
            elseif this.Game_.GameState_ == GameState.Paused
                this.InputHandlerPausedMouse();
                
            elseif this.Game_.GameState_ == GameState.GameOver
                this.InputHandlerGameOverMouse();
            end
        end

        function InputHandlerMenuMouse(this)
            pt = get(this.Game_.Renderer_.Eixos_, 'CurrentPoint');
            mouse_x = pt(1, 1);
            mouse_y = pt(1, 2);
            
            opcoes = enumeration('MenuOpt');
            pos_y = [0.8, 0.6, 0.4, 0.2];
            center_x = 0.45;
            
            tolerance_y = 0.05;
            tolerance_x = 0.15;
            
            for i = 1:4
                if abs(mouse_y - pos_y(i)) < tolerance_y && abs(mouse_x - center_x) < tolerance_x
                    switch opcoes(i)
                        case MenuOpt.Start
                            this.Game_.GameState_ = GameState.Playing;
                            this.Game_.ConfigurarInterfaceJogo();
                            this.Game_.StartGame();
                        case MenuOpt.Statistics
                        case MenuOpt.Settings
                            this.Game_.GameState_ = GameState.Settings;
                            this.Game_.ConfigurarInterfaceSettings();
                        case MenuOpt.Quit
                            delete(this.Game_);
                    end
                    return;
                end
            end
        end

        function InputHandlerPausedMouse(this)
            pt = get(this.Game_.Renderer_.Eixos_, 'CurrentPoint');
            mouse_x = pt(1, 1);
            mouse_y = pt(1, 2);
            
            opcoes = enumeration('PauseMenuOpt');
            pos_y = [0.8, 0.6, 0.4, 0.2];
            center_x = 0.45;
            
            tolerance_y = 0.05;
            tolerance_x = 0.15;
            
            for i = 1:3
                if abs(mouse_y - pos_y(i)) < tolerance_y && abs(mouse_x - center_x) < tolerance_x
                    switch opcoes(i)
                        case PauseMenuOpt.Continue
                            this.Game_.GameState_ = GameState.Wait;
                            this.Game_.ConfigurarInterfaceJogo();
                            set(this.Game_.Renderer_.Fig_, 'DeleteFcn', @(~,~) delete(this.Game_));
                            this.Game_.Renderer_.DrawGame();
                            
                        case PauseMenuOpt.Save

                        case PauseMenuOpt.Exit
                            this.Game_.GameState_ = GameState.Menu;
                            this.Game_.ConfigurarInterfaceMenu();
                            this.Game_.ResetGame();
                    end
                    return;
                end
            end
        end

        function InputHandlerGameOverMouse(this)

            this.Game_.GameState_ = GameState.Menu;
            this.Game_.ConfigurarInterfaceMenu();
        end
    end
end