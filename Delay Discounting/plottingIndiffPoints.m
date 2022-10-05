


load('/home/helpdesk/Documents/MATLAB/RNI-OUD/Delay Discounting/Delay Discounting Data/DISCO/Test/Test_Delay_Discounting_training_08_30_2022.mat')

time_in_days = [1,7,30,90,365,5*365,25*365];
time_strings = {'1 day','1 week','1 month','3 months','1 year','5 years','25 years'};


indiffPoints = data.indiffPoints;
t = linspace(time_in_days(1),time_in_days(end),10000);

proportionAmounts = [0.05:0.1:0.95,1,0.92,0.96,1.04,1.08];

points = data.funct(data.k,time_in_days);
testPoints = points'*proportionAmounts;

figure;
scatter(time_in_days,points,125,'r.')
hold on;

plot(t,data.funct(data.k,t))


for i = 1:size(testPoints,1)
    for j = 1:size(testPoints,2)
        scatter(time_in_days(i),testPoints(i,:),'k')
    end 
end 
set(gca,'xscale','log')
set(gca,'XTick',time_in_days)
set(gca,'XTickLabels',time_strings)
