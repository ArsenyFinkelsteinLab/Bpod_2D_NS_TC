function [seq_block] = trial_seq_randperm_max_separation(num_positions)

possible_pos = 1:1:num_positions;
seq_block_L=possible_pos(randperm(floor(num_positions/2)));
if num_positions>9
seq_block_R=possible_pos(randperm(floor(num_positions/2))+floor(num_positions/2));
else
seq_block_R=possible_pos(randperm(ceil(num_positions/2))+floor(num_positions/2));
end

seq_block=[];
for i=1:1:floor(num_positions/2)
    seq_block = [seq_block, seq_block_L(i),seq_block_R(i)];
end

if num_positions<=9
    seq_block = [seq_block,seq_block_R(end)];
end