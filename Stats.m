classdef Stats < handle
    properties
        Game_;

        Rankings_;
        nRanks_;
        SavedGames_;
        nSavedGames_;


        SavedGamesPath_;
        RankingsPath_;
    end

    methods
        function this = Stats(pathSaves, pathRanks, game)
            this.Game_ = game;

            this.SavedGamesPath_ = pathSaves;
            this.RankingsPath_ = pathRanks;

            if isfile(this.RankingsPath_)
                this.Rankings_ = this.getRankings();
                
                if isempty(fieldnames(this.Rankings_))
                    this.nRanks_ = 0;
                else
                    this.nRanks_ = length(this.Rankings_);
                end
            else
                this.Rankings_ = struct();
                this.nRanks_ = 0;
            end

            this.SavedGames_ = struct();
            this.nSavedGames_ = 0;

        end

        function Rankings = getRankings(this)
            temp = load(this.RankingsPath_);
            Rankings = temp.Rankings_;
        end

        function storeRankings(this)

            [pasta_destino, ~, ~] = fileparts(this.RankingsPath_);


            if ~isempty(pasta_destino) && ~exist(pasta_destino, 'dir')
                mkdir(pasta_destino);
            end


            Rankings_ = this.Rankings_;
            
            save(this.RankingsPath_, 'Rankings_');
        end

        function addToRankings(this)
            n = this.nRanks_ + 1;
            
            this.Rankings_(n).name = this.Game_.PlayerName_;
            this.Rankings_(n).score = this.Game_.Score_;
            this.Rankings_(n).Difficulty = this.Game_.SettingsDifficulty_;

            this.nRanks_ = this.nRanks_ + 1;
        end
    end
end