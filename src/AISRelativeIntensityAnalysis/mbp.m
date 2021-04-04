clear
addpath flib/

%% Load data

% This cell is modified new since last version, Gustav Risting <130105>

inputdirectory = './input/';
plot_channel = 1;

filenames = readInputDir(inputdirectory);

data = loadXYYYData('input/data.txt');
dataraw = data;

figure(1)
clf
hold on
plotXYdataChannel(data, plot_channel)
title('raw')

%% Smooth data
data = smoothdata(data, 1);
datasmoothed = data;

figure(2)
clf
hold on
plotXYdataChannel(data, plot_channel)
title('smooth')

%% normalise data

data = normaliseY(data);
data = normaliseX(data);

datanormalised = data;

figure(3)
clf
hold on
plotXYdataChannel(data, plot_channel)
title('normalised')

 %% interpolate data
 
xi = linspace(.1, 1-1e-5, 50);
xi = linspace(.01, 1, 30);
data = interpolateData(data, xi);
datainterpolated = data;

saveData(datainterpolated, 'output/interpolated')

figure(4)
clf
hold on
plotXYdataChannel(data, plot_channel)
title('interpolated')

%% average data

data = averageData(data);

% plotXYdataChannel(data, 1, 'LineWidth', 3)
% errorbar(data.XY.x, data.XY.y(:, plot_channel), data.sem(:, plot_channel))

sub_set_for_plotting = 1:1:length(data.XY.x);
errorbar(data.XY.x(sub_set_for_plotting), ...
    data.XY.y(sub_set_for_plotting, plot_channel), ...
    data.sem(sub_set_for_plotting, plot_channel))

%% save data
mkdir('output')
saveAverageData(data, 'output/ollemig')




