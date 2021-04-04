function saveData( data, filename )
%UNTITLED2 Summary of this function goes here

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

%   Detailed explanation goes here

datalengths = zeros(1, data.nSeries);
for idx_series = 1:data.nSeries
    datalengths(idx_series) = numel(data.XY(idx_series).x);
end
if var(datalengths) > 1e-8
    error('all data series must be of equal length')
end

datalength = datalengths(1);
xs = zeros(datalength, data.nSeries);
for idx_series = 1:data.nSeries
    xs(:, idx_series) = data.XY(idx_series).x;
end
if sum( var(xs, 0, 2) > 1e-8 )
    xs
    varxs = var(xs, 0, 2)
    sum( var(xs, 0, 1) > 1e-8 )
    error('all data series must use the same x values')
end
xs = xs(:,1);

if var( double(data.nChannels) ) > 1e-8
    error('all data series must use the same number of channels')
end
nChannels = data.nChannels(1);

for idx_channel = 1:nChannels
    
    filenamech = sprintf('%sch%d', filename, idx_channel);

    fileID = fopen(filenamech, 'w');
    try
        fprintf(fileID, '%s channel %d\n', data.name, idx_channel);
        fprintf(fileID, 'input files:\n');
        for idx_ = 1:numel(data.fnames)
            fprintf(fileID, '  %s\n', data.fnames{idx_});
        end
        fprintf(fileID, 'Processing history:\n');
        for idx_ph = 1:numel(data.processingHistory)
            fprintf(fileID, '  %s\n', data.processingHistory{idx_ph});
        end
        fprintf(fileID,...
            '##########################################################\n');
        % make header
        header = sprintf('%10s','length');
        for idx_series = 1:data.nSeries
            colheader = sprintf('series%d', idx_series);
            header = sprintf('%s\t%10s',header, colheader);
        end
        fprintf(fileID,'%s\n', header);
        for idx_line = 1:data.signalLengths
            linestring = sprintf('%10.8f', xs(idx_line));
            for idx_series = 1:data.nSeries
                linestring = sprintf('%s\t%10.8f',...
                    linestring, data.XY(idx_series).y(idx_line, idx_channel) );
            end
            fprintf(fileID, '%s\n', linestring);
        end
    catch exception
        fclose(fileID);
    end
    fclose(fileID);
end



end

