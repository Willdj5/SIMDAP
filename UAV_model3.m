function [XDOT] = UAV_model3(X, U)

% All angles in radians

c = Cs(X, U);

% fprintf('Roll Moment %f\n', c.Cl)
% fprintf('Pitch Moment %f\n', c.Cm)
% fprintf('Yaw Moment %f\n\n', c.Cn)

%% ------------------------ 7. State Derivatives ------------------------ %
% Inertia matrix
Ib = [177.0178172	0	        -36.47246821;
      0	            1	        0;
      -36.47246821	0	        547.7680286;];

% Ib = [177.0178172	0	        -36.47246821;
%       0	            446.7782171	0;
%       -36.47246821	0	        547.7680286;];

% Get the new velocities
omega_hat = [0 -c.r c.q;
             c.r 0 -c.p;
             -c.q c.p 0];

V_axis = [c.u;
          c.v;
          c.w];

Omega_axis = [c.p;
              c.q;
              c.r];

F_b = c.Fg_b + c.FE_b + c.FA_b;

x1to3dot = (1 / c.Aircraft.m) * F_b - omega_hat * V_axis;

M_b = c.MA_b;

x4to6dot = inv(Ib) * (M_b - omega_hat * Ib * Omega_axis);

H_phi = [1 (sin(c.phi) * tan(c.theta)) (cos(c.phi) * tan(c.theta));
        0 cos(c.phi) -sin(c.phi);
        0 (sin(c.phi) / cos(c.theta)) (cos(c.phi) / cos(c.theta))];

x7to9dot = H_phi * Omega_axis;

XDOT = [x1to3dot;
        x4to6dot;
        x7to9dot];

n = c.q * c.Va / c.g;

storeData = load('DataStoreLastRun.mat');
store = storeData.store;
store.CL(end+1) = c.CL;
store.CLt(end+1) = c.CL_t;
store.Cm(end+1) = c.Cm;
store.CY(end+1) = c.CY;
store.Cn(end+1) = c.Cn;
store.Cl(end+1) = c.Cl;
store.n(end+1) = n;
save('DataStoreLastRun.mat', 'store')
end