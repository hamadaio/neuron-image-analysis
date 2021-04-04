function [outdata, AL] = normaliseX_v2( indata )
%normaliseX, max(x) = 1
%   outdata = normaliseX( indata )

outdata = indata;
ENDS = nan(1,indata.nSeries);
for idx_series = 1:indata.nSeries;
    s = indata.XY(idx_series);
    ENDS(idx_series) = s.x(end);
end

AL = mean(ENDS);

for idx_series = 1:indata.nSeries;
    s = indata.XY(idx_series);
    s.x = 1/ max(s.x) * s.x*mean(ENDS);
    outdata.XY(idx_series) = s;
end

outdata.processingHistory{end + 1} = 'normalise X';

end

