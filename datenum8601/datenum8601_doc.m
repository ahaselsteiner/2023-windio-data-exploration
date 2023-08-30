%% DATENUM8601 Examples
% The function <https://www.mathworks.com/matlabcentral/fileexchange/39389
% |DATENUM8601|> converts ISO 8601 formatted date strings (char vectors),
% into date numbers, the format specified by a very compact token syntax.
%
% *In general |DATENUM8601| token syntax is not compatible with |DATENUM|
% or |DATETIME|*. Note |DATENUM8601| does not parse or handle timezones.
%
% This document shows examples of |DATENUM8601| usage. Most examples
% use the date+time given by the date vector |[1999,1,3,15,6,48.0568]|.
%% Basic Usage
% With just one input argument |DATENUM8601| will try to match any ISO 8601
% timestamps in the provided string. The timestamps can use any ISO 8601
% date notation (calendar, ordinal, week-numbering), and optionally also
% have reduced precision (i.e. missing trailing units), fractions of the
% trailing unit (with any number of digits), and use one of some common
% (non-standard) date-time separator characters (must be one of |'T @_'|):
datevec(datenum8601('19990103T15.25')) % calendar date, fractional hours.
datenum8601('2000-002@0000') % ordinal date, '@' date-time separator.
datenum8601('Both 2000-01-02 and 1999-W52-7 are the same day') % calendar and week dates.
%% Output 2: Split String
% The second output is a cell array of character vectors containing the
% parts of the input string that were not matched as ISO 8601 timestamps:
[~,spl] = datenum8601('Both 2000-01-02 and 1999-W52-7 are the same day')
%% Output 3: Matched Tokens
% The third output is a cell array of character vectors containing tokens
% that represent the date format of the matched dates (see the Mfile help
% for a complete explanation of these tokens, also used in |DATESTR8601|):
[~,~,tkc] = datenum8601('Both 2000-01-02 and 1999-W52-7 are the same day')
%% Input 2: Date-Time Separator Character
% Allows the date-time separator character to be specified, e.g. in case
% the default automagical matching lead to wrong timestamp matches:
datevec(datenum8601('1999W527 20000102T00')) % default allows 'T @_' separators.
datevec(datenum8601('1999W527 20000102T00','T')) % date-time separator char 'T'.
%% Input 2: Timestamp Token
% Allows the entire timestamp format to be specified, e.g. in case
% the default automagical matching lead to wrong timestamp matches:
[dtn,spl] = datenum8601('1999W527 20000102','ymd')
%% Input 1: Fractional Units
% Any trailing unit may include a fractional part (i.e. decimal digits):
datevec(datenum8601('1998-12-29.75'))
datevec(datenum8601('1998W53.25'))
%% Input 1: Week-Numbering Year Only
% By default a year by itself is interpreted as being the calendar year.
% To interpret the year by itself as the week-numbering year either:
%
% * add the |'W'| suffix, e.g. |'1999W'| or |'1999.123456W'|, or
% * specify the |'Y'| token when calling |DATENUM8601|.
datevec(datenum8601('1999.997252747253W'))
datevec(datenum8601('1999.997252747253','Y12'))
%% Bonus: ISO 8601 Calendar and Weekday Functions
% Included functions that support other ISO 8601 date functionalities,
% using ISO 8601 weekday order (with Monday as the first day of the week):
[day,name] = weekday8601(now,'long')
calendar8601()
%% Bonus: DATESTR8601 Function
% The reverse conversion (from date number/vector/datetime to ISO 8601
% timestamps) is easy to achieve by simply downloading my function
% <https://www.mathworks.com/matlabcentral/fileexchange/34095 DATESTR8601>:
dtn = datenum8601('1999-01-03T15:06:48.0568');
datestr8601(dtn, '*ymdHMS4') % calendar
datestr8601(dtn,  '*ynHMS4') % ordinal
datestr8601(dtn, '*YWDHMS4') % week