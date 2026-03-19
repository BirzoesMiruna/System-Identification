%%
% Nume si prenume: TODO
%

clearvars
clc

%% Magic numbers (replace with received numbers)
m = 2;
n = 1;

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
% Cu datele noastre
Tfin = 2; % simulation duration
t0 = Tfin/4;
t1 = Tfin/2;


t1=0.05
N=5% ~ numar de byti la alegere
tr=0.08 %t90-t10  %dublam timpu de urcare inmultind cu 4 ca sa vedem mai bine oscilatiile pe iesire, asta dupa ce avem graficul facut( din grafic din poza 1.02-1.00) -tr reprezinta timpul de urcare
p= round(tr/N/Ts) % sa fie peste 1 si sa fim atenti la perioda de esanrtionare)


%u_star=ref pe care am primit o
%delta_spab=cu cat 'enervez sistemul'

% ca sa aflam delta T ul facem   deltaT = p*(2^N-1)*Ts =0.0749 ~ minim atatea secunde
DeltaT = p*(2^N-1)*Ts;
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
i1=28525;
i2=94722;
i3=122462;
i4=188435;

N_dec=14;

t_id= t(i1:N_dec:i2);
u_id= u(i1:N_dec:i2);
u_id=u_id- mean(u_id); %rafinare dc 
y_id= y(i1:N_dec:i2);
y_id=y_id- mean(y_id); 

t_vd= t(i3:N_dec:i4);
u_vd= u(i3:N_dec:i4);
u_vd=u_vd- mean(u_vd);
y_vd= y(i3:N_dec:i4);
y_vd=y_vd- mean(y_vd); 

%%
figure 
subplot (2,2,1)
plot(t_id,u_id); 

subplot(223)
plot(t_id,y_id);

subplot(222)
plot(t_vd,u_vd);

subplot(224)
plot(t_vd,y_vd);

dat_id = iddata(y_id,u_id,t_id(2)-t_id(1));
dat_vd = iddata(y_vd,u_vd,t_vd(2)-t_vd(1));




%%
model_arx=arx(dat_id,[2,2,1]); % avem 3 parametri de structura
figure,resid(model_arx,dat_vd)
figure,compare(model_arx,dat_vd)
%%
model_armax=armax(dat_id,[2,2,4,1]) % (dat_id,[nA nB nC nd) avem 4 parametrri de structura nA nB nD - care i i am gasit mai sus + nC care se ia prin incercari (nA,nB,nC,nD)
figure,resid(model_armax,dat_vd)
figure,compare(model_armax,dat_vd)
%%
% Aplicarea tehnicii de rafinare PEM pe modelul ARMAX existent
model_armax_rafinat = pem(dat_id, model_armax);

figure;
compare(dat_vd, model_armax, model_armax_rafinat); % Vezi daca FIT-ul creste peste 86.7%
%%
%Testam modelul IV4 ( instrument variables)
model_iv4=iv4(dat_id,[2 2 1]);
figure,resid(model_iv4,dat_vd); 
figure,compare(model_iv4,dat_vd);
%%
%Testamo modelul OE
model_oe=oe(dat_id,[2,2,1])
figure,resid(model_oe,dat_vd)
figure,compare(model_oe,dat_vd)
%%
% Testam modelul Box Jenkins
model_bj=bj(dat_id,[2 2 1 2 1]);
figure,resid(model_bj,dat_vd);
figure,compare(model_bj,dat_vd);
%%
model_n4sid=n4sid(dat_id,1:15); %matricea huncle
figure ,resid(model_n4sid,dat_vd);
figure, compare (model_n4sid,dat_vd);
%%
% daca nu merge cu niciun model, incercam sa folosim tehnici de RAFINARE 
%modificam DC ul de exemplu sau facem decimarea datelor cu N(numarul cu
%sagetile din grafic cate puncte is)

%%
% incercam cu un model in spatiul starilor
model_n4sid=n4sid(dat_id,1:15);
figure,resid(model_n4sid,dat_vd)
figure,compare(model_n4sid,dat_vd)
%%
model_ssest=ssest(dat_id,1:15);
figure,resid(model_ssest,dat_vd)
figure,compare(model_ssest,dat_vd)