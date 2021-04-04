function outdata = normaliseY( indata )
%normaliseY, max(y) = 1
%   outdata = normaliseY( indata )

outdata = indata;

%smootheddata = smoothdata(indata,100);
smootheddata = indata;

for idx_series = 1:indata.nSeries;
    s = indata.XY(idx_series);
    for idx_channel = 1:indata.nChannels(idx_series)
        yt = 1 / max( smootheddata.XY(idx_series).y(:,idx_channel)     ) * s.y(:,idx_channel);
        s.y(:,idx_channel) = yt;
    end
    outdata.XY(idx_series) = s;
end

outdata.processingHistory{end + 1} = 'normalise Y';

end

