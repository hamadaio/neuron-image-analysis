function plotXYdataChannel( data, idx_channel, varargin )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


axh = gca;
colors = hsv(data.nSeries);

for idx_series = 1:data.nSeries
    if numel(varargin) > 0
        plot(axh, ...
            data.XY(idx_series).x, ...
            data.XY(idx_series).y(:, idx_channel),'o', ...
            'Color', colors(idx_series, :), varargin{:})
    else
        plot(axh, ...
            data.XY(idx_series).x, ...
            data.XY(idx_series).y(:, idx_channel),'o', ...
            'Color', colors(idx_series, :))
    end
end


end

