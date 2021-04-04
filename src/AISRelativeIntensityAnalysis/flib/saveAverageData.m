function saveAverageData( data, filename )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if data.nSeries > 1
    error('can only save one series')
end

for idx_channel = 1:data.nChannels
    
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
        fprintf(fileID,'%10.8s\t%10.8s\t%10.8s\t%10.8s\n',...
            'length', 'mean', 'stdev', 'sem');
        for idx_line = 1:data.signalLengths
            fprintf(fileID, '%10.8f\t%10.8f\t%10.8f\t%10.8f\n', ...
                data.XY.x(idx_line), ...
                data.XY.y(idx_line, idx_channel), ...
                data.standarddev(idx_line, idx_channel), ...
                data.sem(idx_line, idx_channel));
        end
    catch exception
        fclose(fileID);
    end
    fclose(fileID);
end



end

