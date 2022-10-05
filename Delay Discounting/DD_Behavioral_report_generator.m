function [] = DD_Behavioral_report_generator(data,subjectID,sessionID,protocolID)
% Function used to generate the post task report for
% Delay_Discount_Behavioral.m as part of the "insert cool app name" app
% Will create a report from the data generated during the behavioral session,
% 
%
% Created August 26th 2022 Jacob Suffridge
% 
% Updated August 31st 2022
% Add functionality to save all the data to a csv for external analysis if
% necessary.1
%
% Example inputs:
% training_data = load('/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting/Delay Discounting Data/Jacob_Test/Jacob_Test_Delay_Discounting_Behavioral_09_24_2022.mat').data;
% subjectID = 'Jacob_Test';
% protocolID = 'DISCO';
% sessionID = '1';
% -------------------------------------------------------------------------

% Set some initial parameters to be used later
savePath = ['/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting/Delay Discounting Data/', protocolID, '/', subjectID, '/'];
saveNamePDF = [savePath, subjectID, '_Behavioral_', sessionID, '.pdf'];
saveNameCSV = [savePath, subjectID, '_Behavioral_', sessionID, '.csv'];

time_in_days = [1,7,30,90,365,5*365,25*365];
time_strings = {'1 day','1 week','1 month','3 months','1 year','5 years','25 years'};

%% Create PDF Report
import mlreportgen.dom.*
import mlreportgen.report.*
rpt = Report(saveNamePDF,'pdf');

% Title Page --------------------------------------------------------------
tp = TitlePage();
tp.Title = 'Delay Discounting Behavioral Report';
tp.Subtitle = ['Participant: ', subjectID];

titleImg = Image(which('blank.JPG'));
titleImg.Height = '5.5in';
titleImg.Width = '7in';
tp.Image = titleImg;
tp.PubDate = [tp.PubDate, ' at ', datestr(now,'HH:MM:SS')];

tp.Publisher = 'automatically generated on';
tp.Author = '*Insert cool OUD app name*';

% Add title page to the report and insert page break
add(rpt,tp);
add(rpt,mlreportgen.dom.PageBreak());

% Generate table to showcase the collected data ---------------------------
tblNames = {'Now Amount','RT (s)','Delay Time','Resp','Now Location','0-Delayed, 1-Now','0-Easy, 1-Hard'};
tableStyles = { ColSep("solid"), RowSep("solid"), Border("solid"), NumberFormat("%1.3f"), Width("100%"), HAlign('center'), FontFamily('Times New Roman'), FontSize('11')};            
tableHeaderStyles = { BackgroundColor("lightgray"), Bold(true), HAlign('center')};

% Loop through and round all numbers to 2 decimal places
for i = 1:length(data.counter)
    % Round the now amounts to 2 decimal places
%     training_data.counter{i,1} = num2str(round(training_data.counter{i,1},2));
    % Round the Reaction Times
    data.counter{i,end} = round(data.counter{i,end}*1000)/1000;

    % Convert booleans to numeric string (ignores sig figs)
    data.counter{i,3} = num2str(data.counter{i,3});
    % Convert booleans to numeric string (ignores sig figs)
    data.counter{i,4} = num2str(data.counter{i,4});
    % Convert booleans to numeric string (ignores sig figs)
    data.counter{i,5} = num2str(data.counter{i,5});
    % Convert booleans to numeric string (ignores sig figs)
    data.counter{i,6} = num2str(data.counter{i,6});
    % Convert booleans to numeric string (ignores sig figs)
    data.counter{i,7} = num2str(data.counter{i,7});
end 

% Set the table formats
cellTbl = FormalTable(tblNames,data.counter);
cellTbl.Style = [cellTbl.Style, tableStyles];
cellTbl.Header.Style = [cellTbl.Header.Style, tableHeaderStyles];
cellTbl.TableEntriesInnerMargin = "2pt";
cellTbl.TableEntriesHAlign = 'center';

% Create table to save the data as a csv
tbl = cell2table(data.counter,VariableNames = tblNames);
writetable(tbl,saveNameCSV);

% Add the table to the report and insert page break
append(rpt,cellTbl);
add(rpt,mlreportgen.dom.PageBreak());


% -------------------------------------------------------------------------
close all
rptview(rpt)

% end 