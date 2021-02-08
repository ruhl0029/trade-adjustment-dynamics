clear all; close all; clc;

figure_folder = 'figures/';
model_folder = 'model outputs/';

set(groot,'defaultLegendAutoUpdate', 'off');
set(groot,'defaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 12)

% Model output
Bench = xlsread(strcat(model_folder,'NewExporterStatsGA.xlsx'), 1);
Sunk  = xlsread(strcat(model_folder,'NewExporterStatsGA.xlsx'), 2);
SunkH = xlsread(strcat(model_folder,'NewExporterStatsGA.xlsx'), 3);

Bench(1,4)=NaN; Sunk(1,4) = NaN; SunkH(1,4)=NaN;

%   1        2       3        4      5       6       7       8       9
% 'Period',	'C',	'L',	'EXY',	'LP',	'n_0',	'n_1',	'n_X',	'OP',	
%  10     11      12       13         14      15      16         17
% 'PP',	 'NT',	'N_TE',	'IntT*N',	'Int0', 'IntH',	'IntL',	'(NT+n_x*NT)',
%  18     19     20      21             22 
% 'K0',	 'Y',	'W',	'X', '(IntT+ta^(-th)*(xiH^(1-th)*IntH+xiL^(1-th)*IntL))',	
%  23    24       25      26          27
% 'z0',	'zH',	'zL',	'lambda',	'IMD'

% Ratio of the entry cost in the sunk cost and sunk cost high models to 
% the benchmark models. (See table 2.)
sunkscale = 5.79/3.76;
sunkscaleH = 18.3/3.76;

% Compute survival probabilities and cumulative profit
cumprofit = -100;
cumprofitS = -100;
cumprofitH = -100;
survival = Bench(1,5)/100*Bench(2,5)/Bench(2,4);
survivalS = Sunk(1,5)/100*Sunk(2,5)/Sunk(2,4);
survivalH = SunkH(1,5)/100*SunkH(2,5)/SunkH(2,4);

for i=2:1:25 %Each of these is an additional cut
   survival = [survival; survival(i-1)*Bench(i,5)/100];
   survivalS = [survivalS; survivalS(i-1)*Sunk(i,5)/100];
   survivalH = [survivalH; survivalH(i-1)*SunkH(i,5)/100];
   cumprofit = [cumprofit; cumprofit(i-1)+0.96^(i-1)*survival(i-1)*Bench(i,13)];
   cumprofitS = [cumprofitS; cumprofitS(i-1)+0.96^(i-1)*survivalS(i-1)*Sunk(i,13)];
   cumprofitH = [cumprofitH; cumprofitH(i-1)+0.96^(i-1)*survivalH(i-1)*SunkH(i,13)];
 
end

% Plot 
TT= 15;

%%
figure(1);
plot(Bench(:,6),  'b'), hold on
plot(Sunk(:,6) ,'--k'), hold on
plot(SunkH(:,6),'-.r'), hold on


ylim([0,20]); xlim([0,TT]);
ylabel('Percent');
leg = legend('Benchmark','Sunk','Sunk High', 'Location', 'Southeast');

format_figure(gca, leg)
saveas(gcf, strcat(figure_folder,'fig1_export_intensity.eps'), 'epsc');

%% 
figure(2)
plot(Bench(:,4),'-b' ), hold on
plot(Sunk(:,4) ,'--k'), hold on
plot(SunkH(:,4),'-.r'), hold on
plot([0 100],[83 83],'k')

text(11, 84, 'data (mean)');
ylim([75,100]); xlim([0,TT]);

format_figure(gca, leg)
saveas(gcf,strcat(figure_folder,'fig1_survival_rate.eps'),'epsc');

%%
figure(3);
plot(Bench(:,13),'-ob', 'MarkerIndices',1:2:TT), hold on
plot(Bench(:,14),'-sb', 'MarkerIndices',1:2:TT), hold on
plot(sunkscale*Sunk(:,13),'--k'), hold on
plot([0 100],[0 0],'k')

xlim([0,TT]);

ylabel('Percent');
xlabel('Years Exporting');
leg = legend('Benchmark Avg.','Benchmark z_{\infty}','Sunk','Location','Southeast');

format_figure(gca, leg)
saveas(gcf,strcat(figure_folder,'fig1_profits.eps'),'epsc');    



%%
figure(4);
plot(cumprofit,'-b'  ), hold on
plot(cumprofitS,'--k'), hold on
plot(cumprofitH,'-.r'), hold on
plot([0 100],[0 0],'k')

xlim([0,TT]);
xlabel('Years Exporting');

format_figure(gca, leg);
saveas(gcf,strcat(figure_folder,'fig1_cum_profit.eps'),'epsc');    

%%
% We load a different data set here. Notice the change in x axis. 
figure(5);
TT=50;
Bench= xlsread(strcat(model_folder,'DynamicsFromBirth.xlsx'),1);
Sunk= xlsread(strcat(model_folder,'DynamicsFromBirth.xlsx'),2);
SunkH= xlsread(strcat(model_folder,'DynamicsFromBirth.xlsx'),3);

plot(100*Bench(:,5),'-b', 'MarkerIndices', 1:4:TT), hold on
plot(100*Sunk(:,5),'--k'), hold on
plot(100*SunkH(:,5),'-.r'), hold on
xlim([0,TT]);

xlabel('Years Since Establishment Creation');
ylabel('Percent');

format_figure(gca, leg);
saveas(gcf,strcat(figure_folder,'fig1_exs_cohort.eps'),'epsc');    

%%
figure(6);
plot(100*Bench(:,12)./Bench(:,10),'-b', 'MarkerIndices',1:4:TT), hold on
plot(100*Sunk(:,12)./Sunk(:,10),'--k'), hold on
plot(100*SunkH(:,12)./SunkH(:,10),'-.r'), hold on
plot([0,TT],[0,0], '-k'), hold on

xlim([0,TT]);
xlabel('Years Since Establishment Creation');

format_figure(gca, leg);
saveas(gcf,strcat(figure_folder,'fig1_ex_profit_cohort.eps'),'epsc');    

%%
% Print out a few statistics.
disp('Export Share of Firm Value');
disp([sum(Bench(:,12))/sum(Bench(:,10)) sum(Sunk(:,12))/sum(Sunk(:,10)) sum(SunkH(:,12))/sum(SunkH(:,10))]);
disp('Discounted Export Profit/Aggregate Export Profits');
disp([sum(Bench(:,12))/sum(Bench(:,9)) sum(Sunk(:,12))/sum(Sunk(:,9)) sum(SunkH(:,12))/sum(SunkH(:,9))]);

% Remove the default boxing of the figures and the legend.
function format_figure(gca, leg)
set(gca, 'Box', 'Off');
set(leg, 'box', 'off');
    
end
