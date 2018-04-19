function [pathToFile, person] = getFileNameFromIndex(type_of_file, file_index, no_of_indiv)
    cur_index = 0;
    
    if strcmpi(type_of_file, 'training') == 1
        parentPath = 'training\';
    else
        parentPath = 'testing\';
    end
    
    for i = 1:no_of_indiv
        path = sprintf('%s%02d\\', parentPath, i);
        files_in_dir = dir(path);
        no_files_in_dir = size(files_in_dir, 1);
        
        for j = 3:no_files_in_dir
            
            cur_index = cur_index + 1;
            if  cur_index == file_index
                pathToFile = sprintf('%s%02d\\%s', parentPath, i, (files_in_dir(j).name));
                person = i;
                break;
            end
            
        end
    end
end