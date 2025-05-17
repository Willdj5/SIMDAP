function [V_A] = toNormalAxis(V_b, sigma_b)

phi = sigma_b(1);
theta = sigma_b(2);
psi = sigma_b(3);

% Psi - trident
% Phi - circle

S_t = [cos(psi)*cos(theta), cos(psi)*sin(theta)*sin(phi) - sin(psi)*cos(phi), cos(psi)*sin(theta)*cos(phi) + sin(psi)*sin(phi);
       sin(psi)*cos(theta), sin(psi)*sin(theta)*sin(phi) + cos(psi)*cos(phi), sin(psi)*sin(theta)*cos(phi) - cos(psi)*sin(phi);
       -sin(theta),         cos(theta)*sin(phi),                              cos(theta)*cos(phi)];

V_A = S_t * V_b;
end