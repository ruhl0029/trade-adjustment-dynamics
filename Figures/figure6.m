clear all; close all; clc;

set(groot,'defaultLegendAutoUpdate','off') ;
set(groot,'defaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 12);

figure_folder = 'figures/';
model_folder = 'model outputs/';

lwidth = 1.5;
asize = 12;
fsize = 12;
pw = 8.5;
ph = 11;
lsize = 6;

% model output
filename1 = 'Tran_new.xlsx';   
bench= xlsread(strcat(model_folder,filename1),1);
benchlog= xlsread(strcat(model_folder,filename1),10); % log prefs
benchR5= xlsread(strcat(model_folder,filename1),11);  % r = 5
benchR2= xlsread(strcat(model_folder,filename1),12);  % r = 2

obs=50;

%% Consumption
figure(1)
plot(100*log((bench(:,2)/bench(1,2))),'-b'), hold on
plot(100*log((benchlog(:,2)/benchlog(1,2))),'-.r'), hold on
plot(100*log((benchR5(:,2)/benchR5(1,2))),'--k'), hold on
plot(100*log((benchR2(:,2)/benchR2(1,2))),'-sb', 'MarkerIndices', 1:5:obs), hold on

leg = legend('Benchmark','Log preferences','5 % interest rate','2 % interest rate','location', 'best','FontSize',14);

ylabel('Change (%)');
ylim([0,16]);xlim([0,obs]); 
set(gca,'XTick',0:10:obs)

format_figure(gca, leg);
saveas(gcf,strcat(figure_folder,'fig6_consumption.eps'),'epsc');

%% Capital
figure(2);
plot(100*log((bench(:,18)/bench(1,18))),'-b'), hold on
plot(100*log((benchlog(:,18)/benchlog(1,18))),'-.r'), hold on
plot(100*log((benchR5(:,18)/benchR5(1,18))),'--k'), hold on
plot(100*log((benchR2(:,18)/benchR2(1,18))),'-sb', 'MarkerIndices', 1:5:obs), hold on
plot([0 100],[0 0],'k');

ylim([-4,18]);xlim([0,obs]); 
set(gca,'XTick',0:10:obs)

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig6_capital.eps'),'epsc');

%% Establishments
figure(3);
plot(100*log((bench(:,11)/bench(1,11))),'-b'), hold on
plot(100*log((benchlog(:,11)/benchlog(1,11))),'-.r'), hold on
plot(100*log((benchR5(:,11)/benchR5(1,11))),'--k'), hold on
plot(100*log((benchR2(:,11)/benchR2(1,11))),'-sb', 'MarkerIndices', 1:5:obs), hold on
plot([0 100],[0 0],'k');

ylabel('Change (%)');
xlabel('Years');
ylim([-16,1]);xlim([0,obs]); 
set(gca,'XTick',0:10:obs)

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig6_establishments.eps'),'epsc');

%% Elasticity
figure(4);
plot(log((bench(:,27)/bench(1,27)))/log(1.1),'-b'), hold on
plot(log((benchlog(:,27)/benchlog(1,27)))/log(1.1),'-.r'), hold on
plot(log((benchR5(:,27)/benchR5(1,27)))/log(1.1),'--k'), hold on
plot(log((benchR2(:,27)/benchR2(1,27)))/log(1.1),'-sb', 'MarkerIndices', 1:5:obs), hold on

ylim([0,12]);xlim([0,obs]); 
set(gca,'XTick',0:10:obs)
xlabel('Years');
format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig6_elasticity.eps'),'epsc');