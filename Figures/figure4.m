%%
clear all; close all; clc;

figure_folder = 'figures/';
model_folder = 'model outputs/';

set(groot,'defaultLegendAutoUpdate','off') ;
set(groot,'defaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 12);


% model output
bench= xlsread(strcat(model_folder,'RhoHL01.xlsx'),1);
fixed_entry = xlsread(strcat(model_folder,'RhoHL_FixedN01.xlsx'), 1);
sunk= xlsread(strcat(model_folder,'Sunk_Same01.xlsx'),1);
no_cost= xlsread(strcat(model_folder,'NoCost_Sluggish01.xlsx'),1);

% 1	Period   6	n_0    11	NT     16	IntL         21	X
% 2	C        7	n_1    12	N_TE   17	(NT+n_x*NT)  22	(IntT+ta^(-th)*(xiH^(1-th)*IntH+xiL^(1-th)*IntL))
% 3	L        8	n_X    13	IntT   18	K0           23	z0
% 4	EXY      9	OP     14	Int0   19	Y            24	zH
% 5	LP       10	PP     15	IntH   20	W            25	zL
%                                                    26	lambda
%                                                    27	IMD



%% PsiD 
figure(1);
const = 4*(1-0.810087);
plot(100*(bench(:,13)/bench(1,13) - bench(:,11)/bench(1,11))/const,'-blue'), hold on
plot(100*(sunk(:,13)/sunk(1,13) - sunk(:,11)/sunk(1,11))/const,'--k'), hold on
plot(100*(no_cost(:,13)/no_cost(1,13) - no_cost(:,11)/no_cost(1,11))/const,'-or', 'MarkerIndices', 1:5:50), hold on
plot([0,50],[0,0], '-black'), hold on
leg = legend('Benchmark','Sunk','No Cost', 'Location','NorthEast');

ylabel('Change (%)');
ytickformat('%,.1f')
ylim([-0.5,2.5]);xlim([0,50]);

format_figure(gca,leg)
saveas(gcf,strcat(figure_folder,'fig4psid.eps'),'epsc');

%% Wage
figure(2);
jj = 20;
plot(100*log((bench(:,jj)/bench(1,jj))),'-blue'), hold on
plot(100*log((sunk(:,jj)/sunk(1,jj))),'--k'), hold on
plot(100*log((no_cost(:,jj)/no_cost(1,jj))),'-or', 'MarkerIndices', 1:5:50), hold on

ylim([0,15]);xlim([0,50]);
format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig4wage.eps'),'epsc');

%% Output
figure(3);
jj = 19;
plot(100*log((bench(:,jj)/bench(1,jj))),'-blue'), hold on
plot(100*log((sunk(:,jj)/sunk(1,jj))),'--k'), hold on
plot(100*log((no_cost(:,jj)/no_cost(1,jj))),'-or', 'MarkerIndices', 1:5:50), hold on
plot([0,50],[0,0], '-black'), hold on

ylabel('Change (%)');
ylim([-1,12]);xlim([0,50]);

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig4output.eps'),'epsc');

%% Capital
figure(4);
jj = 18;
plot(100*log((bench(:,jj)/bench(1,jj))),'-blue'), hold on
plot(100*log((sunk(:,jj)/sunk(1,jj))),'--k'), hold on
plot(100*log((no_cost(:,jj)/no_cost(1,jj))),'-or', 'MarkerIndices', 1:5:50), hold on
plot([0,50],[0,0], '-black'), hold on

ylim([-5,20]);xlim([0,50]);
format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig4capital.eps'),'epsc');

%% Number of firms
figure(5);
jj = 11;
plot(100*log((bench(:,jj)/bench(1,jj))),'-blue'), hold on
plot(100*log((sunk(:,jj)/sunk(1,jj))),'--k'), hold on
plot(100*log((no_cost(:,jj)/no_cost(1,jj))),'-or','MarkerIndices', 1:5:50), hold on
plot([0,50],[0,0], '-black'), hold on

xlabel('Year');
fylabel=ylabel('Change (%)');
ylim([-15,1]);xlim([0,50]);

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig4firms.eps'),'epsc');
%% Production labor
figure(6);
jj = 5;
plot(100*log((bench(:,jj)/bench(1,jj))),'-blue'), hold on
plot(100*log((sunk(:,jj)/sunk(1,jj))),'--k'), hold on
plot(100*log((no_cost(:,jj)/no_cost(1,jj))),'-or', 'MarkerIndices', 1:5:50), hold on
plot([0,50],[0,0], '-black'), hold on

xlabel('Year');
ylim([-3,4]);xlim([0,50]);

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig4labor.eps'),'epsc');



