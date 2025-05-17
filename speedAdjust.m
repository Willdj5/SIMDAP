function [dt] = speedAdjust(Vf, Va, m, D)

% acceleration
a = 3;

% setting thrust equal to accleration if required speed isnt acheived
if Vf > Va
    dt = D + m * a;
elseif Vf < Va
    dt = 0;
else
    dt = D;
end

end