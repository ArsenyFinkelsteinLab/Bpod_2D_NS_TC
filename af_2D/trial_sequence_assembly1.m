function [trial_type_mat,X_positions_mat, Z_positions_mat, trial_seq, trial_seq_reward, first_trial_in_block_seq] = trial_sequence_assembly()
global BpodSystem S LickPortPosition;
% first_rewarded=50; %the first_rewarded are always rewarded
% no_or_partial_reward_prob = S.GUI.NoPartialRewardProb; % on this fraction of trials block(in each block, the same position is repeated for MaxSame number), there will be either partial or no reward (with equal probability between partial and no reward)

% Generating positions
X_bin_size=S.GUI.X_radius/((S.GUI.num_bins-1)/2);
Z_bin_size=S.GUI.Z_radius/((S.GUI.num_bins-1)/2);
X_positions = S.GUI.X_center - S.GUI.X_radius; %initialize
Z_positions = S.GUI.Z_center - S.GUI.Z_radius; %initialize
for i_b=2:1:S.GUI.num_bins
    X_positions(i_b)= X_positions(i_b-1) + X_bin_size;
    Z_positions(i_b)= Z_positions(i_b-1) + Z_bin_size;
end
% X_positions=X_positions-S.GUI.X_center;
% Z_positions=Z_positions-S.GUI.Z_center;
X_positions_mat=repmat(X_positions,S.GUI.num_bins,1);
Z_positions_mat=repmat(Z_positions,S.GUI.num_bins,1)';

MaxSame = S.GUI.MaxSame;
trial_type_mat = ones(S.GUI.num_bins,S.GUI.num_bins); trial_type_mat(find(trial_type_mat==1))=find(trial_type_mat==1);

% The pseudorandom trial seq is repeared with a periodicity of num_positions*MaxSame
num_positions = numel(trial_type_mat(:));
num_blocks=20; %is unrealistically long, just to have a long sequence
trial_seq=[];
first_trial_in_block_seq=[];
trial_seq_reward=[];
for i=1:1:num_blocks
    seq_block=randperm(num_positions);
    for jj = 1:1:numel(seq_block)
        temp = repmat(seq_block(jj),1,MaxSame);
        trial_seq = [trial_seq,temp];
        temp(1:end)=0;
        temp(1)=1;
        first_trial_in_block_seq = [first_trial_in_block_seq,temp];
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


