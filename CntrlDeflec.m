function [UOUT] = CntrlDeflec(X, current_time)

storeData = load('DataStoreLastRun.mat');
store = storeData.store;
store.time(end+1) = current_time;
save('DataStoreLastRun.mat', 'store')

missionData = load('missionStore.mat');
mission = missionData.mission;

da = 0; % change in aileron
de = 0; % change in elevator
dr = 0; % change in rudder
dt = 0; % change in throttle

c = Cs(X, [da;de;dr;dt]);

%% Roll
for i = 1:size(mission.bank,1)
    scheduled_time = mission.bank(i,1);

    if mission.bank(i,3) == 0
        if current_time > scheduled_time
            fprintf('INITIATED!! %f\n', current_time)
            mission.bank_angle = mission.bank(i,2);
            mission.bank(i,3) = 1;
        end
    end
end

if mission.bank_angle ~= 0
    if c.psi > mission.bank_angle * pi/180 && mission.bank_angle * pi/180 > 0
        fprintf('OFF!! %f\n', current_time)
        mission.bank_angle = 0;
    elseif c.psi < mission.bank_angle * pi/180 && mission.bank_angle * pi/180 < 0
        fprintf('OFF!! %f\n', current_time)
        mission.bank_angle = 0;
    else
        if (mission.bank_angle * pi/180) < 0
            L = -20;
        else
            L = 20;
        end

        Rcl = L / (c.Q * c.Aircraft.S * c.Aircraft.bw);

        da = Rcl * c.Aircraft.bw / (2 * c.la * c.Aircraft.aa);

        Kd_a = 0.005;
        da = da - Kd_a * c.p;

        dr = (-(c.Aircraft.S / c.Aircraft.Sv) * (c.Aircraft.bw / (2 * c.Va))...
            * c.CY_r - c.Aircraft.av * c.beta ) / c.Aircraft.ar;

        Kd_a = 2.5;
        Kd_r = 2.5;
        K_beta = 2.5;
        dr = dr + Kd_r * c.r - K_beta * c.beta + Kd_a * da;

        fprintf('da %f\n', da)
    end
end

%% Pitch
for i = 1:size(mission.pitch,1)
    scheduled_time = mission.pitch(i,1);
    
    if mission.pitch(i,3) == 0
        if current_time > scheduled_time
            fprintf('INITIATED!! %f\n', current_time)
            mission.pitch_angle = mission.pitch(i,2);
            mission.pitch(i,3) = 1;
        end
    end
end

if mission.pitch_angle ~= 0
    if c.theta > mission.pitch_angle * pi/180 && mission.pitch_angle * pi/180 > 0
        fprintf('OFF!! %f\n', current_time)
        mission.pitch_angle = 0;
    elseif c.theta < mission.pitch_angle * pi/180 && mission.pitch_angle * pi/180 < 0
        fprintf('OFF!! %f\n', current_time)
        mission.pitch_angle = 0;
    else
        if (mission.pitch_angle * pi/180) < 0
            M = -30;
        else
            M = 30;
        end

        Rcm = M / (c.Q * c.Aircraft.S * c.Aircraft.cbar);
        
        de = (...
              c.Aircraft.CM0 - Rcm - (c.Aircraft.h0 - c.Aircraft.h) * ((c.Aircraft.St / c.Aircraft.S) * (c.Aircraft.a1 * (c.alpha + c.Aircraft.alpha_tset - c.eps)) + c.CL_q + c.CL_alphadot + c.CL_wb) ...
              - (c.Aircraft.l / c.Aircraft.cbar) * ((c.Aircraft.St / c.Aircraft.S) * (c.Aircraft.a1 * (c.alpha + c.Aircraft.alpha_tset - c.eps)) + c.CL_q + c.CL_alphadot) ...
              )...
              /...
              (...
              (c.Aircraft.St / c.Aircraft.S) * c.Aircraft.a2 * ((c.Aircraft.h0 - c.Aircraft.h) + (c.Aircraft.l / c.Aircraft.cbar))...
              );

        Kd_e = 1.7;
        Kd_m = 0;
        de = de + Kd_e * c.q - Kd_m * abs(c.theta - mission.pitch_angle * pi/180);

        fprintf('de %f\n', de)
    end
end

%% Yaw
for i = 1:size(mission.yaw,1)
    scheduled_time = mission.yaw(i,1);
    
    if mission.yaw(i,3) == 0
        if current_time > scheduled_time
            fprintf('INITIATED!! %f\n', current_time)
            mission.yaw_angle = mission.yaw(i,2);
            mission.yaw(i,3) = 1;
        end
    end
end

if mission.yaw_angle ~= 0
    if c.psi > mission.yaw_angle * pi/180 && mission.yaw_angle * pi/180 > 0
        fprintf('OFF!! %f\n', current_time)
        mission.yaw_angle = 0;
    elseif c.psi < mission.yaw_angle * pi/180 && mission.yaw_angle * pi/180 < 0
        fprintf('OFF!! %f\n', current_time)
        mission.yaw_angle = 0;
    else
        if (mission.yaw_angle * pi/180) < 0
            N = -20;
        else
            N = 20;
        end

        Rcn = N / (c.Q * c.Aircraft.S * c.Aircraft.bw);

        dr = ((c.Aircraft.bw * c.Aircraft.S) / (c.Aircraft.Sv * c.Aircraft.lt)...
              * ( - Rcn - c.Aircraft.lt / (2 * c.Va) * c.CY_r) - c.Aircraft.av * c.beta) / c.Aircraft.ar;

        Kd_r = 2;
        dr = dr + Kd_r * c.r;

        fprintf('dr %f\n', dr)
    end
end

save('missionStore.mat', 'mission')

% Control Limits / Saturation
u1min = -25 * pi / 180;
u1max = 25 * pi / 180;

u2min = -25 * pi / 180;
u2max = 25 * pi / 180;

u3min = -30 * pi / 180;
u3max = 30 * pi / 180;

u4min = 0;
u4max = 5000;

if (da > u1max)
    da = u1max;
elseif (da < u1min)
    da = u1min;
end

if (de > u2max)
    de = u2max;
elseif (de < u2min)
    de = u2min;
end

if (dr > u3max)
    dr = u3max;
elseif (dr < u3min)
    dr = u3min;
end

if (dt > u4max)
    dt = u4max;
elseif (dt < u4min)
    dt = u4min;
end

UOUT = [da; de; dr; dt];

end