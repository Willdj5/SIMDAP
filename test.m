%% TEST
x0 = [85;
      0;
      0;
      0;
      0;
      0;
      0;
      0.1; % Pitched up at about 5 degrees
      0];

u = [0;
     -0.1; % Tail down
     0;
     0.08];

CLStore = [];
save('DataStoreLastRun', 'CLStore')

X = UAV_model3(x0, u);

U = etatoTrim(X, 0);

EXdata = load('Data.mat');
data = EXdata.data;

display(data.CLMAX)
display(data.alphaS)

%% GRAPHS
alpha_range = -20*pi/180:0.001:20*pi/180;
CL_wb_values = zeros(size(alpha_range));

aS_o = 4*pi/180; % boundary adjust
slo = 25; % slope for stall

for i = 1:length(alpha_range)
    wing_alpha = alpha_range(i) + data.alpha_wset;
    
    if (-data.alphaS+aS_o <= wing_alpha) && (wing_alpha <= data.alphaS-aS_o)
        CL_wb = data.a * (wing_alpha - data.alpha_L0);
    elseif (wing_alpha > data.alphaS-aS_o)
        CL_wb = data.CLMAX+0.05 - slo * (wing_alpha - data.alphaS-aS_o)^2;
    elseif (wing_alpha < -data.alphaS+aS_o)
        CL_wb = -data.CLMAX+0.35 + slo * (wing_alpha + data.alphaS+aS_o)^2;
    end
    
    % Store the result in the array
    CL_wb_values(i) = CL_wb;
end

%% Plotting
figure;
plot(alpha_range.*180/pi, CL_wb_values);
xlabel('Angle of Attack Aircraft [degrees]');
ylabel('Lift Coefficient (CL_{wb})');
title('Lift Coefficient vs Angle of Attack');
grid on;