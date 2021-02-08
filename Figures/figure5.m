clear all; close all; clc;

set(groot,'defaultLegendAutoUpdate','off') ;
set(groot,'defaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 12);

figure_folder = 'figures/';
model_folder = 'model outputs/';

pw = 8.5;
ph = 11;
lsize = 6;

% model output
bench= xlsread(strcat(model_folder,'RhoHL01.xlsx'),1);


%%
% CALCULATE THE DECOMPOSITION IN THE BENCHMARK MODEL
% Y = (PSID-lambda)/(th-1)(1-alpham) + Lp +alpha*(K/L) +S

alpha = 0.13247214;
alpham = 0.81008870;

adj = 1/(4*(1-alpham));
YY = log((bench(:,19)/bench(1,19))); 
TV = adj*(log((bench(:,13)/bench(1,13))) - log((bench(:,26)/bench(1,26))));
Lp = log((bench(:,5)/bench(1,5)));
NN = log((bench(:,11)/bench(1,11)))/adj;
PSID = (log((bench(:,13)/bench(1,13)))-log((bench(:,11)/bench(1,11))))/adj;
LAMBDA = -log((bench(:,26)/bench(1,26)))/adj;
KLP = alpha*(log((bench(:,18)/bench(1,18)))-log((bench(:,5)/bench(1,5))));
CY = bench(:,2)./bench(:,19);
CY =log(CY/CY(1,1));
S = bench(:,28) - alpham*(0.8);
Shat = log((S/S(1,1)));
YY - TV - Lp - KLP - Shat;
DECOMP = [YY TV Lp KLP Shat LAMBDA PSID NN];

l = length(bench);

%%
plot(100*log((bench(:,19)/bench(1,19))),'-blue'), hold on % Y
plot(100*log((bench(:,5)/bench(1,5))),'-.r'), hold on %Labor in Production
plot(100*KLP,'--k', 'MarkerSize', 6, 'MarkerIndices',1:10:l), hold on
plot(100*Shat,'-sb', 'MarkerIndices', 1:5:50), hold on
plot(100*adj*log((bench(:,11)/bench(1,11)))/adj,'-or', 'MarkerIndices', 1:5:50), hold on % N
plot(100*adj*(log((bench(:,13)/bench(1,13)))-log((bench(:,11)/bench(1,11)))),':k'), hold on % Efficiency
plot(-100*adj*log((bench(:,26)/bench(1,26))),'-*b', 'MarkerIndices', 1:5:50), hold on % lambda

h=legend('Y','L_p','\alpha (K/Lp)','S', 'N', '\psi_d', '\lambda', 'location', 'best', 'NumColumns',4);
set(h,'Position',[0.52,0.68,0.25,0.12]);

ylabel('Change (%)');
xlabel('Years');
plot([0 100],[0 0],'k'); xlim([0,50]);
set(gca,'XTick',0:10:50)

format_figure(gca, h);
saveas(gcf,strcat(figure_folder,'fig5.eps'), 'epsc');