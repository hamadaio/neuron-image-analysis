function data = loadXYYYData( filepath )
%loadData loads XYData from files specified in filepaths
%   data = loadXYYYData( filepaths )
%
% INPUT:
%  filepath: string with a filepath
%
%    file format
%      [xvals, yvals1, yvals2, yvals3, yvals4 ... ]
%
%  properties of input file:
%   first column of data will be used for x values
%   each following column will be treated as its own 1-channel y series
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
% Gustav Risting, 130612


try
    rawdata = load(filepath);
catch exception
    fprintf('Caught an error on loading %s\n', filepath)
    rethrow(exception)
end

x = rawdata(:,1);
y = rawdata(:,2:end);

nChannels = 1;
nSeries = size(y, 2);

data.name = '';
data.processingHistory = {'rawdata'};
data.nChannels = uint16(zeros(nSeries, 1));
data.nSeries = nSeries;
data.signalLengths = uint32(zeros(nSeries, 1));
data.fnames = {filepath};


for idx_series = 1:nSeries
    
    s.x = x;
    s.y = y(:, idx_series);
    data.nChannels(idx_series) = nChannels;
    data.signalLengths(idx_series) = size(s.x,1);
    data.XY(idx_series) = s;
end



end

