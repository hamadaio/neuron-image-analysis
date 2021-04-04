clear
addpath flib/

%% Load data

% This cell is modified new since last version, Gustav Risting <130105>

inputdirectory = './input/';
plot_channel = 1;

filenames = readInputDir(inputdirectory);

data = loadXYData(filenames);
dataraw = data;

figure(1)
clf
hold on
plotXYdataChannel(data, plot_channel)
title('raw')

%% Smooth data
data = smoothdata(data, 10);  
datasmoothed = data;


% compute maxima
supersmoothdata = smoothdata(data, 5);  %10
for i=1:length(supersmoothdata.XY)
    [m,ind]=max(supersmoothdata.XY(i).y)
    maxima(i,:) = supersmoothdata.XY(i).x(ind);
end
maxima
disp([' maxima mean: '  num2str(mean(maxima))]);
disp(['maxima sem: ' num2str(std(maxima)/sqrt(length(supersmoothdata.XY)))]);



figure(2)
clf
hold on
plotXYdataChannel(data, plot_channel)
title('smooth')
%% Normalize data

data = normaliseY(data);
data = normaliseX(data); 

datanormalised = data;

figure(3)
clf
hold on
plotXYdataChannel(data, plot_channel)
title('normalised')
%% Interpolate data

xi = linspace(.01, 1-1e-5, 25);
% xi = linspace(.1, 1, 50);
data = interpolateData(data, xi);
datainterpolated = data;
saveData(datainterpolated, 'raw_interpolated')

figure(4)
clf
hold on
plotXYdataChannel(data, plot_channel)
title('interpolated')
%% Average data

data = averageData(data);
% plotXYdataChannel(data, 1, 'LineWidth', 3)
errorbar(data.XY.x, data.XY.y(:, plot_channel), data.sem(:, plot_channel))


%% Save data
% mkdir('output')
saveAverageData(data, 'output/kalle')



