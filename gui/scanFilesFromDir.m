function [out_file_list, files_directory] = scanFilesFromDir(dir_path)
%SCANFILES Summary of this function goes here
%   Detailed explanation goes here

dirobj = dir(dir_path);
convert2table = struct2table(dirobj);

pre_files_table = {};

for i = 1:size(convert2table)
   name = convert2table.name(i);
   if convert2table.isdir(i) == 0 && ...
         strcmp(name{1}(1),'.') == 0 && ...
         strcmp(name{1}(1),'_') == 0
      pre_files_table = vertcat(pre_files_table,name);
   end
end

files_directory = dirobj.folder;
out_file_list = pre_files_table;
end
