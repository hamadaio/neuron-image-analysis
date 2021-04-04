function data = loadXYData( filepaths )
%loadData loads XYData from files specified in filepaths
%   data = loadXYData( filepaths )
%
% INPUT:
%  filepaths: cellarray with filepaths
%
%  properties of input files:
%   first column of data will be used for x values
%   each following column will be treated as its own y channel
%
% OUTPUT:
%  data struct with the following fields:
%   .name, an arbitrary name
%   .processingHistory, a cell array of strings describing the processing
%    history
%   .nChannels, an array which tells the number of channels within each
%    series (REMEMBER TO UPDATE)
%   .nSeries, the number of series (REMEMBER TO UPDATE)
%   .fnames, a cell array of strings, each filename that was loaded
%   .XY an array of structs with the following fields:
%     .x a one dimensional array of x values
%     .y a x by nChannels(idx) array of corresponding y values at different
%      channels
%
% Gustav Risting, 121226

data.name = '';
data.processingHistory = {'rawdata'};
data.nChannels = uint16(zeros(numel(filepaths), 1));
data.nSeries = numel(filepaths);
data.signalLengths = uint32(zeros(numel(filepaths), 1));
data.fnames = filepaths;


for idx_file = 1:numel(filepaths)
    fname = filepaths{idx_file};
    try 
        rawdata = load(fname);
    catch exception
        fprintf('Caught an error on loading %s\n', fname)
        rethrow(exception)
    end
    s.x = rawdata(:,1);
    s.y = rawdata(:,2:end);
    data.nChannels(idx_file) = size(s.y, 2);
    data.signalLengths(idx_file) = size(s.x,1);
    data.XY(idx_file) = s;
end



end

