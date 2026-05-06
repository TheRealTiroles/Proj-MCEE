classdef PecaAtiva < handle
    
    properties
        Shape_;
        Tipo_;
        PosicaoPivo_;

        Game_;
    end
    
    methods
        
        function this = PecaAtiva(posicao_inicial, game)
            
            this.Game_ = game;

            this.GerarPecaAleatoria();
            
 
            if nargin > 0
                this.PosicaoPivo_ = posicao_inicial;
            else
                this.PosicaoPivo_ = [3, 3, 10]; 
            end
        end
        
        
        function MoverPara(this, nova_posicao)
          
            this.PosicaoPivo_ = nova_posicao;
        end
        
        
        function GerarPecaAleatoria(this)
            
            this.Tipo_ = randi(8);
            
            switch this.Tipo_
                case 1
                    this.Shape_ = [0 0 0];
                case 2
                    this.Shape_ = [0 0 0
                                 0 0 1];
                case 3
                    this.Shape_ = [0 0 0
                                 0 1 0];
                case 4
                    this.Shape_ = [0 0 0
                                 1 0 0];
                case 5
                    this.Shape_ = [0 0 0
                                 0 0 1
                                 0 0 2];
                case 6
                    this.Shape_ = [0 0 0
                                 0 1 0
                                 0 2 0];
                case 7
                    this.Shape_ = [0 0 0
                                 1 0 0
                                 2 0 0];
                case 8
                    this.Shape_ = [0 0 0
                                 0 0 1
                                 0 1 0
                                 0 1 1
                                 1 0 0
                                 1 0 1
                                 1 1 0
                                 1 1 1];
            end
        end

        function PosFutura = GetPosFutura(this)
            map = this.Game_.Map_;
            shape = this.Shape_;
            pos_pivo = this.PosicaoPivo_;
            h_max = this.Game_.Height_;
            
            h_poss = 0;
            for n = 1:size(shape, 1)
                bloco = shape(n, :) + pos_pivo;
                
                for k = bloco(3)-1:-1:1
                    if map(bloco(1), bloco(2), k) ~= 0
                        if k+1 > h_poss
                            h_poss = k;
                        end
                        break;
                    end
                end
            end
            PosFutura = pos_pivo + [0, 0, h_poss + 1 - pos_pivo(3)];
        end
    end
end