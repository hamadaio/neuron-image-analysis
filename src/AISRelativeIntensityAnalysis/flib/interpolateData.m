function outdata = interpolateData( indata, interpolationPts)
%interpolateData 
%   outdata = interpolateData( indata, interpolationPts)

outdata = indata;

for idx_series = 1:indata.nSeries;
    s_in = indata.XY(idx_series);
    s.x = interpolationPts;
    s.y = zeros(numel(interpolationPts), indata.nChannels(idx_series));
    for idx_channel = 1:indata.nChannels(idx_series)
        
        yt = interp1(...
            s_in.x, ...
            s_in.y(:,idx_channel), ...
            interpolationPts);
        s.y(:,idx_channel) = yt;
    end
    outdata.XY(idx_series) = s;
end

outdata.signalLengths = ...
    ones(outdata.nSeries, 1) * numel(interpolationPts);
outdata.processingHistory{end + 1} = sprintf(...
    'interpolation at %d pts', numel(interpolationPts));

end

