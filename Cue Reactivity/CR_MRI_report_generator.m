function [] = CR_MRI_report_generator(training_data,MRI_data,subjectID)
% Function used to generate the post task report for Cue Reactivity in the
% MRI as part of the DISCO protocol
%
%
% Created August 10th 2022 Jacob Suffridge
% 
% Example inputs:
% training_data = load('/home/helpdesk/Documents/MATLAB/RNI-OUD/CR Data/Ashley/Ashley_training_08_10_2022__11_43_46.mat').data;
% MRI_data = load('/home/helpdesk/Documents/MATLAB/RNI-OUD/CR Data/Ashley/CR MRI/Ashley_CR_MRI_Weighted_08_10_2022__11_48_04.mat').Data;
% subjectID = 'Ashley';
% -------------------------------------------------------------------------

%% Create PDF Report
import mlreportgen.dom.*
import mlreportgen.report.*
rpt = Report(subjectID,'pdf');

% Title Page --------------------------------------------------------------
tp = TitlePage();
tp.Title = ['Participant: ', subjectID];
tp.Subtitle = 'Cue Reactivity Report';

titleImg = Image(which('OperationDISCO.JPG'));
titleImg.Height = '5.5in';
titleImg.Width = '7.5in';
tp.Image = titleImg;

tp.Publisher = 'automatically generated on';
tp.Author = 'Jacob Suffridge';

add(rpt,tp);
add(rpt,mlreportgen.dom.PageBreak());

% Training Weights Figure -------------------------------------------------
h1 = Heading1('Training Weights used for MRI session');
h1.Color = 'Black';
h1.HAlign = 'center';
add(rpt,h1);

weight_fig = Figure(bar(training_data.weights));
xticklabels(training_data.CuesTypes)
xtickangle(315);

figImg = Image(getSnapshotImage(weight_fig,rpt));
figImg.Style = [figImg.Style, {ScaleToFit}];

% Create Paragraph wrapper for the figure image
p1 = Paragraph(figImg);
p1.Style = [p1.Style, {OuterMargin("0in","0in","0in","0in")}];
add(rpt,p1)

% Use header text to display training session date
h2 = Heading1(['Training Session Date: ', training_data.save_time(1:find(training_data.save_time == '_')-1)]);
h2.Color = 'Black';
h2.FontSize = '16';
add(rpt,h2);

% Use header text to display training session date
h2 = Heading1(['MRI Session Date: ', MRI_data.save_time(1:find(MRI_data.save_time == '_')-1)]);
h2.Color = 'Black';
h2.FontSize = '16';
add(rpt,h2);


% Use header text to display training session date
excludedCues = [];
if length(training_data.excludedCues) ~= 0
    for i = 1:length(training_data.excludedCues)
        excludedCues = [excludedCues, ',', training_data.excludedCues{i}];
    end
else
    excludedCues = 'None';
end

h2 = Heading1(['Excluded Cues: ', excludedCues]);
h2.Color = 'Black';
h2.FontSize = '16';
add(rpt,h2);

% Insert Page Break
add(rpt,mlreportgen.dom.PageBreak());

%%
%Ratings/Slider Pre data --------------------------------------------------
add(rpt,Heading1('Craving Ratings (Slider Input)'))
ratingsPreFig = Figure(bar(MRI_data.preBlockRatings));
xticklabels({'N','A','N','A','N','A','N','A','N','A'})
ylabel('Mean Craving Rating')
title('Ratings Pre Block',FontWeight='normal',FontSize=16)

ratingsPreImg = Image(getSnapshotImage(ratingsPreFig,rpt));
ratingsPreImg.Style = [ratingsPreImg.Style, {ScaleToFit}];

% Ratings/Slider Post data ------------------------------------------------
ratingsPostFig = Figure(bar(MRI_data.postBlockRatings));
xticklabels({'N','A','N','A','N','A','N','A','N','A'})
ylabel('Mean Craving Rating')
title('Ratings Post Block',FontWeight='normal',FontSize=16)

ratingsPostImg = Image(getSnapshotImage(ratingsPostFig,rpt));
ratingsPostImg.Style = [ratingsPostImg.Style, {ScaleToFit}];

rating_table = Table({ratingsPreImg;' '; ratingsPostImg});

rating_table.entry(1,1).Style = {Height('3.5in'), Width('5in')};
rating_table.entry(2,1).Style = {Height('.2in'), Width('5in')};
rating_table.entry(3,1).Style = {Height('3.5in'), Width('5in')};

rating_table.Style = {Width('100%'), ResizeToFitContents(false), HAlign('center'), ...
    OuterMargin(".25in",".25in",".25in",".25in")};

add(rpt, rating_table);

% Insert Page Break
add(rpt,mlreportgen.dom.PageBreak());

%%
% Slider RT Pre data
add(rpt,Heading1('Slider Input Reaction Time'))

RTpreFig = Figure(bar(MRI_data.preBlockRT));
xticklabels({'N','A','N','A','N','A','N','A','N','A'})
ylabel('Reaction Time (sec)')
title('Reaction Time Pre Block',FontWeight='normal',FontSize=16)

RTpreImg = Image(getSnapshotImage(RTpreFig,rpt));
RTpreImg.Style = [RTpreImg.Style, {ScaleToFit}];

% Slider RT Post data
RTpostFig = Figure(bar(MRI_data.postBlockRT));
xticklabels({'N','A','N','A','N','A','N','A','N','A'})
ylabel('Reaction Time (sec)')
title('Reaction Time Post Block',FontWeight='normal',FontSize=16)

RTpostImg = Image(getSnapshotImage(RTpostFig,rpt));
RTpostImg.Style = [RTpostImg.Style, {ScaleToFit}];

rt_table = Table({RTpreImg;' '; RTpostImg});

rt_table.entry(1,1).Style = {Height('3.5in'), Width('5in')};
rt_table.entry(2,1).Style = {Height('.2in'), Width('5in')};
rt_table.entry(3,1).Style = {Height('3.5in'), Width('5in')};

rt_table.Style = {Width('100%'), ResizeToFitContents(false), HAlign('center'), ...
    OuterMargin(".25in",".25in",".25in",".25in")};

add(rpt, rt_table);

%%
close all
rptview(rpt)

end 