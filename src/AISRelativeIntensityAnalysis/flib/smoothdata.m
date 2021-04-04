function outdata = smoothdata( indata, binsize )
%smoothdata 
%   outdata = smoothdata( indata, binsize )

onesX = ones(binsize, 1);

outdata = indata;

for idx_series = 1:indata.nSeries;
    s = indata.XY(idx_series);
    for idx_channel = 1:indata.nChannels(idx_series)
        yt = conv(s.y(:,idx_channel), onesX,'same');
        s.y(:,idx_channel) = yt;
    end
    outdata.XY(idx_series) = s;
end

outdata.processingHistory{end+1} = sprintf('smooth[%d]', binsize);

end

