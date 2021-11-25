%%%%%%%              ALGORITMOS DE ESTIMAÇÃO 
%
% 10.03.21



clc
clear all
close all

set(0, 'defaultAxesFontSize',12);
set(0, 'defaultAxesFontName','times');
pasta = 'D:\Google Drive\MATLAB\QUALI\ESTIMADORES\Resultados\';

% ---------------------------------------------------------------------
% INICIALIZAÇÕES

N = 256;      % número de amostras
m = 32;      % passo de janelamento
Fs = 12800;   % Taxa de amostragem
f0 = 50;      % freq. fundamental (teórica)
noise = 80;    % nível de ruído em dB ( 0 = sem ruído)
T = 0.5;        % tempo total (em segundos)
param = 0;   % amort(w);    % freq. de modulação, por exemplo
type = 0;     % seleciona tipo de teste (ver gerador_sinais.m)

freqs = [50];        % Vetor de frequências

phases = zeros(3,2);
% phases = [0 0;           % vetor de fases
%          -2*pi/3 0;
%          +2*pi/3 0];    
phases(1,1) = deg2rad(0);
phases(2,1) = deg2rad(-120);
phases(3,1) = deg2rad(+120);

amps = [1 0.3;           % vetor de amplitudes
        1 0.3;
        1 0.3]; 

% ------------------------------------------------------------------------------------------------------------------
% GERAÇÃO DO SINAL
[Va, Vb, Vc, t, refs, mod] = gerador_sinais(f0, freqs, phases, amps,Fs, T,noise, type, param);

% figure, hold on, grid on, plot(t,Va, 'o-'), plot(t,Vb),plot(t,Vc) ,plot(t,mod*10)
% legend('Va','Vb','Vc'), title('Sinais'),xlabel('tempo (s)'), ylabel('amplitude')
[~,~,~,~, ref_seg] = segmentador(Va, Vb, Vc, t, refs, N, m); % gera referências
% save('D:\Google Drive\MATLAB\QUALI\ESTIMADORES\Resultados\ref_seg.mat','ref_seg')
% figure, hold on, grid on, plot(ref_seg(2,:))

%------------------------------------------------------------------------------------
% ESTIMADOR

% DFT completo
[A_dft, ~, ~, phi_dft, ~, ~, f_dft] = estimador_dft_completo(Va, Vb, Vc, t, refs, N, m, Fs,f0);
%save('D:\Google Drive\MATLAB\QUALI\ESTIMADORES\Resultados\0_dft.mat','A_dft','phi_dft','f_dft')



%--------------------------------------------------------------------------------------------------------------------
% CÁLCULO DE ERROS
i=2;
f=length(A_dft(:,1))-1;

a=1;
amp_med(a,:) = A_dft(i:f,2)'; a=a+1;

b=1;
fase_med(b,:) = phi_dft(i:f,2)'; b=b+1;

c=1;
freq_med(c,:) = f_dft(1,i:f); c=c+1;


ref_seg = ref_seg(:,i:f);

[tve, amp_error, phase_error, freq_error] = calcula_erros(amp_med, fase_med, freq_med, ref_seg);




figure
subplot(2,1,1),hold on, grid on, plot(ref_seg(2,:)', 'black'), plot(amp_med'), title('amplitude'), xlabel('medição'), ylabel('amplitude (%)')
subplot(2,1,2),hold on, grid on, plot(ref_seg(5,:)', 'black'), plot(fase_med'),title('fase'), xlabel('medição'), ylabel('angle (deg)')
legend('Ref','DFT','HW-FFT','Prony','Esparso')
movegui('northwest');


figure
subplot(2,1,1), hold on, grid on, plot(ref_seg(1,:),'black'), plot(freq_med')
title('Frequência'), xlabel('medição'), ylabel('frequência (Hz)')
subplot(2,1,2),hold on, grid on, plot(freq_error')
legend('Ref','DFT','HW-FFT','Prony','Esparso')
movegui('north');
%figure, hold on, grid on, plot(freq_error')



figure, x0=500; y0=100; width=500;height=600; set(gcf,'position',[x0,y0,width,height]);
subplot(3,1,1),hold on, grid on, plot(tve'), title('TVE'), xlabel('amostra'), ylabel('TVE (%)')
subplot(3,1,2),hold on, grid on, plot(amp_error'), title('Erro de amplitude'), xlabel('amostra'), ylabel('erro de amplitude(%)')
subplot(3,1,3),hold on, grid on, plot(phase_error'), title('Erro de ângulo'), xlabel('amostra'), ylabel('erro de ângulo (°)')
%legend('DFT','HW-FFT','Prony','Esparso')
movegui('northeast');

% arquivo = '3_DFT.mat';
% filename = strcat(pasta,arquivo);
%save(filename, 'tve','amp_error','phase_error','freq_error');
 
%max(tve(3,:))

