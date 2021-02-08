clear all; close all; clc;

figure_folder = 'figures/';
model_folder  = 'model outputs/';

% Figure defaults
set(groot,'defaultLegendAutoUpdate','off') ;
set(groot,'defaultLineLineWidth', 1.5);
set(0,'defaultAxesFontSize', 12)

% Model output
onetime = xlsread(strcat(model_folder,'RhoHL01.xlsx'), 1);
gradual= xlsread(strcat(model_folder,'RhoHL_tafalls20.xlsx'), 1);
future = xlsread(strcat(model_folder,'RhoHL_futurecut.xlsx'), 1);
% File is from benchmark/smalltariffcut/RhoHL01.xlsx
benchsmalltariff = xlsread(strcat(model_folder,'bench_smalltariffcut_RhoHL01.xlsx'), 1);


% 1	Period   6	n_0    11	NT     16	IntL         21	X
% 2	C        7	n_1    12	N_TE   17	(NT+n_x*NT)  22	(IntT+ta^(-th)*(xiH^(1-th)*IntH+xiL^(1-th)*IntL))
% 3	L        8	n_X    13	IntT   18	K0           23	z0
% 4	EXY      9	OP     14	Int0   19	Y            24	zH
% 5	LP       10	PP     15	IntH   20	W            25	zL
%                                                    26	lambda
%                                                    27	IMD


%% Create the perpetual surprise transition
surprise = log(benchsmalltariff(1:1,[2,11,12,19,27])./benchsmalltariff(1,[2,11,12,19,27]));

for i=3:1:21 %Each of these is an additional cut
    surprise= [surprise; 0.05*sum(log(onetime(2:i,[2,11,12,19,27])./onetime(1,[2,11,12,19,27])))];
end

for i=22:1:300
    surprise= [surprise; 0.05*sum(log(onetime((i-19):i,[2,11,12,19,27])./onetime(1,[2,11,12,19,27])))];
end


TT=25;


%% Consumption growth
jj=2;
figure(1);
plot(100* log(onetime(1:TT,jj)./onetime(1,jj)), '-b'), hold on
plot(100* log(gradual(1:TT,jj)./gradual(1,jj)), '-.r'), hold on
plot(100* surprise(1:TT,1), '-g'), hold on
plot(100* log(future(1:TT,jj)./future(1,jj)), '--k'), hold on

ylabel('Change (percent)');
xlabel('Years');
format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig8c.eps'),'epsc');

%% Trade share growth
jj = 27;
figure(2);
plot(100*log(onetime(1:TT,jj)./onetime(1,jj)), '-b'), hold on
plot(100*log(gradual(1:TT,jj)./gradual(1,jj)), '-.r'), hold on
plot(100*surprise(1:TT,5), '-g'), hold on
plot(100*log(future(1:TT,jj)./future(1,jj)), '--k'), hold on

leg = legend('Once-and-for-all','Gradual-foreseen','Gradual-surprise', 'Future', 'Location', 'Southeast');

ylabel('Change (percent)')
xlabel('Years');
format_figure(gca, leg);
saveas(gcf,strcat(figure_folder,'fig8a.eps'),'epsc');

%% Entrants
figure(3);
plot(100*onetime(1:30,27),log(onetime(1:30,12)./onetime(1,12)), '-b'), hold on
plot(100*gradual(1:30,27),log(gradual(1:30,12)./gradual(1,12)),'-.r'), hold on
plot(100*onetime(1,27).*exp(surprise(1:TT,5)), surprise(1:TT,3),'-g'), hold on
plot(100*future(1:TT,27), log(future(1:TT,12)./future(1,12)), '--k'), hold on

xlabel('Years');
format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig8b.eps'),'epsc');

%% Entry rate
figure(4);
plot(100*onetime(1:30,27),log(onetime(1:30,12)./onetime(1:30,11)) - log(onetime(1,12)./onetime(1,11)), '-b' ), hold on
plot(100*gradual(1:30,27),log(gradual(1:30,12)./gradual(1:30,11)) - log(gradual(1,12)./gradual(1,11)) ,'-.r'), hold on
plot(100*onetime(1,27).*exp(surprise(1:TT,5)), (surprise(1:TT,3) - surprise(1:TT,2)),'-g'), hold on
plot(100*future(1:TT,27), log(future(1:TT,12)./future(1,11)) - log(future(1,12)./future(1,11)), '--k' ), hold on

xlabel('Trade share (percent)');
format_figure(gca);
saveas(gcf,strcat(figure_folder,'fig8d.eps'),'epsc');


