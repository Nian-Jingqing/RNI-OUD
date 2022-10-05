function [] = DD_5Trial_report_generator(baseline_data,subjectID,sessionID,protocolID)
% Function used to generate the post task report for
% Delay_Discount_5Trial.m as part of the "insert cool app name" app
% Will create a report from the data generated during the 5Trial phase,
% made independent report generation to account for participants that only
% participate in the out of scanner baseline session.
%
% Created August 26th 2022 Jacob Suffridge
% 
% Updated August 30th 2022
% Add pathing functionality to incorporate sessionID and protocolID in the
% pwd
%
% Updated August 31st 2022
% Add functionality to save all the data to a csv for external analysis if
% necessary.
%
% Example inputs:
% baseline_data = load('/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting/Delay Discounting Data/Jacob_Test/Jacob_Test_Delay_Discounting_baseline_09_24_2022.mat').data;
% subjectID = 'Jacob_Test';
% -------------------------------------------------------------------------

% Set some initial parameters to be used later
savePath = ['/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting/Delay Discounting Data/', protocolID, '/', subjectID, '/'];
saveNamePDF = [savePath, subjectID, '_5Trial_', sessionID, '.pdf'];
saveNameCSV = [savePath, subjectID, '_5Trial_', sessionID, '.csv'];

time_in_days = [1,7,30,90,365,5*365,25*365];
time_strings = {'1 day','1 week','1 month','3 months','1 year','5 years','25 years'};

%% Create PDF Report
import mlreportgen.dom.*
import mlreportgen.report.*
rpt = Report(saveNamePDF,'pdf');

% Title Page --------------------------------------------------------------
tp = TitlePage();
tp.Title = ['Delay Discounting 5 Trial Report: ', protocolID];
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
tblNames = {'Now Amount','RT (s)','Delay Time','Resp','Now Location','0-Delayed, 1-Now'};
% tbl = cell2table(baseline_data.counter,'VariableNames',tblNames);

tableStyles = { ColSep("solid"), RowSep("solid"), Border("solid"), NumberFormat("%1.3f"), Width("100%"), HAlign('center'), FontFamily('Times New Roman'), FontSize('11')};            
tableHeaderStyles = { BackgroundColor("lightgray"), Bold(true), HAlign('center')};

% Loop through and round all numbers to 2 decimal places
for i = 1:length(baseline_data.counter)
    % Round the now amounts to 2 decimal places
    baseline_data.counter{i,1} = num2str(round(baseline_data.counter{i,1},2));
    % Round the Reaction Times
    baseline_data.counter{i,2} = round(baseline_data.counter{i,2}*1000)/1000;
    % Convert booleans to numeric string (ignores sig figs)
    baseline_data.counter{i,3} = num2str(baseline_data.counter{i,3});
    % Convert booleans to numeric string (ignores sig figs)
    baseline_data.counter{i,4} = num2str(baseline_data.counter{i,4});
    % Convert booleans to numeric string (ignores sig figs)
    baseline_data.counter{i,5} = num2str(baseline_data.counter{i,5});
    % Convert booleans to numeric string (ignores sig figs)
    baseline_data.counter{i,6} = num2str(baseline_data.counter{i,6});
end 

% Set the table formats
cellTbl = FormalTable(tblNames,baseline_data.counter);
cellTbl.Style = [cellTbl.Style, tableStyles];
cellTbl.Header.Style = [cellTbl.Header.Style, tableHeaderStyles];
cellTbl.TableEntriesInnerMargin = "2pt";
cellTbl.TableEntriesHAlign = 'center';

% Create table to save the data as a csv
tbl = cell2table(baseline_data.counter,VariableNames = tblNames);
writetable(tbl,saveNameCSV);

% Add the table to the report and insert page break
append(rpt,cellTbl);
add(rpt,mlreportgen.dom.PageBreak());

% Indifference Points Figure -------------------------------------------------
h1 = Heading1('Plot of Indifference Points');
h1.Color = 'Black';
h1.HAlign = 'center';
add(rpt,h1);

% Create the recipocal function to curve fit the data
funct = @(k,time_in_days) 1./(1+(k.*time_in_days));

% Create log plot and style it
fig = figure;
t = linspace(time_in_days(1),time_in_days(end),10000);
scatter(time_in_days,baseline_data.indiffPoints,'ko')
hold on
plot(t,funct(baseline_data.k,t),'b-')
set(gca,'xtick', time_in_days)
set(gca,'xscale','log')
xticklabels(time_strings)
xtickangle(315);
legend('Indifference Points',['Curve Fit k = ', num2str(baseline_data.k)])
xlabel('Delay to Larger Reward')
ylabel('Proportional Value of Delayed Reward')

indif_fig = Figure(fig);
figImg = Image(getSnapshotImage(indif_fig,rpt));
figImg.Style = [figImg.Style, {ScaleToFit}];

% Create Paragraph wrapper for the figure image
p1 = Paragraph(figImg);
p1.Style = [p1.Style, {OuterMargin("0in","0in","0in","0in")}];
add(rpt,p1)

% -------------------------------------------------------------------------
close all
% rptview(rpt)

% end 