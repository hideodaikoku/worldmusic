function total = mix_worldmusic(stimuli_num)

total = [];
for i = 1:stimuli_num
   for k = 1:stimuli_num
      if i == k
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
