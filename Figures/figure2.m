%%
clear all; close all; clc;

figure_folder = 'figures/';
model_folder = 'model outputs/';

set(groot,'defaultLegendAutoUpdate','off') ;
set(groot,'defaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 12);

% Figure sizes
pw = 650;
ph = 250;

% model output
bench= xlsread(strcat(model_folder,'RhoHL01.xlsx'), 1);

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

plot(log((bench(:,jj)/bench(1,jj)))/log(1.1),'-k'), hold on

ylim([0,15]);xlim([0,25]);
ylabel('Elasticity');

format_figure(gca);
saveas(gcf, strcat(figure_folder,'fig2_elast.eps'), 'epsc');


%% C, W, Y, Lp

figure('Position', [100,100,pw,ph], 'Name','');

jj = 2;  % var to plot
plot(100*log((bench(:,jj)/bench(1,jj))),'-blue'), hold on

jj = 20;  % var to plot
plot(100*log((bench(:,jj)/bench(1,jj))),'-.red'), hold on

jj = 19;  % var to plot
plot(100*log((bench(:,jj)/bench(1,jj))),'--black'), hold on

jj = 5;  % var to plot
plot(100*log((bench(:,jj)/bench(1,jj))),'-sblue', 'MarkerIndices', 1:5:50), hold on

plot([0,50], [0,0], 'color', [0.5, 0.5, 0.5]), hold on

leg = legend('Consumption', 'Wage', 'Output', 'Prod. Labor','NumColumns', 2);
ylabel('Change (%)');
ylim([-5,15]);xlim([0,50]);


format_figure(gca, leg);
saveas(gcf,strcat(figure_folder,'fig2_cwylp.eps'),'epsc');


%% K, Ne, N
figure('Position', [100,100,pw,ph], 'Name','');

jj = 18;  % var to plot
plot(100*log((bench(:,jj)/bench(1,jj))),'-blue'), hold on

jj = 12;  % var to plot
plot(100*log((bench(:,jj)/bench(1,jj))),'-.red'), hold on

jj = 11;  % var to plot
plot(100*log((bench(:,jj)/bench(1,jj))),'--black'), hold on

plot([0,50], [0,0], 'color', [0.5, 0.5, 0.5]), hold on


ylabel('Change (%)');
xlabel('Years');
ylim([-20,20]);xlim([0,50]);
leg = legend('Capital', 'Entrants', 'Estabs.', 'NumColumns', 2);

format_figure(gca, leg);
saveas(gcf,strcat(figure_folder,'fig2_knen.eps'),'epsc');
