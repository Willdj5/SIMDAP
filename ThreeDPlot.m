function [] = ThreeDPlot(time, X, Y, Z, Vx, Vy, Vz, phi, theta, psi)

N = length(time);
dt = diff(time);
dt = [dt; dt(end)];

% Plotting
figure;
hold on; grid on;
xlabel('X Position (m)');
ylabel('Y Position (m)');
zlabel('Z Position (m)');
title('Aircraft Position and Velocity Vectors');
axis equal;
set(gca, 'ZDir', 'reverse')
view(3);

ex = 150;
xMin = min(X)-ex; 
xMax = max(X)+ex;
yMin = min(Y)-ex; 
yMax = max(Y)+ex;
zMin = min(Z)-ex; 
zMax = max(Z)+ex;

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

s = 20;

% Animation loop
for i = 1:N
    % Clear previous aircraft
    cla;
    
    % Rotation matrix using roll (phi), pitch (theta), yaw (psi)
    R = [cos(psi(i))*cos(theta(i)), cos(psi(i))*sin(theta(i))*sin(phi(i)) - sin(psi(i))*cos(phi(i)), cos(psi(i))*sin(theta(i))*cos(phi(i)) + sin(psi(i))*sin(phi(i));
         sin(psi(i))*cos(theta(i)), sin(psi(i))*sin(theta(i))*sin(phi(i)) + cos(psi(i))*cos(phi(i)), sin(psi(i))*sin(theta(i))*cos(phi(i)) - cos(psi(i))*sin(phi(i));
         -sin(theta(i)), cos(theta(i))*sin(phi(i)), cos(theta(i))*cos(phi(i))];
     
    % Rotate and plot fuselage
    fuselage_pts = R * [x_cyl_rot(:)'; y_cyl_rot(:)'; z_cyl_rot(:)'];
    surf(X(i) + reshape(fuselage_pts(1,:), size(x_cyl_rot)), ...
         Y(i) + reshape(fuselage_pts(2,:), size(y_cyl_rot)), ...
         Z(i) + reshape(fuselage_pts(3,:), size(z_cyl_rot)), ...
         'FaceColor', '#808080', 'EdgeColor', 'none');
     
    % Rotate and plot wing
    wing_pts = R * [wing_x; wing_y; wing_z];
    fill3(X(i) + wing_pts(1,:), Y(i) + wing_pts(2,:), Z(i) + wing_pts(3,:), 'k');
    
    % Rotate and plot tail
    tail_pts = R * [tail_x; tail_y; tail_z];
    fill3(X(i) + tail_pts(1,:), Y(i) + tail_pts(2,:), Z(i) + tail_pts(3,:), 'k');

    % Replot trajectory
    plot3(X(1:i), Y(1:i), Z(1:i), 'b', 'LineWidth', 1.5);
    
    d_s = 10;
    % Replot velocity vector
    quiver3(X(i), Y(i), Z(i), Vx(i) / d_s, Vy(i) / d_s, Vz(i) / d_s, 'r', 'LineWidth', 1.5, 'MaxHeadSize', 1);
    
    % Set axis limits around the current point (zoom in)
    axis([X(i)-s, X(i)+s, Y(i)-s, Y(i)+s, Z(i)-s, Z(i)+s]); 
    
    drawnow; % Refresh plot
    pause(dt(i)); % Adjust speed for real-time effect
end

% Zoom out to show full trajectory
xlim([xMin, xMax]);
ylim([yMin, yMax]);
zlim([zMin, zMax]);
title('Final Aircraft Trajectory');
drawnow;

hold off
end