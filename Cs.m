function [c] = Cs(X, U)

c = struct;

% Extract state
c.u = X(1); % velocity in x axis
c.v = X(2); % velocity in y axis
c.w = X(3); % velocity in z axis
c.p = X(4); % angular rate about body in x axis
c.q = X(5); % angular rate about body in y axis
c.r = X(6); % angular rate about body in z axis
c.phi = X(7); % bank euler angle
c.theta = X(8); % pitch euler angle
c.psi = X(9); % yaw euler angle

% Change in state
c.da = U(1); % change in aileron
c.de = U(2); % change in elevator
c.dr = U(3); % change in rudder
c.dt = U(4); % change in throttle

%% APPROXIMATIONS
% Look into this
c.alphadot = 0;

% change in side force with respect to side slip
c.dCYdbeta = -0.5;

% Distance of the ailerons
c.la = 2.5;

%% -------------------1.2 Constants - Aircraft Dim ---------------------- %

c.Aircraft = AircraftConstants();

c.rho = 1.22506;          % air density
c.g = 9.81;               % gravity

%% --------------------- 2. Intermediate Variables ---------------------- %
% Airspeed
c.Va = sqrt(c.u^2 + c.v^2 + c.w^2);

% Alpha and Beta
c.alpha = atan2(c.w, c.u);
c.beta = asin(c.v / c.Va);

% Dynamic Pressure
c.Q = 0.5 * c.rho * c.Va^2;

%% -------------------------- 3. FORCES ----------------------------------%

% --------------------------- 3.1 Lift -----------------------------------%
c.aS_o = 4*pi/180; % boundary adjust
c.slo = 25; % slope for stall

c.wing_alpha = c.alpha + c.Aircraft.alpha_wset;

% Calculate the CL_wb
if (-c.Aircraft.alphaS + c.aS_o <= c.wing_alpha) && (c.wing_alpha <= c.Aircraft.alphaS - c.aS_o)
    c.CL_wb = c.Aircraft.a * (c.wing_alpha - c.Aircraft.alpha_L0);
elseif (c.wing_alpha > c.Aircraft.alphaS - c.aS_o)
    c.CL_wb = c.Aircraft.CLMAX + 0.05 - c.slo * (c.wing_alpha - c.Aircraft.alphaS - c.aS_o)^2;
elseif (c.wing_alpha < -c.Aircraft.alphaS + c.aS_o)
    c.CL_wb = -c.Aircraft.CLMAX + 0.35 + c.slo * (c.wing_alpha + c.Aircraft.alphaS + c.aS_o)^2;
end

c.eps = c.Aircraft.depsda * c.alpha - c.Aircraft.eps_0;

% Damping with respect to pitch rate
c.CL_q = 1.1 * c.Aircraft.a1 * (c.Aircraft.St / c.Aircraft.S) * ((c.Aircraft.lt * c.q) / c.Va);

% Damping with respect to rate of angle of attack
c.CL_alphadot = 1.1 * c.Aircraft.a1 * c.eps * (c.Aircraft.St / c.Aircraft.S) * ((c.alphadot * c.Aircraft.lt) / c.Va);

% No need to model tail stall as wing stalls first
% Calculate CL_t
c.CL_t = (c.Aircraft.St / c.Aircraft.S) * (c.Aircraft.a1 * (c.alpha + c.Aircraft.alpha_tset - c.eps) + c.Aircraft.a2 * c.de) + c.CL_q + c.CL_alphadot;

% Total Lift Force
c.CL = c.CL_wb + c.CL_t;

% --------------------------- 3.2 Drag -----------------------------------%
% Calculate total drag force
c.CD = c.Aircraft.CDi + c.Aircraft.CDb * c.CL^2;

% --------------------------- 3.3 Yaw ------------------------------------%
% Side force of the body
c.CY_b = c.dCYdbeta * c.beta;

% Side force from the tail
c.CY_t = - (c.Aircraft.Sv / c.Aircraft.S) * (c.Aircraft.av * c.beta + c.Aircraft.ar * c.dr);

% Side force damping
c.CY_r = (c.Aircraft.Sv / c.Aircraft.S) * (c.Aircraft.lt * c.r / c.Va) * c.Aircraft.av;

% Calculate side force
c.CY = c.CY_b + c.CY_t + c.CY_r;

%% --------------------- 3.4 X, Y, and Z FORCE ---------------------------%
% Stability axis matrix
c.FA_s = [-c.CD * c.Q * c.Aircraft.S;
           c.CY * c.Q * c.Aircraft.S;
          -c.CL * c.Q * c.Aircraft.S];
% Rotation for stability to body axis
c.C_bs = [cos(c.alpha)  0  -sin(c.alpha);
          0             1   0;
          sin(c.alpha)  0   cos(c.alpha)];

% X, Y, and Z Force with respect to body axis
c.FA_b = c.C_bs * c.FA_s;

%% ---------------------------4. MOMENTS ---------------------------------%
% Pitching
c.Cm = c.Aircraft.CM0 - (c.Aircraft.h0 - c.Aircraft.h) * c.CL - (c.Aircraft.l / c.Aircraft.cbar) * c.CL_t;

% Roll
c.Cl = 2 * c.la / c.Aircraft.bw * (c.Aircraft.aa * c.da);

% Yaw
c.Cn = c.CY_t * c.Aircraft.lt / c.Aircraft.bw - c.Aircraft.lt / (2 * c.Va) * c.CY_r;

% Dimensionalise
c.MA_b = [c.Cl * c.Q * c.Aircraft.S * c.Aircraft.bw;
          c.Cm * c.Q * c.Aircraft.S * c.Aircraft.cbar;
          c.Cn * c.Q * c.Aircraft.S * c.Aircraft.bw];

%% ---------------------- 5. Engine Force and Moment -------------------- %
% Thrust of engine
c.FE_b = [c.dt;
          0;
          0;];

%% ------------------------- 6. Gravity Effects ------------------------- %
c.g_b = [c.g * -sin(c.theta);
         c.g * cos(c.theta) * sin(c.phi);
         c.g * cos(c.theta) * cos(c.phi)];

c.Fg_b = c.Aircraft.m * c.g_b;

end