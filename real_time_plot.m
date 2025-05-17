function real_time_plot(u)
    X = u(1);
    Y = u(2);
    Z = u(3);
    Vx = u(4);
    Vy = u(5);
    Vz = u(6);
    phi = u(7);
    theta = u(8);
    psi = u(9);

    % Create figure once
    persistent h;
    if isempty(h) || ~isvalid(h)
        h = figure;
        hold on;
    end

    % Call the Live Plot Function
    LiveThreeDPlot(X, Y, Z, Vx, Vy, Vz, phi, theta, psi);

    drawnow; % Ensures real-time updates
end