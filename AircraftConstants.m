function [Aircraft] = AircraftConstants()

Aircraft = struct;
%% -------------------1.2 Constants - Aircraft Dim ---------------------- %

Aircraft.rho = 1.22506;          % air density
Aircraft.g = 9.81;               % gravity

Aircraft.m = 450;

Aircraft.CDi = 0.0077;
Aircraft.CDb = 0.0325;

% WING
Aircraft.cbar = 0.714286;
Aircraft.bw = 10;
Aircraft.S = 7.14286;
Aircraft.alpha_L0 = -0.0392223;
Aircraft.alpha_wset = 0.100007;
Aircraft.alphaS = 0.213803;
Aircraft.CLMAX = 1.4238;

% TAIL
Aircraft.St = 1.37286;
Aircraft.Sv = 1.014;
Aircraft.alpha_tset = -0.0232129;
Aircraft.depsda = 0.276387;
Aircraft.eps_0 = 0.0372326;

% STABCON
Aircraft.CM0 = -0.0536526;
% original - Test 1
% Aircraft.h = 2.422;

% Test 2
Aircraft.h = 2.30;

% Test 3
% Aircraft.h = 2.25;

% Test 4
% Aircraft.h = 2.23;

Aircraft.h0 = 2.24;
Aircraft.l = 1.4;
Aircraft.lt = 1.27;
Aircraft.a = 5.47848;
Aircraft.a1 = 5.14818;
Aircraft.a2 = 5.53561;
Aircraft.av = 2.69773;
Aircraft.ar = 2.14809;
Aircraft.aa = 5.21627;

% CG Locs
Aircraft.Xcg = 0;                % x position of cg in Fm
Aircraft.Ycg = 0;                % y position of cg in Fm
Aircraft.Zcg = 0;                % z position of cg in Fm

Aircraft.Xac = 0;                % x position of AC in Fm
Aircraft.Yac = 0;                % y position of AC in Fm
Aircraft.Zac = 0;                % z position of AC in Fm

Aircraft.Xapt = 0;               % x position of engine force
Aircraft.Yapt = 0;               % y position of engine force
Aircraft.Zapt = 0;               % z position of engine force
end