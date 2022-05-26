function [] = plotRatings(ratings,timestamp)
% This function plots the ratings scale values in real time
% written Jan 2022 Jacob Suffridge

% ratings is expected to be a nx6 array

% Color and Legend Labels
colors = {'k', 'b', 'r', 'g', 'm', 'c'};
legend_labels = {'Craving', 'Mood', 'Anxiety', 'Energy', 'Happiness', 'Fear'};
ylabels = {'0','1','2','3','4','5','6','7','8','9'};

% Check that input ratings are consistent with expected matrix size
tmp = size(ratings);
if tmp(2) ~= 6
    disp('Input matrix dimensions are incorrect!')
end

% Get the timestamps and time vector for the plot
time = 1:height(ratings);
timestamp = timestamp(:,end)';

% Set the fontsize of the tick labels 
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',15,'fontweight','bold')

% Open new figure
% figure; 
hold on;
for i = 1:width(ratings)
    % plot the ratings individually on the same plot
    plot(time, ratings(:,i), colors{i}, 'LineWidth', 3, 'Marker', 'o');
    drawnow;
    grid on;
    
    % adjust y labels  (MRI INPUT)
    %     ylim([1,4]);
    %     yticks(1:4);
    %     yticklabels({'1st Q.','2nd Q.','3rd Q.','4th Q.'});
    
    % adjust x labels  (MRI INPUT)
    %     xticks(time);
    %     xticklabels(timestamp);
    
    % adjust y labels (keypad input)
    ylim([0,9]);
    yticks(0:9);
    yticklabels(ylabels);
    
    % adjust x labels (keypad input)
    xticks(time);
    xticklabels(timestamp);
end

% Set the legend for the now drawn plot
legend(legend_labels, 'Location', 'northoutside', 'NumColumns', 3, 'AutoUpdate', 'off');

