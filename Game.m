classdef Game < handle
    properties
        Height_;
        Width_;
        Map_;

        PecaAtiva_;

        Clock_;

    
        PosFutura_;
        Renderer_;
        InputHandler_;

        EmJogo_; %bool
    end

    methods
        function this = Game(height, width)
            this.Height_ = height;
            this.Width_ = width;  
            this.Map_ = zeros(this.Width_, this.Width_, this.Height_+2);
            this.EmJogo_ = true;
            
            this.InputHandler_ = InputHandler(this);

            this.Renderer_ = Renderer(this);

            this.ConfigurarInterface();

            % Criar a primeira peça
            this.PecaAtiva_ = PecaAtiva([3, 3, this.Height_], this);

            t_antigos = timerfind;
            if ~isempty(t_antigos)
                stop(t_antigos);
                delete(t_antigos);
            end

            this.Clock_ = timer('ExecutionMode', 'fixedRate', 'Period',...
                1, 'TimerFcn', @(src, event) this.ClockTick());

            start(this.Clock_);

            
            
        end
    
        function ConfigurarInterface(this)
            this.Renderer_.Fig_ = figure('Name', 'Tetris', ...
                                'KeyPressFcn', @(src, event) this.InputHandler_.TecladoCallback(src, event));
            this.Renderer_.Eixos_ = axes('Parent', this.Renderer_.Fig_);
            axis(this.Renderer_.Eixos_, 'equal');
            grid(this.Renderer_.Eixos_, 'on');
            view(this.Renderer_.Eixos_, 3);
            

            xlim(this.Renderer_.Eixos_, [0, this.Width_]); xlabel('x'); xticks(0:this.Width_);
            ylim(this.Renderer_.Eixos_, [0, this.Width_]); ylabel('y'); yticks(0:this.Width_);
            zlim(this.Renderer_.Eixos_, [0, this.Height_]); zlabel('z'); zticks(0:this.Height_);
     
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
            this.Renderer_.Draw();
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

        function ClockTick(this)
            if ~this.EmJogo_
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
            this.Renderer_.Draw();
        end

        function FreeFall(this)
            if ~this.EmJogo_
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


        function GameOver(this)
            this.EmJogo_ = false;
            stop(this.Clock_);
            title(this.Renderer_.Eixos_, 'GAME OVER!', 'FontSize', 20, 'Color', 'r');
        end


        function delete(this)
            t_antigos = timerfind;            
            if isvalid(this.Clock_)
                stop(this.Clock_);
                delete(this.Clock_);
            end
        end

    end
end