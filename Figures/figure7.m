clear all; close all; clc;

set(groot,'defaultLegendAutoUpdate','off') ;
set(groot,'defaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 12);

figure_folder = 'figures/';
model_folder = 'model outputs/';

filename = 'BenchUni_HC.xlsx';
UniBond = xlsread(strcat(model_folder,filename),1);
UniComp = xlsread(strcat(model_folder,filename),2);
UniFA   = xlsread(strcat(model_folder,filename),3);
UniSlug = xlsread(strcat(model_folder,filename),4);


temp = [2;3;16; 17;43; 50; 36; 37; 38; 39; 40; 41];


%% Consumption
obs = 50;
figure(1);
plot(100*log((UniBond(1:obs,temp(1))/UniBond(1,temp(1)))),'-blue'), hold on
plot(100*log((UniComp(1:obs,temp(1))/UniComp(1,temp(1)))),'-.r'), hold on
plot(100*log((UniFA(1:obs,temp(1))/UniFA(1,temp(1)))),'--k'), hold on
plot(100*log((UniSlug(1:obs,temp(1))/UniSlug(1,temp(1)))),'-sb','MarkerIndices',1:5:obs), hold on
plot([0 50],[0 0],'k')

ylabel('Change (%)');
ylim([-3,8])
set(gca,'XTick',0:10:obs)
leg = legend('Bond','Complete','Fin. Autarky','No-cost');

format_figure(gca, leg);
saveas(gcf,strcat(figure_folder,'fig7_uni_consumption.eps'),'epsc');
    
%% Consumption*
figure(2);
plot(100*log((UniBond(1:obs,temp(2))/UniBond(1,temp(2)))),'-blue'), hold on
plot(100*log((UniComp(1:obs,temp(2))/UniComp(1,temp(2)))),'-.r'), hold on
plot(100*log((UniFA(1:obs,temp(2))/UniFA(1,temp(2)))),'--k'), hold on
plot(100*log((UniSlug(1:obs,temp(2))/UniSlug(1,temp(2)))),'-sb','MarkerIndices',1:5:obs), hold on
plot([0 50],[0 0],'k')

ylim([-1,8])
set(gca,'XTick',0:10:obs)

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig7_uni_consumption_f.eps'),'epsc');
 
%% Entry
figure(3);
plot(100*log((UniBond(1:obs,temp(3))/UniBond(1,temp(3)))),'-b'), hold on
plot(100*log((UniComp(1:obs,temp(3))/UniComp(1,temp(3)))),'-.r'), hold on
plot(100*log((UniFA(1:obs,temp(3))/UniFA(1,temp(3)))),'--k'), hold on
plot(100*log((UniSlug(1:obs,temp(3))/UniSlug(1,temp(3)))),'-sb','MarkerIndices',1:5:obs), hold on
plot([0 50],[0 0],'k')

ylabel('Change (%)');
ylim([-12,2])
set(gca,'XTick',0:10:obs)

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig7_uni_entry_h.eps'),'epsc');

%% Entry*
figure(4);
plot(100*log((UniBond(1:obs,temp(4))/UniBond(1,temp(4)))),'-b'), hold on
plot(100*log((UniComp(1:obs,temp(4))/UniComp(1,temp(4)))),'-.r'), hold on
plot(100*log((UniFA(1:obs,temp(4))/UniFA(1,temp(4)))),'--k'), hold on
plot(100*log((UniSlug(1:obs,temp(4))/UniSlug(1,temp(4)))),'-sb','MarkerIndices',1:5:obs), hold on
plot([0 50],[0 0],'k')

ylim([-12,2])
set(gca,'XTick',0:10:obs)

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig7_uni_entry_f.eps'),'epsc');

%% RER
figure(5);
plot(100*log((UniBond(1:obs,temp(5))/UniBond(1,temp(5)))),'-b'), hold on
plot(100*log((UniComp(1:obs,temp(5))/UniComp(1,temp(5)))),'-.r'), hold on
plot(100*log((UniFA(1:obs,temp(5))/UniFA(1,temp(5)))),'--k'), hold on
plot(100*log((UniSlug(1:obs,temp(5))/UniSlug(1,temp(5)))),'-sb', 'MarkerIndices',1:5:obs), hold on

ylabel('Change (%)');
ylim([0,6]);
set(gca,'XTick',0:10:obs)
xlabel('Years');

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig7_uni_rer.eps'),'epsc');


%% NX/GDP 
figure(6);
plot(100*((UniBond(1:obs,temp(6))-UniBond(1,temp(6)))),'-b'), hold on
plot(100*((UniComp(1:obs,temp(6))-UniComp(1,temp(6)))),'-.r'), hold on
plot(100*((UniSlug(1:obs,temp(6))-UniSlug(1,temp(6)))),'-sb', 'MarkerIndices',1:5:obs), hold on
plot([0 50],[0 0],'k')

ylim([-3.0,1]);xlim([0,obs]);
set(gca,'XTick',0:10:obs)
ytickformat('%.1f')
xlabel('Years');

format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig7_uni_nx.eps'),'epsc');
