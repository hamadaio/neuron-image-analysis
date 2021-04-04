function outdata = averageData( indata )
%averageData
%   outdata = averageData( indata )

if max(indata.signalLengths) > min(indata.signalLengths)
    error('All signals must be of equal length to be able to do average')
else
    signalLength = indata.signalLengths(1);
end


nChannels = min(indata.nChannels);
if nChannels < max(indata.nChannels)
    warning(['will not use more than %d channels though some '...
        'series have up to %d channels'], nChannels, max(nChannelList))
end

outdata = indata;

s.x = indata.XY(1).x;
s.y = zeros(signalLength, nChannels);
outdata.standarddev = zeros(signalLength, nChannels);
outdata.sem = zeros(signalLength, nChannels);
outdata.nChannels = nChannels;

yt = zeros(signalLength, indata.nSeries);

for idx_channel = 1:nChannels
    for idx_series = 1:indata.nSeries
        yt(:, idx_series) = indata.XY(idx_series).y(:,idx_channel);
    end
    s.y(:,idx_channel) = mean(yt, 2);
    outdata.standarddev(:,idx_channel) = std(yt,[],2);
    outdata.sem(:,idx_channel) = ...
        outdata.standarddev(:, idx_channel) / sqrt(outdata.nSeries);
end

outdata.XY = s;
outdata.nSeries = 1;
outdata.signalLengths = outdata.signalLengths(1);
outdata.processingHistory{end + 1} = 'average';


end

