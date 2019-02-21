function false_row = detectFalseRow(original_array, compare_array, row)
% remove false row value
false_row = [];
for k = 1:length(row)
   if compare_array == original_array(row(k),:)
      continue
   else
      false_row = [false_row, k];
   end
end