function [U] = control(U1, U2)

if abs(U1(1)) > 0
    da = U1(1);
else
    da = U2(1);
end

if abs(U1(2)) > 0
    de = U1(2);
else
    de = U2(2);
end

if abs(U1(3)) > 0
    dr = U1(3);
else
    dr = U2(3);
end

dt = U2(4);

U = [da; de; dr; dt];

end