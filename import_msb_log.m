fname = 'msblog_test.log';
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