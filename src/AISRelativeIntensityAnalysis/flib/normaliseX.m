function outdata = normaliseX( indata )
%normaliseX, max(x) = 1
%   outdata = normaliseX( indata )

outdata = indata;

for idx_series = 1:indata.nSeries;
    s = indata.XY(idx_series);
    s.x = 1/ max(s.x) * s.x;
    outdata.XY(idx_series) = s;
end

outdata.processingHistory{end + 1} = 'normalise X';

end

