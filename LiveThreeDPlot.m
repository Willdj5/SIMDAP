function LiveThreeDPlot(X, Y, Z, Vx, Vy, Vz, phi, theta, psi)

% Plotting
hold on; grid on;
xlabel('X Position (m)');
ylabel('Y Position (m)');
zlabel('Z Position (m)');
title('Aircraft Position and Velocity Vectors');
axis equal;
set(gca, 'ZDir', 'reverse')
view(3);

% Aircraft dimensions
fuselage_length = 5;
fuselage_radius = 0.7;
wing_span = 10;
wing_depth = 1;
tail_span = 5;
tail_depth = 1;

% Create fuselage (cylinder)
[x_cyl, y_cyl, z_cyl] = cylinder(fuselage_radius, 20);
z_cyl = z_cyl * fuselage_length - fuselage_length / 2;
z_cyl_rot = y_cyl;
y_cyl_rot = x_cyl;
x_cyl_rot = z_cyl;

ratio = -(fuselage_length / 2) * 1/8;
% Create wing (rectangular cuboid)
wing_y = [-wing_span/2, wing_span/2, wing_span/2, -wing_span/2];
wing_x = [-wing_depth/2-ratio, -wing_depth/2-ratio, wing_depth/2-ratio, wing_depth/2-ratio];
wing_z = [0, 0, 0, 0];

ratio = (fuselage_length / 2) * 4/5;
% Create tail (rectangular cuboid)
tail_y = [-tail_span/2, tail_span/2, tail_span/2, -tail_span/2];
tail_x = [-tail_depth/2-ratio, -tail_depth/2-ratio,tail_depth/2-ratio, tail_depth/2-ratio];
tail_z = [0, 0, 0, 0];

R = [cos(psi)*cos(theta), cos(psi)*sin(theta)*sin(phi) - sin(psi)*cos(phi), cos(psi)*sin(theta)*cos(phi) + sin(psi)*sin(phi);
     sin(psi)*cos(theta), sin(psi)*sin(theta)*sin(phi) + cos(psi)*cos(phi), sin(psi)*sin(theta)*cos(phi) - cos(psi)*sin(phi);
     -sin(theta), cos(theta)*sin(phi), cos(theta)*cos(phi)];

cla;
% Rotate and plot fuselage
fuselage_pts = R * [x_cyl_rot(:)'; y_cyl_rot(:)'; z_cyl_rot(:)'];
surf(X + reshape(fuselage_pts(1,:), size(x_cyl_rot)), ...
     Y + reshape(fuselage_pts(2,:), size(y_cyl_rot)), ...
     Z + reshape(fuselage_pts(3,:), size(z_cyl_rot)), ...
     'FaceColor', '#808080', 'EdgeColor', 'none');
 
% Rotate and plot wing
wing_pts = R * [wing_x; wing_y; wing_z];
fill3(X + wing_pts(1,:), Y + wing_pts(2,:), Z + wing_pts(3,:), 'k');

% Rotate and plot tail
tail_pts = R * [tail_x; tail_y; tail_z];
fill3(X + tail_pts(1,:), Y + tail_pts(2,:), Z + tail_pts(3,:), 'k');

d_s = 2;
% Replot velocity vector
quiver3(X, Y, Z, Vx / d_s, Vy / d_s, Vz / d_s, 'r', 'LineWidth', 1.5, 'MaxHeadSize', 1);

s = 20;
% Set axis limits around the current point (zoom in)
axis([X-s, X+s, Y-s, Y+s, Z-s, Z+s]);
end