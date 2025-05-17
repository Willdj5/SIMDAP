% Intialise constants for the SIM
clear
clc
close all

%% STUFF TO DO
% 1. finish UAV_model3 with more damping so should equailise out much
% better
% 2. implement variable density with hieght
% 3. issue with reynolds number - changes the CLMAX massively

%% Define constants
% Intial velocity and angles
x0 = [38;
      0;
      0;
      0;
      0;
      0;
      0 *pi/180; % Roll
      0 *pi/180; % Pitch
      0 *pi/180]; % Yaw

% Deflections
u = [0 *pi/180; % Aileron
     0 *pi/180; % Elevator
     0 *pi/180; % Rudder
     150];% Throttle

% Inital height
z0 = -500;

% TF = 60*55;
TF = 60*3;

store = struct;
store.CL = [];
store.CLt = [];
store.Cm = [];
store.CY = [];
store.Cn = [];
store.Cl = [];
store.n = [];
store.time = [];
save('DataStoreLastRun.mat', 'store')

% Time - Angle - 0
mission = struct;

%% Mission
phase1end = 120;
phase2end = phase1end + 500;
phase3end = phase2end + 1660;
phase4end = phase3end + 600;
mission.bank = [phase2end + 60, 75, 0;
                phase2end + 260, -75, 0;
                phase2end + 460, 75, 0;
                phase2end + 660, -75, 0;
                phase2end + 860, 75, 0;
                phase2end + 1060, -75, 0;
                phase2end + 1260, 75, 0;
                phase2end + 1460, -75, 0;
                phase2end + 1660, 75, 0];
mission.bank_angle = 0;

mission.pitch = [30, 30, 0;
                 60, 30, 0;
                 90, 30, 0;
                 120, 30, 0;
                 phase4end + 200, -30, 0];
mission.pitch_angle = 0;

mission.yaw = [phase1end + 100, 20, 0;
               phase1end + 200, 40, 0;
               phase1end + 300, -10, 0;
               phase3end + 100, 180, 0;
               phase3end + 300, 190, 0];
mission.yaw_angle = 0;
saveDir = 'C:\Users\Will\OneDrive\Documents\Uni year 3\UAS Project\Reporting\Results\temp';
phaseName = 'temp';

%% Dutch Roll
% mission.bank = [60, 10, 0;
%                 70, -10, 0;
%                 80, 10, 0;
%                 90, -10, 0;
%                 100, 10, 0;
%                 110, -10, 0];
% mission.bank_angle = 0;
% 
% mission.pitch = [0, 0, 0;
%                  0, 0, 0];
% mission.pitch_angle = 0;
% 
% mission.yaw = [60, -10, 0;
%                 70, 10, 0;
%                 80, -10, 0;
%                 90, 10, 0;
%                 100, -10, 0;
%                 110, 10, 0];
% mission.yaw_angle = 0;
% saveDir = 'C:\Users\Will\OneDrive\Documents\Uni year 3\UAS Project\Reporting\Results\Dutch Roll';
% phaseName = 'dutch';

%% Base
% mission.bank = [0, 0, 0;
%                 0, 0, 0];
% mission.bank_angle = 0;
% 
% mission.pitch = [0, 0, 0;
%                  0, 0, 0];
% mission.pitch_angle = 0;
% 
% mission.yaw = [0, 0, 0;
%                0, 0, 0];
% mission.yaw_angle = 0;
% saveDir = 'C:\Users\Will\OneDrive\Documents\Uni year 3\UAS Project\Reporting\Results\Trim';
% phaseName = 'trim';

%% Short
% mission.bank = [0, 0, 0;
%                 0, 0, 0];
% mission.bank_angle = 0;
% 
% mission.pitch = [60, 30, 0;
%                  0, 0, 0];
% mission.pitch_angle = 0;
% 
% mission.yaw = [0, 0, 0;
%                0, 0, 0];
% mission.yaw_angle = 0;
% saveDir = 'C:\Users\Will\OneDrive\Documents\Uni year 3\UAS Project\Reporting\Results\Short Period';
% phaseName = 'short';

%% Roll Sub
% mission.bank = [60, 90, 0;
%                 0, 0, 0];
% mission.bank_angle = 0;
% 
% mission.pitch = [0, 0, 0;
%                  0, 0, 0];
% mission.pitch_angle = 0;
% 
% mission.yaw = [0, 0, 0;
%                0, 0, 0];
% mission.yaw_angle = 0;
% saveDir = 'C:\Users\Will\OneDrive\Documents\Uni year 3\UAS Project\Reporting\Results\Roll Subsidence';
% phaseName = 'rollsub';

%% Spiral
% mission.bank = [20, 6000, 0;
%                 0, 0, 0];
% mission.bank_angle = 0;
% 
% mission.pitch = [0, 0, 0;
%                  0, 0, 0];
% mission.pitch_angle = 0;
% 
% mission.yaw = [0, 0, 0;
%                0, 0, 0];
% mission.yaw_angle = 0;
% saveDir = 'C:\Users\Will\OneDrive\Documents\Uni year 3\UAS Project\Reporting\Results\Spiral';
% phaseName = 'spiral';

%% Phugoid
% mission.bank = [0, 0, 0;
%                 0, 0, 0];
% mission.bank_angle = 0;
% 
% mission.pitch = [0, 0, 0;
%                  0, 0, 0];
% mission.pitch_angle = 0;
% 
% mission.yaw = [0, 0, 0;
%                0, 0, 0];
% mission.yaw_angle = 0;
% saveDir = 'C:\Users\Will\OneDrive\Documents\Uni year 3\UAS Project\Reporting\Results\Phugoid';
% phaseName = 'glide';

% saveDir = 'C:\Users\Will\OneDrive\Documents\Uni year 3\UAS Project\Reporting\Results\temp';
% phaseName = 'temp';

save('missionStore.mat', 'mission')

%% Run the model
sim('SIM.slx')

%% Plot results
t = ans.simX.Time;

u1 = ans.simU.Data(:,1);
u2 = ans.simU.Data(:,2);
u3 = ans.simU.Data(:,3);
u4 = ans.simU.Data(:,4);

x1 = ans.simX.Data(:,1);
x2 = ans.simX.Data(:,2);
x3 = ans.simX.Data(:,3);
x4 = ans.simX.Data(:,4);
x5 = ans.simX.Data(:,5);
x6 = ans.simX.Data(:,6);
x7 = ans.simX.Data(:,7);
x8 = ans.simX.Data(:,8);
x9 = ans.simX.Data(:,9);

x1A = ans.simXA.Data(:,1);
x2A = ans.simXA.Data(:,2);
x3A = ans.simXA.Data(:,3);

X = ans.simZ.Data(:,1);
Y = ans.simZ.Data(:,2);
Z = ans.simZ.Data(:,3);

%% Axial Velocities
figure
set(gcf, 'Position', [100 100 800 800]) 
subplot(3,1,1)
plot(t, x1A, 'k')
ylabel('x Axial Velocity ($x_{axial}$) ($m/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(3,1,2)
plot(t, x2A, 'k')
ylabel('y Axial Velocity ($y_{axial}$) ($m/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(3,1,3)
plot(t, x3A, 'k')
ylabel('z Axial Velocity ($z_{axial}$) ($m/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

fileName = sprintf('%saxial.eps', lower(phaseName));
fullPath = fullfile(saveDir, fileName);
print('-depsc', fullPath);

%% Control Inputs
figure
set(gcf, 'Position', [100 100 800 800]) 
subplot(4,1,1)
plot(t, 180/pi .* u1, 'k')
ylabel('Aileron deflec ($\delta_a$) (deg)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(4,1,2)
plot(t, 180/pi .* u2, 'k')
ylabel('Elevator deflec ($\delta_e$) (deg)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(4,1,3)
plot(t, 180/pi .* u3, 'k')
ylabel('Rudder deflec ($\delta_r$) (deg)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(4,1,4)
plot(t, u4, 'k')
ylabel('Thrust ($\delta_t$) (N)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

fileName = sprintf('%sdeflec.eps', lower(phaseName));
fullPath = fullfile(saveDir, fileName);
print('-depsc', fullPath);

%% TEMP
figure
set(gcf, 'Position', [100 100 800 800])
storeData = load('DataStoreLastRun.mat');
n = storeData.store.n;
time = storeData.store.time;

subplot(2,1,1)
plot(time, n, 'k')
ylabel('$n$', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(2,1,2)
plot(t, 180/pi .* u2, 'k')
ylabel('Elevator deflec ($\delta_e$) (deg)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

%% Body V and AoA
Va = sqrt(x1.^2 + x2.^2 + x3.^2);
figure
set(gcf, 'Position', [100 100 800 800]) 
subplot(3,1,1)
plot(t, Va, 'k')
ylabel('Total Body Velocity ($m/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

alpha = atan2(x3, x1);
subplot(3,1,2)
plot(t, 180/pi .* alpha, 'k')
ylabel('AoA ($\alpha$) (deg)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

beta = atan2(x2, x1);
subplot(3,1,3)
plot(t, 180/pi .* beta, 'k')
ylabel('beta ($\beta$) (deg)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

fileName = sprintf('%sAoA.eps', lower(phaseName));
fullPath = fullfile(saveDir, fileName);
print('-depsc', fullPath);

%% Longatudinal constants
figure
set(gcf, 'Position', [100 100 800 800]) 
storeData = load('DataStoreLastRun.mat');
CL = storeData.store.CL;

subplot(3,1,1)
plot(time, CL, 'k')
ylabel('$C_L$', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

storeData = load('DataStoreLastRun.mat');
CLt = storeData.store.CLt;

subplot(3,1,2)
plot(time, CLt, 'k')
ylabel('$C_{L_T}$', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

storeData = load('DataStoreLastRun.mat');
Cm = storeData.store.Cm;

subplot(3,1,3)
plot(time, Cm, 'k')
ylabel('$C_m$', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

fileName = sprintf('%sCL.eps', lower(phaseName));
fullPath = fullfile(saveDir, fileName);
print('-depsc', fullPath);

%% Lateral constants
figure
set(gcf, 'Position', [100 100 800 800]) 
storeData = load('DataStoreLastRun.mat');
CY = storeData.store.CY;

subplot(3,1,1)
plot(time, CY, 'k')
ylabel('$C_Y$', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

storeData = load('DataStoreLastRun.mat');
Cn = storeData.store.Cn;

subplot(3,1,2)
plot(time, Cn, 'k')
ylabel('$C_n$', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

storeData = load('DataStoreLastRun.mat');
Cl = storeData.store.Cl;

subplot(3,1,3)
plot(time, Cl, 'k')
ylabel('$C_l$', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

fileName = sprintf('%sCY.eps', lower(phaseName));
fullPath = fullfile(saveDir, fileName);
print('-depsc', fullPath);

%% Plot states
figure
set(gcf, 'Position', [100 100 1000 800])
% u, v, w
subplot(3,3,1)
plot(t, x1, 'k')
ylabel('x Body Velocity ($x_{body}$) ($m/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(3,3,4)
plot(t, x2, 'k')
ylabel('y Body Velocity ($y_{body}$) ($m/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(3,3,7)
plot(t, x3, 'k')
ylabel('z Body Velocity ($z_{body}$) ($m/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

% q, r, s
subplot(3,3,2)
plot(t, x4, 'k')
ylabel('x Angular Velocity ($p$) ($rad/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(3,3,5)
plot(t, x5, 'k')
ylabel('y Angular Velocity ($q$) ($rad/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(3,3,8)
plot(t, x6, 'k')
ylabel('z Angular Velocity ($r$) ($rad/s$)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

% phi, theta, psi
subplot(3,3,3)
plot(t, x7, 'k')
ylabel('x Angle ($\phi$) (rad) (roll angle)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(3,3,6)
plot(t, x8, 'k')
ylabel('y Angle ($\theta$) (rad) (pitch angle)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on

subplot(3,3,9)
plot(t, x9, 'k')
ylabel('z Angle ($\psi$) (rad) (yaw angle)', 'Interpreter', 'latex')
xlabel('Time ($s$)', 'Interpreter', 'latex')
grid on
hold off

fileName = sprintf('%s6.eps', lower(phaseName));
fullPath = fullfile(saveDir, fileName);
print('-depsc', fullPath);

%% 3D plot
% ThreeDPlot(t, ans.simZ.Data(:,1), ans.simZ.Data(:,2), ans.simZ.Data(:,3),...
%     ans.simXA.Data(:,1), ans.simXA.Data(:,2), ans.simXA.Data(:,3), x7, x8, x9)

figure
hold on; grid on;
axis equal;
set(gca, 'ZDir', 'reverse')
view(3);

N = length(t);
for i = 1:N
    plot3(X(1:i), Y(1:i), Z(1:i), 'b', 'LineWidth', 1.5);
end
hold off

fileName = sprintf('%strajec.eps', lower(phaseName));
fullPath = fullfile(saveDir, fileName);
print('-depsc', fullPath);

%% Live plot

scr = get(0, 'ScreenSize');

figure('Position', [scr(1)+20, scr(2)+80, scr(3)-40, scr(4)-120]);
grid on;
axis equal;
set(gca, 'ZDir', 'reverse');
view(3);
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Real-Time Aircraft Animation');

N = length(t);

for i = 1:N
    % Call the LiveThreeDPlot function with the current data point
    LiveThreeDPlot(X(i), Y(i), Z(i), x1A(i), x2A(i), x3A(i), x7(i), x8(i), x9(i));

    % Calculate the pause time using the difference in time steps
    if i < N
        dt = t(i+1) - t(i);
        pause(dt);  % Pause using actual time interval
    end
end