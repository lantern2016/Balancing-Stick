function stickModelODE
clear
m = 1;
theta0 = .3; %Radians
rodLength = .3;
thetadot0 = 0;
g = 9.81;
integral=0;
PIDIntegral=0;
dTheta = 0;

randOffset = 0; %Radians of offset that the center of mass is.


% zeros = [];
% poles = [-1, -1, 1i, -1i];
% K = .01;
sys = tf([rodLength], [0 0 -rodLength 0 g]);
% impulse(sys)
disp(sys)
C_pid = pidtune(sys,'PID');
K = 2;
P = K*C_pid.kp
I = K*C_pid.ki
D = K*C_pid.kd
PID=0;
DTheta_C = .04;
error=0;

dt = .001;

tEnd = 20;
t=0:dt:tEnd;   % time scale
thetaAccumulation = 0;
thetaAccTracker = zeros(1,1+tEnd/dt);

% options = odeset('Events', @springEvents);

x1 = ode1(@phase1, t, [theta0 thetadot0]);

hold on;
%Plot phase 1
plot(t,x1(:,1)); %Plot mass

figure
posx = rodLength*sin(x1(:,1));
posy = rodLength*cos(x1(:,1));

axisLength =rodLength*1.25;

axis([-axisLength, axisLength, -axisLength, axisLength])
pbaspect([1,1,1])
% axis(ax, 'square')
% comet(posx, posy)

h = animatedline('Marker', 'o');
b = animatedline;


for k = 1:10:length(posx)
    addpoints(h,posx(k),posy(k));
    addpoints(b, 0,0);
    addpoints(b, posx(k),posy(k));
    drawnow
    clearpoints(h);
    clearpoints(b);
end


function dValues=phase1(t,M)
    theta = M(1);
    thetadot = M(2);  
    trans= 0;
    if t > 10
        trans = .1;
    end
    dTheta = -PID*DTheta_C;
    thetaAccumulation = thetaAccumulation+dTheta*dt;
    thetaAccTracker(round(t/dt)+1) = thetaAccumulation;
%     thetaAccumulation[t] = thetaAccumulation;
    error = theta+trans+thetaAccumulation;
    integral = integral+(error)*dt;
    PID = (P*error + D*thetadot + 0*I*integral)
%     PIDIntegral = PIDIntegral + I_PID*(PID+PIDIntegral)*dt;
 
    a = g*sin(theta+randOffset) + PID;

    dValues=[thetadot; a];
end
figure
plot(t, thetaAccTracker);
xlabel('Time');
ylabel('Theta Error');

end