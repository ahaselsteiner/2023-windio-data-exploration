% This is a Matlab script for exploration of two WindIO datasets:
% * the first dataset containts acceleration data from the Krogmann wind 
% turbine in Bremerhaven.
% * the second dataset contains acceleration data from a Senvion wind 
% turbine in Bremen.
%
% This is a data analysis script and not a polished software.
%
% Figures are in German as WindIO is a German-funded project with German
% as the main working language.



% Complete acceleration file import takes longer than 15 minutes such that the workspace
% has been saved as matlab.mat. The structs msb1 and msb3 contain the time series.
DO_IMPORT_RAW_KROGMANN_MSB = 0;
DO_IMPORT_RAW_KROGMANN_LIDAR = 0;
DO_IMPORT_RAW_SENVION = 0;
DO_PLOT_FFT = 1;

FNAME_LIDAR = "time-series-lidar.csv";
FNAME_MSB_SENVION = "measurement_windio_msb-0002-a_2021-10-21.log";
FNAME_MSB0001 = "time-series-msbi0001.csv";
FNAME_MSB0003 = "time-series-msbi0003.csv";

FIGURE_POSITION =  [10 10 900 600];
GFX_FOLDER = "gfx";
FIRST_LINE_TO_IMPORT_FROM_MSB_FILES = 2;
LAST_LINE_TO_IMPORT_FROM_MSB_FILES = Inf;

% Add files in subfolders to path
% Determine where your m-file's folder is.
folder = fileparts(which( matlab.desktop.editor.getActiveFilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));

if DO_IMPORT_RAW_KROGMANN_MSB == 1
    filename = FNAME_MSB0001;
    disp('Starting to import ' + filename');
    msb1 = importMSBfile(filename, [FIRST_LINE_TO_IMPORT_FROM_MSB_FILES, LAST_LINE_TO_IMPORT_FROM_MSB_FILES]);

    filename = FNAME_MSB0003;
    disp('Starting to import ' + filename');
    msb3 = importMSBfile(filename, [FIRST_LINE_TO_IMPORT_FROM_MSB_FILES, LAST_LINE_TO_IMPORT_FROM_MSB_FILES]);   
else
    load('matlab.mat')
end
if DO_IMPORT_RAW_KROGMANN_LIDAR == 1
    filename = FNAME_LIDAR;
    disp('Starting to import ' + filename');
    lidar = importLidarFile(filename, [2, Inf]);
end

if DO_IMPORT_RAW_SENVION == 1
    fname = FNAME_MSB_SENVION;
    msb_senvion = import_msb_log(fname);
end

% For plotting, set Matlab TimeZones to Berlin time
msb_senvion.time.TimeZone = 'Europe/Berlin';
lidar.time.TimeZone = 'Europe/Berlin';
msb1.time.TimeZone = 'Europe/Berlin';
msb3.time.TimeZone = 'Europe/Berlin';

% Set the zoom in times.
% Set the zooom time for Senvion MSB.
zoomInStartTime = msb_senvion.time(1) + minutes(30);
zoomInEndTime = zoomInStartTime + minutes(1);
msb_senvion.inTime = msb_senvion.time > zoomInStartTime & msb_senvion.time < zoomInEndTime;

% Set the zooom time for Krogmann MSB.
zoomInStartTime = msb1.time(1) + hours(7);
zoomInEndTime = zoomInStartTime + minutes(0.5);
msb1.inTime = msb1.time > zoomInStartTime & msb1.time < zoomInEndTime;
msb3.inTime = msb3.time > zoomInStartTime & msb3.time < zoomInEndTime;

% Set the zoom time for Lidar.
zoomInStartTimeLidar = msb1.time(1) + hours(7);
zoomInEndTimeLidar = zoomInStartTimeLidar + minutes(30);
lidar.inTime = lidar.time > zoomInStartTimeLidar & lidar.time < zoomInEndTimeLidar;


% PLOTTING SENVION
% Senvion turbine: Raw acceleration data
fig = figure('position', FIGURE_POSITION);
t = tiledlayout(2,1);

nexttile
title('Rohdaten: Senvion (MSB0002; ca. 48 Hz)')
hold on
plot(msb_senvion.time, msb_senvion.acc_x, 'DisplayName', 'X')
plot(msb_senvion.time, msb_senvion.acc_y, 'DisplayName', 'Y')
plot(msb_senvion.time, msb_senvion.acc_z, 'DisplayName', 'Z')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')
legend

nexttile
title('Nachbearbeite Daten: Senvion (MSB0002; ca. 48 Hz)')
hold on
msb_senvion.acc_x_no_outliers = msb_senvion.acc_x;
msb_senvion.acc_x_no_outliers(msb_senvion.acc_x > 20) = NaN;
msb_senvion.acc_y_no_outliers = msb_senvion.acc_y;
msb_senvion.acc_y_no_outliers(msb_senvion.acc_y > 20) = NaN;
plot(msb_senvion.time, msb_senvion.acc_x_no_outliers - nanmean(msb_senvion.acc_x_no_outliers), 'DisplayName', 'X')
plot(msb_senvion.time, msb_senvion.acc_y_no_outliers - nanmean(msb_senvion.acc_y_no_outliers), 'DisplayName', 'Y')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')
legend

title(t, 'Senvion-Anlage')
print(GFX_FOLDER + "/" + "senvion",'-dpng')

analyzeTimeIntervals(msb_senvion.time, 30, 'MSB0002', FIGURE_POSITION);
print(GFX_FOLDER + "/" + "MSB0002_time_intervals", '-dpng')

% Senvion turbine: Zoomed in
fig = figure('position', FIGURE_POSITION);
t = tiledlayout(2,1);

nexttile
title('Rohdaten: Senvion (MSB0002; ca. 48 Hz)')
hold on
plot(msb_senvion.time(msb_senvion.inTime), msb_senvion.acc_x(msb_senvion.inTime), 'DisplayName', 'X')
plot(msb_senvion.time(msb_senvion.inTime), msb_senvion.acc_y(msb_senvion.inTime), 'DisplayName', 'Y')
plot(msb_senvion.time(msb_senvion.inTime), msb_senvion.acc_z(msb_senvion.inTime), 'DisplayName', 'Z')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')
legend

nexttile
title('Nachbearbeite Daten: Senvion (MSB0002; ca. 48 Hz)')
hold on
plot(msb_senvion.time(msb_senvion.inTime), msb_senvion.acc_x(msb_senvion.inTime) - nanmean(msb_senvion.acc_x_no_outliers(msb_senvion.inTime)), 'DisplayName', 'X')
plot(msb_senvion.time(msb_senvion.inTime), msb_senvion.acc_y(msb_senvion.inTime) - nanmean(msb_senvion.acc_y_no_outliers(msb_senvion.inTime)), 'DisplayName', 'Y')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')
legend

title(t, 'Senvion-Anlage')
print(GFX_FOLDER + "/" + "senvion_zoomed", '-dpng')

if DO_PLOT_FFT == 1
    calculateFFT(msb_senvion, FIGURE_POSITION);
    title('FFT der Senvion-Anlage (MSB0002)');
    print(GFX_FOLDER + "/" + "senvion_FFT", '-dpng')
end

% PLOTTING LIDAR AT KROGMANN
heights = [lidar.ground_to_lidar_top_in_m, ...% height for ground wind speed
    lidar.set_height_10(1), ...
    lidar.set_height_11(1), ...
    lidar.set_height_9(1), ...
    lidar.set_height_8(1), ...
    lidar.set_height_7(1), ...
    lidar.set_height_6(1), ...
    lidar.set_height_5(1), ...
    lidar.set_height_4(1), ...
    lidar.set_height_3(1), ...
    lidar.set_height_2(1), ...
    lidar.set_height_1(1)];
windSpeeds = [lidar.ground_windspeed, ...
    lidar.horizontal_windspeed_height_10, ...
    lidar.horizontal_windspeed_height_11, ...
    lidar.horizontal_windspeed_height_9, ...
    lidar.horizontal_windspeed_height_8, ...
    lidar.horizontal_windspeed_height_7, ...
    lidar.horizontal_windspeed_height_6, ...
    lidar.horizontal_windspeed_height_5, ...
    lidar.horizontal_windspeed_height_4, ...
    lidar.horizontal_windspeed_height_3, ...
    lidar.horizontal_windspeed_height_2, ...
    lidar.horizontal_windspeed_height_1];
availablePercentWindspeeds = (sum(~isnan(windSpeeds))/ length(lidar.time)) * 100;
meanWindspeeds = nanmean(windSpeeds);
stdWindspeeds = nanstd(windSpeeds);


fig = figure('position', FIGURE_POSITION);
hold on
bar(heights, availablePercentWindspeeds);
box off
xlabel('Messhöhe (m)');
ylabel('Datenverfügbarkeit (%)');
text(0.988 * heights(end), 96, string(lidar.time(1)) + ' bis ' + string(lidar.time(end)), 'HorizontalAlignment', 'right')
print(GFX_FOLDER + "/" + "lidar_availability", '-dpng')


fig = figure('position', FIGURE_POSITION);
hold on
plt = plot(meanWindspeeds, heights, '-o');
plot(meanWindspeeds(3), heights(3), '-ok', 'MarkerFaceColor', '#0072BD');
text(meanWindspeeds(1), heights(1)+5, 'Wetterstation', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
text(meanWindspeeds(3), heights(3)+5, "Referenzhöhe 39 m" + newline + "(in Rohdaten falsch zugeordnet)", 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
box off
xlabel('Durchschnittliche Windgeschwindigkeit (m/s)');
ylabel('Höhe (m)');
text(3.8, 10, string(lidar.time(1)) + ' bis ' + string(lidar.time(end)))
print(GFX_FOLDER + "/" + "lidar_mean_values", '-dpng')

fig = figure('position', FIGURE_POSITION);
hold on
plot(lidar.time, lidar.horizontal_windspeed_height_9, 'DisplayName', string(lidar.set_height_9(1)) + ' m')
plot(lidar.time, lidar.horizontal_windspeed_height_7, 'DisplayName', string(lidar.set_height_7(1)) + ' m')
plot(lidar.time, lidar.horizontal_windspeed_height_5, 'DisplayName', string(lidar.set_height_5(1)) + ' m')
plot(lidar.time, lidar.horizontal_windspeed_height_3, 'DisplayName', string(lidar.set_height_3(1)) + ' m')
plot(lidar.time, lidar.horizontal_windspeed_height_1, 'DisplayName', string(lidar.set_height_1(1)) + ' m')
ylabel('Windgeschwindigkeit (m/s)');
xlabel('Zeit (Berlin-Zeitzone)')
legend
print(GFX_FOLDER + "/" + "lidar", '-dpng')


fig = figure('position', FIGURE_POSITION);
markerSize = 4;
hold on
plot(lidar.time(lidar.inTime), lidar.horizontal_windspeed_height_9(lidar.inTime), '-o', 'MarkerSize', markerSize, 'DisplayName', string(lidar.set_height_9(1)) + ' m')
plot(lidar.time(lidar.inTime), lidar.horizontal_windspeed_height_7(lidar.inTime), '-o', 'MarkerSize', markerSize, 'DisplayName', string(lidar.set_height_7(1)) + ' m')
plot(lidar.time(lidar.inTime), lidar.horizontal_windspeed_height_5(lidar.inTime), '-o', 'MarkerSize', markerSize, 'DisplayName', string(lidar.set_height_5(1)) + ' m')
plot(lidar.time(lidar.inTime), lidar.horizontal_windspeed_height_3(lidar.inTime), '-o', 'MarkerSize', markerSize, 'DisplayName', string(lidar.set_height_3(1)) + ' m')
plot(lidar.time(lidar.inTime), lidar.horizontal_windspeed_height_1(lidar.inTime), '-o', 'MarkerSize', markerSize, 'DisplayName', string(lidar.set_height_1(1)) + ' m')
ylabel('Windgeschwindigkeit (m/s)');
xlabel('Zeit (Berlin-Zeitzone)')
legend
print(GFX_FOLDER + "/" + "lidar_zoomed", '-dpng')

lidar_duration_between_measurements = lidar.time(2:end) - lidar.time(1:end-1);
fig = figure('position', FIGURE_POSITION);
histogram(lidar_duration_between_measurements);
upperXLim =  seconds(60);
xlim([seconds(0) seconds(60)]);
is_outlier = lidar_duration_between_measurements>seconds(60);
is_within_first_mode = lidar_duration_between_measurements<seconds(28);
lidar_duration_first_mode = seconds(mean(lidar_duration_between_measurements(is_within_first_mode)));
lidar_duration_first_mode_std = seconds(std(lidar_duration_between_measurements(is_within_first_mode)));
y_pos = -220;
text(seconds(lidar_duration_first_mode), y_pos, num2str(lidar_duration_first_mode, '%4.1f') + "±" + num2str(lidar_duration_first_mode_std, '%4.1f') + " s", 'HorizontalAlignment', 'Center')
is_within_second_mode = lidar_duration_between_measurements>seconds(28) & lidar_duration_between_measurements<seconds(60);
lidar_duration_second_mode = seconds(mean(lidar_duration_between_measurements(is_within_second_mode)));
lidar_duration_second_mode_std = seconds(std(lidar_duration_between_measurements(is_within_second_mode)));
text(seconds(lidar_duration_second_mode), y_pos, num2str(lidar_duration_second_mode, '%4.1f') + "±" + num2str(lidar_duration_second_mode_std, '%4.1f') + " s", 'HorizontalAlignment', 'Center')
text(seconds(46), y_pos, num2str(sum(is_outlier)) + " Ausreisser > 60 Sekunden")
currentYLim = ylim;
text(0.97 * upperXLim, 0.04 * currentYLim(2), string(lidar.time(1)) + ' bis ' + string(lidar.time(end)), 'HorizontalAlignment', 'right')
xlabel('Zeitlicher Abstand zwischen den Lidar-Messintervallen');
ylabel('Häufigkeit');
print(GFX_FOLDER + "/" + "lidar_messintervalle", '-dpng')

% PLOTTING MSBs AT KROGMANN
% Krogmann turbine: Raw acceleration data
fig = figure('position', FIGURE_POSITION);
t = tiledlayout(2,1);

nexttile
title('Gondel (MSB0001; 20 Hz)')
hold on
plot(msb1.time, msb1.acc_x, 'DisplayName', 'X')
plot(msb1.time, msb1.acc_y, 'DisplayName', 'Y')
plot(msb1.time, msb1.acc_z, 'DisplayName', 'Z')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')

nexttile
title('Halbe Turmhöhe (MSB0003; 20 Hz)')
hold on
plot(msb3.time, msb3.acc_x, 'DisplayName', 'X')
plot(msb3.time, msb3.acc_y, 'DisplayName', 'Y')
plot(msb3.time, msb3.acc_z, 'DisplayName', 'Z')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')

lgd = legend;
lgd.Layout.Tile = 'east';
title(t, 'Krogmann-Anlage: Rohdaten')
print(GFX_FOLDER + "/" + "krogmann_raw",'-dpng')

analyzeTimeIntervals(msb1.time, 75, 'MSB0001', FIGURE_POSITION);
print(GFX_FOLDER + "/" + "MSB0001_time_intervals", '-dpng')


% Krogmann turbine: Postprocessed acceleration data
% We subtractthe mean values and do not show the gravity axis.
fig = figure('position', FIGURE_POSITION);
t = tiledlayout(2,1);
nexttile
title('Gondel (MSB0001; 20 Hz)')
hold on
plot(msb1.time, msb1.acc_x - mean(msb1.acc_x), 'DisplayName', 'X')
plot(msb1.time, msb1.acc_y - mean(msb1.acc_y), 'DisplayName', 'Y')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')
nexttile
title('Halbe Turmhöhe (MSB0003; 20 Hz)')
hold on
plot(msb3.time, msb3.acc_x - mean(msb3.acc_x), 'DisplayName', 'X')
plot(msb3.time, msb3.acc_z - mean(msb3.acc_z), 'DisplayName', 'Z')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')
lgd = legend;
lgd.Layout.Tile = 'east';
title(t, 'Krogmann-Anlage: Nachbearbeitete Daten')
print(GFX_FOLDER + "/" + "krogmann_postprocessed", '-dpng')

fig = figure('position', FIGURE_POSITION);
t = tiledlayout(2,1);
nexttile
title('Gondel (MSB0001; 20 Hz)')
hold on
plot(msb1.time(msb1.inTime), msb1.acc_x(msb1.inTime) - mean(msb1.acc_x(msb1.inTime)), 'DisplayName', 'X')
plot(msb1.time(msb1.inTime), msb1.acc_y(msb1.inTime) - mean(msb1.acc_y(msb1.inTime)), 'DisplayName', 'Y')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')
nexttile
title('Halbe Turmhöhe (MSB0003; 20 Hz)')
hold on
plot(msb3.time(msb1.inTime), msb3.acc_x(msb1.inTime) - mean(msb3.acc_x(msb1.inTime)), 'DisplayName', 'X')
plot(msb3.time(msb1.inTime), msb3.acc_z(msb1.inTime) - mean(msb3.acc_z(msb1.inTime)), 'DisplayName', 'Z')
xlabel('Zeit (Berlin-Zeitzone)')
ylabel('Beschleunigung (m/s^2)')
lgd = legend;
lgd.Layout.Tile = 'east';
title(t, 'Krogmann-Anlage: Nachbearbeitete Daten')
print(GFX_FOLDER + "/" + "krogmann_postprocessed_zoomed", '-dpng')


if DO_PLOT_FFT == 1
    calculateFFT(msb1, FIGURE_POSITION);
    title('FFT der Krogmann-Anlage (MSB0001)');
    print(GFX_FOLDER + "/" + "krogmann_FFT",'-dpng')
end


function lidar = importLidarFile(filename, dataLines)

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 83);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ";";

% Specify column names and types
%
% TODO: Fix 'horinzontal' typo in https://github.com/project-windio/lidar-data.
% Variable names are not compared to the file header, instead each column
% is named subsequently with the specified strings. Thus, parseing the data
% works despite the typo.
opts.VariableNames = ["time", "airPressure", "battery", "gps_latitude", "gps_longitude", "ground_windspeed", "horizontal_windspeed_height_1", "horizontal_windspeed_height_10", "horizontal_windspeed_height_11", "horizontal_windspeed_height_2", "horizontal_windspeed_height_3", "horizontal_windspeed_height_4", "horizontal_windspeed_height_5", "horizontal_windspeed_height_6", "horizontal_windspeed_height_7", "horizontal_windspeed_height_8", "horizontal_windspeed_height_9", "humidity", "individual_reference_1", "individual_reference_10", "individual_reference_11", "individual_reference_2", "individual_reference_3", "individual_reference_4", "individual_reference_5", "individual_reference_6", "individual_reference_7", "individual_reference_8", "individual_reference_9", "individual_timestamp_1", "individual_timestamp_10", "individual_timestamp_11", "individual_timestamp_2", "individual_timestamp_3", "individual_timestamp_4", "individual_timestamp_5", "individual_timestamp_6", "individual_timestamp_7", "individual_timestamp_8", "individual_timestamp_9", "met_wind_direction", "pod_humidity", "pod_lower_temperature", "pod_upper_temperature", "raining", "reference", "scan_dwell_time", "set_height_1", "set_height_10", "set_height_11", "set_height_2", "set_height_3", "set_height_4", "set_height_5", "set_height_6", "set_height_7", "set_height_8", "set_height_9", "temperature", "tilt", "timestamp_data_received", "vertical_windspeed_height_1", "vertical_windspeed_height_10", "vertical_windspeed_height_11", "vertical_windspeed_height_2", "vertical_windspeed_height_3", "vertical_windspeed_height_4", "vertical_windspeed_height_5", "vertical_windspeed_height_6", "vertical_windspeed_height_7", "vertical_windspeed_height_8", "vertical_windspeed_height_9", "wind_direction_1", "wind_direction_10", "wind_direction_11", "wind_direction_2", "wind_direction_3", "wind_direction_4", "wind_direction_5", "wind_direction_6", "wind_direction_7", "wind_direction_8", "wind_direction_9"];
opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "time", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "time", "EmptyFieldRule", "auto");

% Import the data
tbl = readtable(filename, opts);

%% Convert to output type

timeString = tbl.time;
lidar.time = NaT(length(timeString),1);
for i = 1:length(lidar.time)
    lidar.time(i) = datetime(datestr(datenum8601(char(timeString(i)))));
end
lidar.time.TimeZone = '+00:00'; % Data are in UTC.

lidar.airPressure = tbl.airPressure;
lidar.battery = tbl.battery;
lidar.gps_latitude = tbl.gps_latitude;
lidar.gps_longitude = tbl.gps_longitude;
lidar.ground_windspeed = tbl.ground_windspeed;
lidar.horizontal_windspeed_height_1 = tbl.horizontal_windspeed_height_1;
lidar.horizontal_windspeed_height_2 = tbl.horizontal_windspeed_height_2;
lidar.horizontal_windspeed_height_3 = tbl.horizontal_windspeed_height_3;
lidar.horizontal_windspeed_height_4 = tbl.horizontal_windspeed_height_4;
lidar.horizontal_windspeed_height_5 = tbl.horizontal_windspeed_height_5;
lidar.horizontal_windspeed_height_6 = tbl.horizontal_windspeed_height_6;
lidar.horizontal_windspeed_height_7 = tbl.horizontal_windspeed_height_7;
lidar.horizontal_windspeed_height_8 = tbl.horizontal_windspeed_height_8;
lidar.horizontal_windspeed_height_9 = tbl.horizontal_windspeed_height_9;
lidar.horizontal_windspeed_height_10 = tbl.horizontal_windspeed_height_10;
lidar.horizontal_windspeed_height_11 = tbl.horizontal_windspeed_height_11;
lidar.humidity = tbl.humidity;
lidar.individual_reference_1 = tbl.individual_reference_1;
lidar.individual_reference_10 = tbl.individual_reference_10;
lidar.individual_reference_11 = tbl.individual_reference_11;
lidar.individual_reference_2 = tbl.individual_reference_2;
lidar.individual_reference_3 = tbl.individual_reference_3;
lidar.individual_reference_4 = tbl.individual_reference_4;
lidar.individual_reference_5 = tbl.individual_reference_5;
lidar.individual_reference_6 = tbl.individual_reference_6;
lidar.individual_reference_7 = tbl.individual_reference_7;
lidar.individual_reference_8 = tbl.individual_reference_8;
lidar.individual_reference_9 = tbl.individual_reference_9;
lidar.individual_timestamp_1 = tbl.individual_timestamp_1;
lidar.individual_timestamp_2 = tbl.individual_timestamp_2;
lidar.individual_timestamp_3 = tbl.individual_timestamp_3;
lidar.individual_timestamp_4 = tbl.individual_timestamp_4;
lidar.individual_timestamp_5 = tbl.individual_timestamp_5;
lidar.individual_timestamp_6 = tbl.individual_timestamp_6;
lidar.individual_timestamp_7 = tbl.individual_timestamp_7;
lidar.individual_timestamp_8 = tbl.individual_timestamp_8;
lidar.individual_timestamp_9 = tbl.individual_timestamp_9;
lidar.individual_timestamp_10 = tbl.individual_timestamp_10;
lidar.individual_timestamp_11 = tbl.individual_timestamp_11;
lidar.met_wind_direction = tbl.met_wind_direction;
lidar.pod_humidity = tbl.pod_humidity;
lidar.pod_lower_temperature = tbl.pod_lower_temperature;
lidar.pod_upper_temperature = tbl.pod_upper_temperature;
lidar.raining = tbl.raining;
lidar.reference = tbl.reference;
lidar.scan_dwell_time = tbl.scan_dwell_time;

% After a discussion between Malte Frieling and Andreas Haselsteiner it
% became clear that the wind speed at height 11 is the measurement at the 
% reference height of 38 m  that is always included (see page 6 in 
% Lewis, A. (2018): ZX 300 Configuration Guide). 
% height_11 is thus wrongly described as 0 m in the raw data. It is 
% actually 38 m + distance from lidar top to ground. Generally, we need to 
% add the distance from ground to the lidar top, 1 m, to the stated height.

lidar.ground_to_lidar_top_in_m = 1;
lidar.set_height_1 = tbl.set_height_1 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_2 = tbl.set_height_2 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_3 = tbl.set_height_3 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_4 = tbl.set_height_4 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_5 = tbl.set_height_5 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_6 = tbl.set_height_6 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_7 = tbl.set_height_7 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_8 = tbl.set_height_8 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_9 = tbl.set_height_9 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_10 = tbl.set_height_10 + lidar.ground_to_lidar_top_in_m;
lidar.set_height_11 = zeros(size(lidar.set_height_10)) + 38 + lidar.ground_to_lidar_top_in_m;

lidar.temperature = tbl.temperature;
lidar.tilt = tbl.tilt;
lidar.timestamp_data_received = tbl.timestamp_data_received;

lidar.vertical_windspeed_height_1 = tbl.vertical_windspeed_height_1;
lidar.vertical_windspeed_height_2 = tbl.vertical_windspeed_height_2;
lidar.vertical_windspeed_height_3 = tbl.vertical_windspeed_height_3;
lidar.vertical_windspeed_height_4 = tbl.vertical_windspeed_height_4;
lidar.vertical_windspeed_height_5 = tbl.vertical_windspeed_height_5;
lidar.vertical_windspeed_height_6 = tbl.vertical_windspeed_height_6;
lidar.vertical_windspeed_height_7 = tbl.vertical_windspeed_height_7;
lidar.vertical_windspeed_height_8 = tbl.vertical_windspeed_height_8;
lidar.vertical_windspeed_height_9 = tbl.vertical_windspeed_height_9;
lidar.vertical_windspeed_height_10 = tbl.vertical_windspeed_height_10;
lidar.vertical_windspeed_height_11 = tbl.vertical_windspeed_height_11;

lidar.wind_direction_1 = tbl.wind_direction_1;
lidar.wind_direction_2 = tbl.wind_direction_2;
lidar.wind_direction_3 = tbl.wind_direction_3;
lidar.wind_direction_4 = tbl.wind_direction_4;
lidar.wind_direction_5 = tbl.wind_direction_5;
lidar.wind_direction_6 = tbl.wind_direction_6;
lidar.wind_direction_7 = tbl.wind_direction_7;
lidar.wind_direction_8 = tbl.wind_direction_8;
lidar.wind_direction_9 = tbl.wind_direction_9;
lidar.wind_direction_10 = tbl.wind_direction_10;
lidar.wind_direction_11 = tbl.wind_direction_11;
end

function msb = importMSBfile(filename, dataLines)
%IMPORTFILE Import data from a text file
%  [TIME, ACC_X, ACC_Y, ACC_Z] = IMPORTFILE(FILENAME) reads data from
%  text file FILENAME for the default selection.  Returns the data as
%  column vectors.
%
%  [TIME, ACC_X, ACC_Y, ACC_Z] = IMPORTFILE(FILE, DATALINES) reads data
%  for the specified row interval(s) of text file FILENAME. Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  [time, acc_x, acc_y, acc_z] = importfile("C:\UBremen\01d_WindIO\LidarUndMSBs\dataset_from_2022-12-10\time-series-msbi0001.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 08-Aug-2023 16:55:15

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ";";

% Specify column names and types
opts.VariableNames = ["time", "acc_x", "acc_y", "acc_z"];
opts.VariableTypes = ["string", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "time", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "time", "EmptyFieldRule", "auto");

% Import the data
tbl = readtable(filename, opts);

timeString = tbl.time;

time = NaT(1, length(timeString));
for i = 1:length(timeString)
    timeChars = char(timeString(i));
    if length(timeChars) == 27
        time(i) = datetime(timeChars(1:length(timeChars) - 1), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
    else
        % time stamp does not contain milliseconds
        time(i) = datetime(timeChars(1:length(timeChars) - 1), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    end
end
time.TimeZone = '+00:00'; % Data is in UTC


%% Convert to output type
msb.time = time;
msb.timeString = timeString;
msb.acc_x = tbl.acc_x;
msb.acc_y = tbl.acc_y;
msb.acc_z = tbl.acc_z;
end

function msb = import_msb_log(fname)
    G = 9.81;

    totLines = countLines(fname);
    time = NaT(totLines, 1);
    acc_x = nan(totLines, 1);
    acc_y = nan(totLines, 1);
    acc_z = nan(totLines, 1);
    fid = fopen(fname);
    tline = fgetl(fid);
    count = 1;
    while ischar(tline)
        if tline(3:5) == 'imu'
            sepColumns = strsplit(tline, ["{'imu': [", ","]);
            time(count) = datetime(str2double(sepColumns{2}), 'convertfrom', 'posixtime', 'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
            acc_x(count) = str2double(sepColumns{4});
            acc_y(count) = str2double(sepColumns{5});
            acc_z(count) = str2double(sepColumns{6});
        end
        tline = fgetl(fid);
        count = count + 1;
    end
    fclose(fid);
    
    isValidData = ~isnat(time);
    
    msb.time = time(isValidData);
    msb.time.TimeZone = '+00:00'; % Data are in UTC
    msb.acc_x = acc_x(isValidData) * G;
    msb.acc_y = acc_y(isValidData) * G;
    msb.acc_z = acc_z(isValidData) * G;
end

% Thanks to: https://stackoverflow.com/questions/12176519/is-there-a-way-in-matlab-to-determine-the-number-of-lines-in-a-file-without-loop
function count = countLines(fname)
    fh = fopen(fname, 'rt');
    assert(fh ~= -1, 'Could not read: %s', fname);
    x = onCleanup(@() fclose(fh));
    count = 0;
    while ~feof(fh)
        count = count + sum( fread( fh, 16384, 'char' ) == newline );
    end
end

function calculateFFT(msb, FIGURE_POSITION)
    x = msb.acc_x - mean(msb.acc_x);
    y = msb.acc_y - mean(msb.acc_y);

    Fs = 50;              % Sampling frequency  in Hz                  
    T = 1/Fs;             % Sampling period in seconds
    
    time_seconds = seconds(msb.time - msb.time(1));
    time_resampled = [time_seconds(1):T:time_seconds(end)];
    
    % Resample x
    tsin = timeseries(x, time_seconds);
    tsout = resample(tsin, time_resampled);
    x_resampled = tsout.Data;
    
    % Resample y
    tsin = timeseries(y, time_seconds);
    tsout = resample(tsin, time_resampled);
    y_resampled = tsout.Data;
    
    % Calculate FFT, thanks to: https://de.mathworks.com/help/matlab/ref/fft.html   
    L = length(y_resampled);% Length of signal
    f = Fs*(0:(L/2))/L;
    
    % FFT for x
    Y_x = fft(x_resampled);
    P2_x = abs(Y_x/L);
    P1_x = P2_x(1:L/2+1);
    P1_x(2:end-1) = 2*P1_x(2:end-1);
    
    % FFT for y
    Y_y = fft(y_resampled);
    P2_y = abs(Y_y/L);
    P1_y = P2_y(1:L/2+1);
    P1_y(2:end-1) = 2*P1_y(2:end-1);
    
    
    fig = figure('position', FIGURE_POSITION);
    hold on 
    plot(f, P1_x, 'DisplayName', 'X') 
    plot(f, P1_y, 'DisplayName', 'Y') 
    title("Single-Sided Amplitude Spectrum of X(t)")
    xlabel("Frequenz (Hz)")
    ylabel("Amplitude, |P1(f)|")
    legend
    xlim([0 5])
    start_f_index = 20;
    max_y = max([max(P1_x(start_f_index:end)), max(P1_y(start_f_index:end))]);
    ylim([0, max_y])
end

function analyzeTimeIntervals(time, mode_divider, msb_name, FIGURE_POSITION)
    outlier_threshold = 120;
    duration_between_measurements = milliseconds(time(2:end) - time(1:end-1));
    fig = figure('position', FIGURE_POSITION);
    histogram(duration_between_measurements, 'BinWidth', 1);
    is_within_first_mode = duration_between_measurements < mode_divider;
    msb1_duration_first_mode = (mean(duration_between_measurements(is_within_first_mode)));
    msb1_duration_first_mode_std = (std(duration_between_measurements(is_within_first_mode)));
    currentYLim = ylim;
    y_pos = -0.08 * currentYLim(2);
    text(msb1_duration_first_mode, y_pos, num2str(msb1_duration_first_mode, '%4.1f') + "±" + num2str(msb1_duration_first_mode_std, '%4.1f') + " ms", 'HorizontalAlignment', 'Center')
    is_within_second_mode = duration_between_measurements > mode_divider & duration_between_measurements < outlier_threshold;
    if sum(is_within_second_mode) > 0
        msb1_duration_second_mode = mean(duration_between_measurements(is_within_second_mode));
        msb1_duration_second_mode_std = std(duration_between_measurements(is_within_second_mode));
        text(msb1_duration_second_mode, y_pos, num2str(msb1_duration_second_mode, '%4.1f') + "±" + num2str(msb1_duration_second_mode_std, '%4.1f') + " ms", 'HorizontalAlignment', 'Center')
    end
    is_outlier = duration_between_measurements > outlier_threshold;
    text(100, y_pos, num2str(sum(is_outlier)) + " Ausreisser > 120 ms")
    upperXLim = 120;
    text(0.97 * upperXLim, 0.04 * currentYLim(2), string(time(1)) + ' bis ' + string(time(end)), 'HorizontalAlignment', 'right')
    xlim([0 upperXLim])
    xlabel("Zeitlicher Abstand zwischen den " + msb_name + "-Messintervallen (ms)");
    ylabel('Häufigkeit');
end
