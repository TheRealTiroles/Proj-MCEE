classdef Renderer < handle
    properties
        Game_;
        Fig_;
        Eixos_;
        EixosAux_;
        Txt_;
    end

    methods 
        function this = Renderer(game)
            this.Game_ = game;

            this.Fig_ = [];
            this.Eixos_ = [];
            this.EixosAux_ = [];
            this.Txt_ = [];
        end

        function ChangeView(this, vista_id)
            switch vista_id
                case 1, view(this.Eixos_, [0 0 this.Game_.Height_]);
                case 2, view(this.Eixos_, [0 this.Game_.Width_ 0]);
                case 3, view(this.Eixos_, [this.Game_.Width_ 0 0]);
                case 4, view(this.Eixos_, 3);
            end
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
            
            cla(this.EixosAux_);
            this.DrawProximasPecas();
        end

        function DrawProximasPecas(this)
            v_unit = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
            f_unit = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            cores = [0 1 1; 0 1 0; 1 1 0; 0 0 1; 1 0 1; 1 0.5 0; 0.5 0 0.5; 1 0 0];
            
            % Posições Z: próxima peça em cima (10), depois (6), depois em baixo (2)
            posicoes_base = [10, 6, 2];
            
            for i = 2:4
                if i <= numel(this.Game_.PecaAtiva_)
                    forma = this.Game_.PecaAtiva_(i).Shape_;
                    tipo = this.Game_.PecaAtiva_(i).Tipo_;
                    z_offset = posicoes_base(i-1);
                    
                    % Construir os vértices da peça
                    forma_v = v_unit;
                    forma_f = f_unit;
                    if size(forma, 1) > 1
                        for f = 2:size(forma, 1)
                            forma_v = [forma_v; v_unit + forma(f, :)];
                            forma_f = [forma_f; f_unit + (f-1)*8];
                        end
                    end
                    
                    % Desenhar a peça com offset de Z
                    pos_desenho = [1, 1, z_offset];
                    patch(this.EixosAux_, 'Vertices', forma_v + pos_desenho - 1, 'Faces', forma_f, ...
                        'FaceColor', cores(tipo, :), 'FaceAlpha', 0.75);
                end
            end
            drawnow;
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


        function DrawWaitTime(this)
            if isempty(this.Txt_) || ~all(isgraphics(this.Txt_))
                this.Txt_(1) = text(0.5, 0.5, '', ...
                'Units', 'normalized', ...           
                'HorizontalAlignment', 'center', ... 
                'VerticalAlignment', 'middle', ...   
                'FontSize', 105, ...                 
                'FontWeight', 'bold', ...            
                'Color', [0 0 0], ...                
                'Clipping', 'off');
            this.Txt_(2) = text(0.5, 0.5, '', ...
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

            title(this.Eixos_, 'GAME OVER!', 'FontSize', 20, 'Color', 'r');

        end


    end
end