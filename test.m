T = 0.01;
t = 0:T:2;
Fs = 1/T;

x = sin(2*pi*10*t)+cos(2*pi*20*t);
plot(t,x)
y = fft(x);
y = fftshift(y);
figure
nn = linspace(-pi,pi,length(t));
plot(nn,abs(y));