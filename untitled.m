% Parameters
N = 1000; % Number of terms in the series
sumVal = 0;

for k = 0:N
    n = 2*k + 1;
    term = (-1)^k * besselj(n, pi/2) / n;
    sumVal = sumVal + term;
end

result = -pi/2 - sumVal;

fprintf('The result is approximately: %.10f\n', result);
