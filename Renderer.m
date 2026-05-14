classdef Renderer < handle
    properties
        Game_;
        Fig_;
        Eixos_;
        EixosAux_;
        Txt_;

        ViewAzimuth_;
        ViewElevation_;
    end

    methods 
        function this = Renderer(game)
            this.Game_ = game;

            this.Fig_ = [];
            this.Eixos_ = [];
            this.EixosAux_ = [];
            this.Txt_ = [];

            this.ViewAzimuth_ = -37.5;
            this.ViewElevation_ = 30;
        end

        function ChangeView(this, vista_id)
            switch vista_id
                case 1, view(this.Eixos_, [0 0 this.Game_.Height_]);
                case 2, view(this.Eixos_, [0 this.Game_.Width_ 0]);
                case 3, view(this.Eixos_, [this.Game_.Width_ 0 0]);
                case 4, view(this.Eixos_, 3);
            end
        end

        function MoveAzimuth(this, delta)
            this.ViewAzimuth_ = this.ViewAzimuth_ + delta * 5;
            view(this.Eixos_, [this.ViewAzimuth_, this.ViewElevation_]);
            
            if ~isempty(this.EixosAux_) && isgraphics(this.EixosAux_)
                view(this.EixosAux_, [this.ViewAzimuth_, 30]);
            end
        end

        function MoveElevation(this, delta)
            this.ViewElevation_ = max(-90, min(90, this.ViewElevation_ + delta * 5));
            view(this.Eixos_, [this.ViewAzimuth_, this.ViewElevation_]);
        end

        function [direction, axis] = GetMovementDirection(this, moveType)
            
            az = mod(this.ViewAzimuth_, 360);
            
            quadrant = round(az / 90) * 90;
            quadrant = mod(quadrant, 360);
            
            switch quadrant
                case 0
                    switch moveType
                        case 'up',    direction = [0, 1, 0]; axis = 2;
                        case 'down',  direction = [0, -1, 0]; axis = 2;
                        case 'left',  direction = [-1, 0, 0]; axis = 1;
                        case 'right', direction = [1, 0, 0]; axis = 1;
                    end
                case 90
                    switch moveType
                        case 'up',    direction = [-1, 0, 0]; axis = 1;
                        case 'down',  direction = [1, 0, 0]; axis = 1;
                        case 'left',  direction = [0, -1, 0]; axis = 2;
                        case 'right', direction = [0, 1, 0]; axis = 2;
                    end
                case 180
                    switch moveType
                        case 'up',    direction = [0, -1, 0]; axis = 2;
                        case 'down',  direction = [0, 1, 0]; axis = 2;
                        case 'left',  direction = [1, 0, 0]; axis = 1;
                        case 'right', direction = [-1, 0, 0]; axis = 1;
                    end
                case 270
                    switch moveType
                        case 'up',    direction = [1, 0, 0]; axis = 1;
                        case 'down',  direction = [-1, 0, 0]; axis = 1;
                        case 'left',  direction = [0, 1, 0]; axis = 2;
                        case 'right', direction = [0, -1, 0]; axis = 2;
                    end
            end
        end

        function SetupFigure(this, title_str, keyPressFcn)
            if isgraphics(this.Fig_)
                clf(this.Fig_);
                set(this.Fig_, 'Name', title_str, 'KeyPressFcn', keyPressFcn);
            else
                this.Fig_ = figure('Name', title_str, ...
                                    'ToolBar', 'none', ...
                                    'Menu', 'none', ...
                                    'WindowState', 'maximized', ...
                                    'NumberTitle', 'off', ...
                                    'KeyPressFcn', keyPressFcn);
            end
        end

        function SetupFigureWithMouse(this, title_str, keyPressFcn, mouseDownFcn, mouseMotionFcn)
            this.SetupFigure(title_str, keyPressFcn);
            set(this.Fig_, 'WindowButtonDownFcn', mouseDownFcn, 'WindowButtonMotionFcn', mouseMotionFcn);
        end

        function SetupFigureWithScroll(this, title_str, keyPressFcn, mouseDownFcn, mouseMotionFcn, scrollFcn)
            this.SetupFigureWithMouse(title_str, keyPressFcn, mouseDownFcn, mouseMotionFcn);
            set(this.Fig_, 'WindowScrollWheelFcn', scrollFcn);
        end

        function SetupGameInterface(this, showNextPieces)
            this.SetupFigure('Tetris', @(src, event) this.Game_.InputHandler_.TecladoCallback(src, event));
            
            if showNextPieces
                this.Eixos_ = axes('Parent', this.Fig_, 'Position', [0.05 0.05 0.75 0.90]);
            else
                this.Eixos_ = axes('Parent', this.Fig_, 'Position', [0.05 0.05 0.95 0.90]);
            end
            
            set(this.Fig_, 'CurrentAxes', this.Eixos_);
            axis(this.Eixos_, 'equal');
            grid(this.Eixos_, 'on');
            view(this.ViewAzimuth_, this.ViewElevation_);
            
            xlim(this.Eixos_, [0, this.Game_.Width_]); xlabel('x'); xticks(0:this.Game_.Width_);
            ylim(this.Eixos_, [0, this.Game_.Width_]); ylabel('y'); yticks(0:this.Game_.Width_);
            zlim(this.Eixos_, [0, this.Game_.Height_]); zlabel('z'); zticks(0:this.Game_.Height_);
            
            if showNextPieces
                this.SetupNextPiecesDisplay();
            else
                this.EixosAux_ = [];
            end
        end

        function SetupNextPiecesDisplay(this)
            this.EixosAux_ = axes('Parent', this.Fig_, 'Position', [0.60 0.05 0.25 0.90]);
            set(this.Fig_, 'CurrentAxes', this.EixosAux_);
            axis(this.EixosAux_, 'off');
            grid(this.EixosAux_, 'off');
            daspect(this.EixosAux_, [1 1 1]);
            view(this.EixosAux_, [this.ViewAzimuth_, 30]);
            
            xlim(this.EixosAux_, [0, 4]);
            ylim(this.EixosAux_, [0, 4]);
            zlim(this.EixosAux_, [0, 12]);
            set(this.EixosAux_, 'Color', 'none');
            title(this.EixosAux_, 'Próximas Peças', 'FontSize', 12);
        end

        function SetupMenuInterface(this)
            this.SetupFigureWithMouse('Menu Tetris', @(src, event) this.Game_.InputHandler_.TecladoCallback(src, event), ...
                @(src, event) this.Game_.InputHandler_.MouseClickCallback(src, event), ...
                @(src, event) this.Game_.InputHandler_.MouseMotionCallback(src, event));
            
            this.Eixos_ = axes('Parent', this.Fig_, 'Visible', 'off');
            set(this.Fig_, 'CurrentAxes', this.Eixos_);
        end

        function SetupPauseMenuInterface(this)
            this.SetupFigureWithMouse('Paused', @(src, event) this.Game_.InputHandler_.TecladoCallback(src, event), ...
                @(src, event) this.Game_.InputHandler_.MouseClickCallback(src, event), ...
                @(src, event) this.Game_.InputHandler_.MouseMotionCallback(src, event));
            
            this.Eixos_ = axes('Parent', this.Fig_, 'Visible', 'off');
            set(this.Fig_, 'CurrentAxes', this.Eixos_);
        end

        function SetupSettingsInterface(this)
            this.SetupFigureWithScroll('Settings', @(src, event) this.Game_.InputHandler_.TecladoCallback(src, event), ...
                @(src, event) this.Game_.InputHandler_.MouseClickCallback(src, event), ...
                @(src, event) this.Game_.InputHandler_.MouseMotionCallback(src, event), ...
                @(src, event) this.Game_.InputHandler_.MouseScrollCallback(src, event));
            
            this.Eixos_ = axes('Parent', this.Fig_, 'Visible', 'off');
            set(this.Fig_, 'CurrentAxes', this.Eixos_);
        end
        function SetupGameOverInterface(this)
            this.SetupFigure('Game Over', @(src, event) this.Game_.InputHandler_.TecladoCallback(src, event));
            
            this.Eixos_ = axes('Parent', this.Fig_, 'Position', [0.05 0.05 0.75 0.90]);
            set(this.Fig_, 'CurrentAxes', this.Eixos_);
            axis(this.Eixos_, 'equal');
            grid(this.Eixos_, 'on');
            view(this.ViewAzimuth_, this.ViewElevation_);
            
            xlim(this.Eixos_, [0, this.Game_.Width_]); xlabel('x'); xticks(0:this.Game_.Width_);
            ylim(this.Eixos_, [0, this.Game_.Width_]); ylabel('y'); yticks(0:this.Game_.Width_);
            zlim(this.Eixos_, [0, this.Game_.Height_]); zlabel('z'); zticks(0:this.Game_.Height_);
        end
        function DrawBlocosPosicionados(this)
           
            v_unit = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
            f_unit = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            cores = [0 1 1; 0 1 0; 1 1 0; 0 0 1; 1 0 1; 1 0.5 0; 0.5 0 0.5; 1 0 0];
            

            for i = 1:this.Game_.Width_
                for j = 1:this.Game_.Width_
                    for k = 1:this.Game_.Height_
                        cor_idx = this.Game_.Map_(i, j, k);
                        if cor_idx ~= 0
                            v_temp = v_unit + [i-1, j-1, k-1];
                            patch(this.Eixos_, 'Vertices', v_temp, 'Faces', f_unit, ...
                                'FaceColor', cores(cor_idx, :), 'FaceAlpha', 1);
                        end
                    end
                end
            end
        end

        function DrawPecaAtiva(this)

            v_unit = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
            f_unit = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            cores = [0 1 1; 0 1 0; 1 1 0; 0 0 1; 1 0 1; 1 0.5 0; 0.5 0 0.5; 1 0 0];
            
            forma = this.Game_.PecaAtiva_(1).Shape_;
            pos = this.Game_.PecaAtiva_(1).PosicaoPivo_;
            tipo = this.Game_.PecaAtiva_(1).Tipo_;
            

            forma_v = v_unit;
            forma_f = f_unit;
            if size(forma, 1) > 1
                for f = 2:size(forma, 1)
                    forma_v = [forma_v; v_unit + forma(f, :)];
                    forma_f = [forma_f; f_unit + (f-1)*8];
                end
            end


            pos_futura = this.Game_.PecaAtiva_(1).GetPosFutura();
            patch(this.Eixos_, 'Vertices', forma_v + pos_futura - 1, 'Faces', forma_f, ...
                'FaceColor', [0.5, 0.5, 0.5], 'FaceAlpha', 0.50);
                

            patch(this.Eixos_, 'Vertices', forma_v + pos - 1, 'Faces', forma_f, ...
                'FaceColor', cores(tipo, :), 'FaceAlpha', 0.75); 

                drawnow;
        end

       function DrawGame(this)
            cla(this.Eixos_);
    
            this.DrawBlocosPosicionados();
            this.DrawPecaAtiva();
            
            if ~isempty(this.EixosAux_) && isgraphics(this.EixosAux_)
                if this.Game_.GameState_ ~= GameState.GameOver
                    cla(this.EixosAux_);
                    this.DrawProximasPecas();
                end
            end
        end

        function DrawProximasPecas(this)
            v_unit = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
            f_unit = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            cores = [0 1 1; 0 1 0; 1 1 0; 0 0 1; 1 0 1; 1 0.5 0; 0.5 0 0.5; 1 0 0];
            
            posicoes_base = [10, 6, 2];
            
            for i = 2:4
                if i <= numel(this.Game_.PecaAtiva_)
                    forma = this.Game_.PecaAtiva_(i).Shape_;
                    tipo = this.Game_.PecaAtiva_(i).Tipo_;
                    z_offset = posicoes_base(i-1);
                    
                    forma_v = v_unit;
                    forma_f = f_unit;
                    if size(forma, 1) > 1
                        for f = 2:size(forma, 1)
                            forma_v = [forma_v; v_unit + forma(f, :)];
                            forma_f = [forma_f; f_unit + (f-1)*8];
                        end
                    end
                    
                    pos_desenho = [1, 1, z_offset];
                    patch(this.EixosAux_, 'Vertices', forma_v + pos_desenho - 1, 'Faces', forma_f, ...
                        'FaceColor', cores(tipo, :), 'FaceAlpha', 0.75);
                end
            end
            drawnow;
        end

        function drawScore(this)


        end

        function DrawMenu(this)
            cla(this.Eixos_);
            set(this.Eixos_, 'XLim', [0 1], 'YLim', [0 1], 'ZLim', [0 1]);
            opcoes = enumeration('MenuOpt');
            pos = [0.8, 0.6, 0.4, 0.2];
            for i = 1:4
                if opcoes(i) == this.Game_.MenuOpt_
                    texto = sprintf('> %s <', char(opcoes(i)));
                else
                    texto = char(opcoes(i));
                end
                text(0.45, pos(i), texto, 'FontSize', 30, 'Parent', this.Eixos_, ...
                    'Units', 'normalized', 'HorizontalAlignment', 'center');
            end
            drawnow;
        end

        function DrawPauseMenu(this)
            cla(this.Eixos_);
            set(this.Eixos_, 'XLim', [0 1], 'YLim', [0 1], 'ZLim', [0 1]);
            opcoes = enumeration('PauseMenuOpt');
            pos = [0.8, 0.6, 0.4, 0.2];
            for i = 1:3
                if opcoes(i) == this.Game_.PauseMenuOpt_
                    texto = sprintf('> %s <', char(opcoes(i)));
                else
                    texto = char(opcoes(i));
                end
                text(0.45, pos(i), texto, 'FontSize', 30, 'Parent', this.Eixos_, ...
                    'Units', 'normalized', 'HorizontalAlignment', 'center');
            end
            drawnow;
        end

        function DrawSettings(this)
            cla(this.Eixos_);
            set(this.Eixos_, 'XLim', [0 1], 'YLim', [0 1], 'ZLim', [0 1]);
            
            text(0.5, 0.90, 'SETTINGS', 'FontSize', 50, 'Parent', this.Eixos_, ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            
            if this.Game_.SettingsOpt_ == SettingsOpt.Width
                texto_width = sprintf('> Width: %d <', this.Game_.SettingsWidth_);
                color_width = [1 0.5 0];
            else
                texto_width = sprintf('Width: %d', this.Game_.SettingsWidth_);
                color_width = [0 0 0];
            end
            text(0.5, 0.75, texto_width, 'FontSize', 32, 'Parent', this.Eixos_, ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', 'Color', color_width, 'FontWeight', 'bold');

            if this.Game_.SettingsWidth_ == 10
                aviso_width = '(Max: 10)';
            elseif this.Game_.SettingsWidth_ == 5
                aviso_width = '(Min: 5)';
            else
                aviso_width = '';
            end
            text(0.5, 0.69, aviso_width, 'FontSize', 14, 'Parent', this.Eixos_, ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', 'Color', [0.6 0.6 0.6]);
            
            if this.Game_.SettingsOpt_ == SettingsOpt.Height
                texto_height = sprintf('> Height: %d <', this.Game_.SettingsHeight_);
                color_height = [1 0.5 0];
            else
                texto_height = sprintf('Height: %d', this.Game_.SettingsHeight_);
                color_height = [0 0 0];
            end
            text(0.5, 0.60, texto_height, 'FontSize', 32, 'Parent', this.Eixos_, ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', 'Color', color_height, 'FontWeight', 'bold');

            if this.Game_.SettingsHeight_ == 20
                aviso_height = '(Max: 20)';
            elseif this.Game_.SettingsHeight_ == 10
                aviso_height = '(Min: 10)';
            else
                aviso_height = '';
            end
            text(0.5, 0.54, aviso_height, 'FontSize', 14, 'Parent', this.Eixos_, ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', 'Color', [0.6 0.6 0.6]);

            dificuldades = {'Easy', 'Normal', 'Hard'};
            if this.Game_.SettingsOpt_ == SettingsOpt.Difficulty
                texto_difficulty = sprintf('> Difficulty: %s <', dificuldades{this.Game_.SettingsDifficulty_});
                color_difficulty = [1 0.5 0];
            else
                texto_difficulty = sprintf('Difficulty: %s', dificuldades{this.Game_.SettingsDifficulty_});
                color_difficulty = [0 0 0];
            end
            text(0.5, 0.45, texto_difficulty, 'FontSize', 32, 'Parent', this.Eixos_, ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', 'Color', color_difficulty, 'FontWeight', 'bold');
            

            if this.Game_.SettingsToggledMusic_
                str_music = 'ON';
            else
                str_music = 'OFF';
            end

            if this.Game_.SettingsOpt_ == SettingsOpt.Music
                texto_music = sprintf('> Music: %s <', str_music);
                color_music = [1 0.5 0];
            else
                texto_music = sprintf('Sound: %s', str_music);
                color_music = [0 0 0];
            end
            text(0.5, 0.32, texto_music, 'FontSize', 32, 'Parent', this.Eixos_, ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', 'Color', color_music, 'FontWeight', 'bold');


            if this.Game_.SettingsToggledSoundEffects_
                str_soundeffects = 'ON';
            else
                str_soundeffects = 'OFF';
            end

            if this.Game_.SettingsOpt_ == SettingsOpt.Sound_Effects
                texto_soundeffects = sprintf('> Sound Effects: %s <', str_soundeffects);
                color_soundeffects = [1 0.5 0];
            else
                texto_soundeffects = sprintf('Sound Effects: %s', str_soundeffects);
                color_soundeffects = [0 0 0];
            end
            text(0.5, 0.20, texto_soundeffects, 'FontSize', 32, 'Parent', this.Eixos_, ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', 'Color', color_soundeffects, 'FontWeight', 'bold');
            
            text(0.5, 0.08, 'Use ↑↓ to navigate | ← → to adjust | ENTER to confirm', 'FontSize', 14, ...
                'Parent', this.Eixos_, 'Units', 'normalized', 'HorizontalAlignment', 'center', ...
                'Color', [0.5 0.5 0.5]);
            
            drawnow;
        end

        function DrawWaitTime(this)
            if isempty(this.Txt_) || ~all(isgraphics(this.Txt_))
                this.Txt_(1) = text(0.5, 0.5, '', ...
                'Parent', this.Eixos_, ...
                'Units', 'normalized', ...           
                'HorizontalAlignment', 'center', ... 
                'VerticalAlignment', 'middle', ...   
                'FontSize', 105, ...                 
                'FontWeight', 'bold', ...            
                'Color', [0 0 0], ...                
                'Clipping', 'off');
            this.Txt_(2) = text(0.5, 0.5, '', ...
                'Parent', this.Eixos_, ...
                'Units', 'normalized', ...           
                'HorizontalAlignment', 'center', ... 
                'VerticalAlignment', 'middle', ...   
                'FontSize', 100, ...                 
                'FontWeight', 'bold', ...            
                'Color', [1 0 0], ...                
                'Clipping', 'off');
            end
            if this.Game_.WaitTime_ <= 0
                set(this.Txt_, 'Visible', 'off');
                return;
            else
                str = num2str(this.Game_.WaitTime_);
                set(this.Txt_, 'Visible', 'on', 'String', str);
                this.Game_.WaitTime_ = this.Game_.WaitTime_ - 1;
            end
        end

        function DrawGameOver(this)
            cla(this.Eixos_);
            this.DrawBlocosPosicionados();
            this.DrawPecaAtiva();
            

            if ~isempty(this.EixosAux_) && isgraphics(this.EixosAux_)
                delete(this.EixosAux_);
            end
            

            this.EixosAux_ = axes('Parent', this.Fig_, 'Position', [0 0 1 1]);
            set(this.EixosAux_, 'XLim', [0 1], 'YLim', [0 1]);
            axis(this.EixosAux_, 'off');
            
            uistack(this.EixosAux_, 'top');
            
            rectangle(this.EixosAux_, 'Position', [0, 0, 1, 1], ...
                'FaceColor', [0, 0, 0], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
            

            text(0.5, 0.75, 'GAME OVER!', ...
                'Parent', this.EixosAux_, ...
                'FontSize', 60, ...
                'FontWeight', 'bold', ...
                'Color', [1 0 0], ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle');
            

            scoreText = sprintf('Pontuação Final: %d', this.Game_.Score_);
            text(0.5, 0.55, scoreText, ...
                'Parent', this.EixosAux_, ...
                'FontSize', 40, ...
                'FontWeight', 'bold', ...
                'Color', [1 1 0], ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle');
            

            text(0.5, 0.35, 'Pressione ENTER para voltar ao Menu', ...
                'Parent', this.EixosAux_, ...
                'FontSize', 18, ...
                'Color', [1 1 1], ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle');
            
            text(0.5, 0.25, 'ou ESC para sair', ...
                'Parent', this.EixosAux_, ...
                'FontSize', 16, ...
                'Color', [0.8 0.8 0.8], ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle');
            
            drawnow;
        end
    end
end