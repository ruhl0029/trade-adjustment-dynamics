%%
clear all; close all; clc;

figure_folder = 'figures/';
model_folder = 'model outputs/';

set(groot,'defaultLegendAutoUpdate','off') ;
set(groot,'defaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 12);

pw = 650;
ph = 350;

% model output

bench= xlsread(strcat(model_folder,'RhoHL01.xlsx'),1);
fixed_entry = xlsread(strcat(model_folder,'RhoHL_FixedN01.xlsx'), 1);
sunk= xlsread(strcat(model_folder,'Sunk_Same01.xlsx'),1);
%no_cost= xlsread('PGM05_20131218\NoCost_SluggishLshare\NoCost_SluggishLshare01.xlsx',1);
no_cost= xlsread(strcat(model_folder,'NoCost_Sluggish01.xlsx'),1);

% 1	Period   6	n_0    11	NT     16	IntL         21	X
% 2	C        7	n_1    12	N_TE   17	(NT+n_x*NT)  22	(IntT+ta^(-th)*(xiH^(1-th)*IntH+xiL^(1-th)*IntL))
% 3	L        8	n_X    13	IntT   18	K0           23	z0
% 4	EXY      9	OP     14	Int0   19	Y            24	zH
% 5	LP       10	PP     15	IntH   20	W            25	zL
%                                                    26	lambda
%                                                    27	IMD

%% Elasticity 
jj = 27;  % var to plot

figure('Position', [100,100,pw,ph], 'Name','');

plot(log((bench(:,jj)/bench(1,jj)))/log(1.1),'-blue'), hold on
plot(log((sunk(:,jj)/sunk(1,jj)))/log(1.1),'--k'), hold on
plot(log((fixed_entry(:,jj)/fixed_entry(1,jj)))/log(1.1),'-sb','MarkerIndices', 1:5:50), hold on
leg = legend('Benchmark & No Cost','Sunk','Fixed Entry', 'Location','SouthEast');


ylabel('Elasticity');
ylim([0,12]);xlim([0,50]);
format_figure(gca, leg);
saveas(gcf, strcat(figure_folder,'fig3a.eps'),'epsc');

%% Consumption
jj = 2;  % var to plot
figure('Position', [100,100,pw,ph], 'Name','');

plot(100*log((bench(:,jj)/bench(1,jj))),'-blue'), hold on
plot(100*log((sunk(:,jj)/sunk(1,jj))),'--k'), hold on
plot(100*log((fixed_entry(:,jj)/fixed_entry(1,jj))),'-sb', 'MarkerIndices', 1:5:50), hold on
plot(100*log((no_cost(:,jj)/no_cost(1,jj))),'-or', 'MarkerIndices', 1:5:50), hold on
plot([0, 50], [0,0], '-k'), hold on
leg = legend('Benchmark','Sunk','Fixed Entry', 'No Cost', 'Location','NorthEast', 'NumColumns', 2);

xlabel('Year');
ylabel('Change');
ylim([-2,12]);xlim([0,50]);

format_figure(gca, leg);
saveas(gcf,strcat(figure_folder,'fig3b.eps'),'epsc');