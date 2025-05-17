function [UOUT] = etatoTrim(X, reqs)

% Extract controls
reqSpeed = reqs(1); % Speed requirement

da = 0; % change in aileron
de = 0; % change in elevator
dr = 0; % change in rudder
dt = 0; % change in throttle

c = Cs(X, [da;de;dr;dt]);

% ------------------------ 3.3 Moment zero -------------------------------%

% Alieron to trim
da = 0;

Kd_a = 1.2;
K_phi = 1;
da = da - Kd_a * c.p - K_phi * c.phi;

% Rudder to trim
dr = (-(c.Aircraft.S / c.Aircraft.Sv) * (c.Aircraft.bw / (2 * c.Va))...
            * c.CY_r - c.Aircraft.av * c.beta ) / c.Aircraft.ar;

Kd_a = 2;
Kd_r = 2;
K_beta = 2;
dr = dr + Kd_r * c.r - K_beta * c.beta + Kd_a * da;

% Eta to trim
de = (...
      c.Aircraft.CM0 - (c.Aircraft.h0 - c.Aircraft.h) * ((c.Aircraft.St / c.Aircraft.S) * (c.Aircraft.a1 * (c.alpha + c.Aircraft.alpha_tset - c.eps)) + c.CL_q + c.CL_alphadot + c.CL_wb) ...
      - (c.Aircraft.l / c.Aircraft.cbar) * ((c.Aircraft.St / c.Aircraft.S) * (c.Aircraft.a1 * (c.alpha + c.Aircraft.alpha_tset - c.eps)) + c.CL_q + c.CL_alphadot) ...
      )...
      /...
      (...
      (c.Aircraft.St / c.Aircraft.S) * c.Aircraft.a2 * ((c.Aircraft.h0 - c.Aircraft.h) + (c.Aircraft.l / c.Aircraft.cbar))...
      );

Kd_e = 2.5;
K_alpha = 2;
K_theta = 2;
de = de + Kd_e * c.q + K_alpha * c.alpha + K_theta * c.theta;

% ------------------------ 3.2 Equal Thrust ------------------------------%
D_F = c.CD * c.Q * c.Aircraft.S;

%% ------------------------ 4. CONTROLS ----------------------------------%
% Required speed
if reqSpeed == 0
    dt = D_F * cos(c.alpha) + c.Aircraft.m * c.g * sin(c.alpha);
else
    dt = speedAdjust(reqSpeed, c.Va, c.Aircraft.m, D_F);
end

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