classdef Renderer < handle
    properties
        Game_;
        Fig_;
        Eixos_;
    end

    methods 
        function this = Renderer(game)
            this.Game_ = game;

            this.Fig_ = [];
            this.Eixos_ = [];
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
                                'FaceColor', cores(cor_idx, :), 'FaceAlpha', 0.75);
                        end
                    end
                end
            end
        end

        function DrawPecaAtiva(this)

            v_unit = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
            f_unit = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
            cores = [0 1 1; 0 1 0; 1 1 0; 0 0 1; 1 0 1; 1 0.5 0; 0.5 0 0.5; 1 0 0];
            
            forma = this.Game_.PecaAtiva_.Shape_;
            pos = this.Game_.PecaAtiva_.PosicaoPivo_;
            tipo = this.Game_.PecaAtiva_.Tipo_;
            

            forma_v = v_unit;
            forma_f = f_unit;
            if size(forma, 1) > 1
                for f = 2:size(forma, 1)
                    forma_v = [forma_v; v_unit + forma(f, :)];
                    forma_f = [forma_f; f_unit + (f-1)*8];
                end
            end


            pos_futura = this.Game_.PecaAtiva_.GetPosFutura();
            patch(this.Eixos_, 'Vertices', forma_v + pos_futura - 1, 'Faces', forma_f, ...
                'FaceColor', [0.5, 0.5, 0.5], 'FaceAlpha', 0.50);
                

            patch(this.Eixos_, 'Vertices', forma_v + pos - 1, 'Faces', forma_f, ...
                'FaceColor', cores(tipo, :), 'FaceAlpha', 0.90); 

                drawnow;
        end

       function DrawGame(this)
            cla(this.Eixos_);
    
            this.DrawBlocosPosicionados();
            this.DrawPecaAtiva();
        end

        function DrawPauseMenu(this)
            

        end

    end
end