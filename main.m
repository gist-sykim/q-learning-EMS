clear all;
clc;

numOfStep =  24*12; % 24hours * 12 in an hour (5 min)
numOfEpisode = 100; % days

SoCOfESS_QL = 250; % initial SoC
maxSoCOfESS = 500; % ESS capacity
energyUnit = 25; % unit energy for selling and charging
numOfSoCOfESS = maxSoCOfESS/energyUnit+1; 

priceHigh = 0.14; priceMid = 0.08; priceLow = 0.04; numOfPrice = 3; % util price (dollars per KWh) from KEPCO
priceV2GHigh = 0.11; priceV2GMid = 0.09; priceV2GLow = 0.06; numOfPriceV2G = 3; % v2g price from KEPCO

numOfNetDemand = 6; % for State (can be adjusted depending on the scale)

CHARGING = 1; NORMAL = 2; DISCHARGING = 3; SELLING = 4; numOfAction = 4; 
possibleAction = zeros(1, numOfAction);
price_util = zeros(1, numOfStep);
price_v2g = zeros(1, numOfStep);
demand_bldg = zeros(1, numOfStep);
demand_v2g = zeros(1, numOfStep);
supply_pv = zeros(1, numOfStep);

numOfTimeZone = 3; % peak, mid, off-peak
timeZoneBorder1 = 9*numOfStep/24; % 9 am
timeZoneBorder2 = 10*numOfStep/24; % 10 am
timeZoneBorder3 = 12*numOfStep/24; % 12 pm
timeZoneBorder4 = 13*numOfStep/24; % 13 pm
timeZoneBorder5 = 17*numOfStep/24; % 17 pm
timeZoneBorder6 = 23*numOfStep/24; % 23 pm

Q = zeros(numOfSoCOfESS, numOfNetDemand, numOfTimeZone, numOfAction);  % Q-table 

alpha = 0.1; % learning rate
initAlpha = 0.9; 
gamma = 0.95; % discount factor
initGamma = 0.0; 
e = 0.2; % e-greedy
initEpsilon = 1.0; 

profit_daily_QL = zeros(1, numOfEpisode);
profit_hourly_QL = zeros(1, numOfStep);

%% Data input (bldg demand, v2g demand, pv demand, utility price, v2g price)
for episode = 1:numOfEpisode
%    demand_bldg(step) = 0; % input your own building demand data set (per 5 min) of 1 day
%    demand_v2g(step) = 0; % input your own v2g demand data set (per 5 min) of 1 day
%    supply_pv(step) = 0; % input your own PV generation data set (per 5 min) of 1 day
   for step = 1:numOfStep % for utility price and v2g price 
        if ((timeZoneBorder2<=step) && (step<timeZoneBorder3)) || ((timeZoneBorder4<=step) && (step<timeZoneBorder5))  % peak zone
            price_v2g(step) = priceV2GHigh;
            price_util(step) = priceHigh;

        elseif ((timeZoneBorder1<=step) && (step<timeZoneBorder2)) || ((timeZoneBorder3<=step) && (step<timeZoneBorder4)) || ((timeZoneBorder5<=step) && (step<timeZoneBorder6))  % mid zone
            price_v2g(step) = priceV2GMid;
            price_util(step) = priceMid;

        else  % off-peak zone
            price_v2g(step) = priceV2GLow;
            price_util(step) = priceLow;

        end
    end
end     
       
%% loop for Q-learning algorithm
if episode == 1 % for Q-table initialization step in the proposed algorithm
    for initIteration = 1:1:1
        [profit_hourly_QL, Q, SoCOfESS_QL] = qlearning( numOfSoCOfESS, price_util, priceHigh, priceMid, priceLow, numOfStep, energyUnit, price_v2g, priceV2GHigh, priceV2GMid, priceV2GLow, profit_hourly_QL,...
                                                       demand_bldg, demand_v2g, supply_pv, episode, timeZoneBorder1, timeZoneBorder2,...
                                                       timeZoneBorder3, timeZoneBorder4, timeZoneBorder5, timeZoneBorder6, SoCOfESS_QL, possibleAction, CHARGING, NORMAL, DISCHARGING, SELLING, Q, initAlpha, initGamma, maxSoCOfESS, initEpsilon ); 
    end
end

% main algorithm call (called every time step)
[profit_hourly_QL, Q, SoCOfESS_QL] = qlearning( numOfSoCOfESS, price_util, priceHigh, priceMid, priceLow, numOfStep, energyUnit, price_v2g, priceV2GHigh, priceV2GMid, priceV2GLow, profit_hourly_QL,...
demand_bldg, demand_v2g, supply_pv, episode, timeZoneBorder1, timeZoneBorder2,...
timeZoneBorder3, timeZoneBorder4, timeZoneBorder5, timeZoneBorder6, SoCOfESS_QL, possibleAction, CHARGING, NORMAL, DISCHARGING, SELLING, Q, alpha, gamma, maxSoCOfESS, e );

%% results of daily profit 
profit_daily_QL(episode) = sum(profit_hourly_QL);

