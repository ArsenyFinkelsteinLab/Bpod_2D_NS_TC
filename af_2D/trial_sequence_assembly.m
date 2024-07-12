function [trial_type_mat,X_positions_mat, Z_positions_mat, trial_seq, trial_seq_reward, first_trial_in_block_seq, current_trial_num_in_block_seq] = trial_sequence_assembly()
global BpodSystem S LickPortPosition;
% first_rewarded=50; %the first_rewarded are always rewarded
% no_or_partial_reward_prob = S.GUI.NoPartialRewardProb; % on this fraction of trials block(in each block, the same position is repeated for MaxSame number), there will be either partial or no reward (with equal probability between partial and no reward)






% Generating positions
X_bin_size=S.GUI.X_radius/((S.GUI.num_bins-1)/2);
Z_bin_size=S.GUI.Z_radius/((S.GUI.num_bins-1)/2);

xz_factor=Z_bin_size/X_bin_size;

X_positions=0;
Z_positions=0;

for i_b=2:1:S.GUI.num_bins
    X_positions(i_b)= X_positions(i_b-1) + X_bin_size;
    Z_positions(i_b)= Z_positions(i_b-1) + X_bin_size; %note that initially we set both X & Z dimensions are the same
end
X_positions_mat=repmat(X_positions,S.GUI.num_bins,1) - mean(X_positions);
Z_positions_mat=repmat(Z_positions,S.GUI.num_bins,1)' - mean(Z_positions);

% X_positions = S.GUI.X_center - S.GUI.X_radius; %initialize
% Z_positions = S.GUI.Z_center - S.GUI.Z_radius; %initialize
% for i_b=2:1:S.GUI.num_bins
%     X_positions(i_b)= X_positions(i_b-1) + X_bin_size;
%     Z_positions(i_b)= Z_positions(i_b-1) + Z_bin_size;
% end
% % X_positions=X_positions-S.GUI.X_center;
% % Z_positions=Z_positions-S.GUI.Z_center;
% X_positions_mat=repmat(X_positions,S.GUI.num_bins,1);
% min_X_positions_mat = min(X_positions_mat(:));
% X_positions_mat = X_positions_mat - min_X_positions_mat;
%
% Z_positions_mat=repmat(Z_positions,S.GUI.num_bins,1)';
% min_Z_positions_mat = min(Z_positions_mat(:));
% Z_positions_mat = Z_positions_mat - min_Z_positions_mat;


% Create rotation matrix
theta = -S.GUI.RollDeg; % to rotate 90 counterclockwise
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% Rotate your point(s)


for i_pos = 1:1:numel(Z_positions_mat(:))
    point = [X_positions_mat(i_pos);Z_positions_mat(i_pos)];
    rotpoint = R*point;
    X_positions_mat(i_pos) = rotpoint(1);
    Z_positions_mat(i_pos) = rotpoint(2);
    
end

X_positions_mat =X_positions_mat + S.GUI.X_center;
Z_positions_mat = Z_positions_mat*xz_factor + S.GUI.Z_center;

% figure
% scatter(X_positions_mat(:),Z_positions_mat(:))


MaxSame = S.GUI.MaxSame;
trial_type_mat = ones(S.GUI.num_bins,S.GUI.num_bins); trial_type_mat(find(trial_type_mat==1))=find(trial_type_mat==1);

% The pseudorandom trial seq is repeared with a periodicity of num_positions*MaxSame
num_positions = numel(trial_type_mat(:));
num_blocks=20; %is unrealistically long, just to have a long sequence
trial_seq=[];
first_trial_in_block_seq=[];
trial_seq_reward=[];
current_trial_num_in_block_seq=[];

seq_block = trial_seq_randperm_max_separation(num_positions);

for i=1:1:num_blocks
    seq_block_temp = trial_seq_randperm_max_separation(num_positions);
    while seq_block_temp(1)==seq_block(end)
        seq_block_temp = trial_seq_randperm_max_separation(num_positions);
    end
    seq_block = seq_block_temp;
    for jj = 1:1:numel(seq_block)
        temp = repmat(seq_block(jj),1,MaxSame);
        trial_seq = [trial_seq,temp];
        temp(1:end)=0;
        temp(1)=1;
        first_trial_in_block_seq = [first_trial_in_block_seq,temp];
        current_trial_num_in_block_seq = [current_trial_num_in_block_seq,[1:1:MaxSame]];
        %         temp_reward= repmat(1,1,MaxSame);
        %         for rr=1:1:numel(temp_reward) %rr=2:1:numel(temp_reward-1)
        %             x_prob=rand;
        %             if x_prob<no_or_partial_reward_prob
        %                 temp_reward(rr)=0.5; %that's just the flag, the actual value of a partial reward could be adjusted on-line from the GUI
        %                 if x_prob<no_or_partial_reward_prob/2
        %                     temp_reward(rr)=0;
        %                 end
        %             end
        %         end
        %         trial_seq_reward = [trial_seq_reward,temp_reward];
    end
end

% the first trial position is always the one in the center
trial_seq(1:MaxSame) =  trial_type_mat(ceil(S.GUI.num_bins/2),ceil(S.GUI.num_bins/2)); % picking the trial corresponding to lickport position at the center
% the first first_rewarded trials are always fully rewarded
% trial_seq_reward(1:first_rewarded) =1;


