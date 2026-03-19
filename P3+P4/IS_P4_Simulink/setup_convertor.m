%%
% Nume si prenume: TODO
%

clearvars
clc

%% Magic numbers (replace with received numbers)
m = 8;
n = 8;

%% Process data and experiment setup (fixed, do not modify)
u_star = 0.15+n*0.045; % trapeze + PRBS amplitudes
delta = 0.02;
delta_spab = 0.015;

E = 12;  % converter source voltage

umin = 0; umax = 0.98; % input saturation
assert(u_star < umax-0.1)
ymin = 0; ymax = 1/(1-u_star)*E*2; % output saturation

% circuit components + parasitic terms
R = 15;
rL = 10e-3;
rC = 0.2;
rDS1 = 0.01;
rDS2 = 0.01;
Cv = 600e-6/3*m;
Lv = 40e-3*3/m;

% (iL0,uC0)
rng(m+10*n)
x0_slx = [(-1)^(n+1)*E/R,E/3/(1-u_star)];

Ts = 1e-5*(1+2*(u_star-0.15)/u_star); % fundamental step size
Ts = round(Ts*1e6)/1e6;

% input white noise power and sampling time
whtn_pow_in = 1e-11*(Ts*1e4)/2; 
whtn_Ts_in = Ts*2;
whtn_seed_in = 23341+m+2*n;
q_in = (umax-umin)/pow2(11); % input quantizer (DAC)

% output white noise power and sampling time
whtn_pow_out = 1e-7*E*(Ts*1e4/50)*(1+(50*u_star)*(u_star-0.15))/3; 
whtn_Ts_out = Ts*2;
whtn_seed_out = 23342-m-2*n;
q_out = (ymax-ymin)/pow2(11); % output quantizer (ADC)

meas_rep = 13+ceil(n/2); % data acquisition hardware sampling limitation

%% Input setup (can be changed/replaced/deleted)
%Tfin = 2; % simulation duration
%t0 = Tfin/4;
%t1 = Tfin/2;
t1=0.25
N=4 % ~ numar de byti la alegere
tr=0.02*4 %t90-t10  %dublam timpu de urcare inmultind cu 4 ca sa vedem mai bine oscilatiile pe iesire, asta dupa ce avem graficul facut( din grafic din poza 1.02-1.00) -tr reprezinta timpul de urcare
p= round(tr/N/Ts) % sa fie peste 1 si sa fim atenti la perioda de esanrtionare)


%u_star=ref pe care am primit o
%delta_spab=cu cat 'enervez sistemul'

% ca sa aflam delta T ul facem   deltaT = p*(2^N-1)*Ts =0.0749 ~ minim atatea secunde
DeltaT = p*(2^N-1)*Ts*1.2;
%DeltaT=0.0749
[input_LUT_dSPACE,Tfin] = generate_input_signal(Ts,t1,DeltaT,N,p,u_star,delta,delta_spab);

%% Data acquisition (use t, u, y to perform system identification)
out = sim("convertor_R2022b_cu_FromWorkspace.slx");

t = out.tout;
u = out.u;
y = out.y;

t = t(1:length(u));

subplot(211)
plot(t,u)
subplot(212)
plot(t,y)

%% System identification

%% 
%TREBUIE ALESE VALORILE NEPARAMETRICE : N - NUMAR DE BYTI , p - divizorul de frecventa , 
%t1>0 minim o perioada care o fost precizata la curs (perioada ii p*N*Te-perioada de esantionare) , delta T - durata Spabului
%cea mai mare durata a unui impuls din spab este N*TS- Comparabila CU TIMPUL DE RIDICARE A SISTEMULUI
