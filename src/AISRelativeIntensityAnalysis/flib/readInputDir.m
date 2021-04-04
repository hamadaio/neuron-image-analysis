function filenames = readInputDir( inputdirectory )
%readInputDir returs a list of possible input files in the input directory
%   filenames = readInputDir( inputdirectory )
%   
%   INPUT:
%    - inputdirectory, string, path to a directory
%   OUTPUT:
%    - filenames, cell array of strings, containing all filenames within
%      the input directory that does not start with a '.'
%
%   Gustav Risting, 130105


files = dir(inputdirectory);
filenames = cell(size(files));
idx_last = 0;
for idx_file = 1:numel(files)
    fname = files(idx_file).name;
    switch fname(1)
        case '.'
        otherwise 
            idx_last = idx_last + 1;
            filenames{idx_last} = [inputdirectory fname];
    end
end

filenames = filenames(1:idx_last);

end

