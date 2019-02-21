function [total, lock_pairs] = mix_copyright(stimuli_num)

total = [];

% non-lock pairs
for i = 1:stimuli_num
   for k = 1:stimuli_num
      if i == k || abs(i-k) == 1
         continue
      end
      total = [total; i,k];
   end
end

sub_total = total;

for i = 1:(length(total)/2)
   column = sub_total(1,:);
   flip_column = flip(column);
   remove_row = [];
   
   whichColumn = round(rand());
   switch whichColumn
      case 0
         remove_row = find(total == flip_column);
         over_row = remove_row > length(total);
         remove_row(over_row) = [];
         false_row = detectFalseRow(total, flip_column, remove_row);
      case 1
         remove_row = find(total == column);
         over_row = remove_row > length(total);
         remove_row(over_row) = [];
         false_row = detectFalseRow(total, column, remove_row);
   end
   
   remove_row(false_row) = [];
   total(remove_row,:) = [];
   
   remove_row = find(sub_total == flip_column);
   over_row = remove_row > length(sub_total);
   remove_row(over_row) = [];
   false_row = detectFalseRow(sub_total, flip_column, remove_row);
   remove_row(false_row) = [];
   sub_total(remove_row,:) = [];
   sub_total(1,:) = [];
end

lock_pairs = [];

% lock pairs
for i = 1:2:stimuli_num
   which_order = round(rand());
   switch which_order
      case 0
         lock_pairs = [lock_pairs; i, i+1];
      case 1
         lock_pairs = [lock_pairs; i+1, i];
   end
end