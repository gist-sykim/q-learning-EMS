function [ profit_hourly_QL, Q, SoCOfESS_QL ] = qlearning( numOfSoCOfESS, price_util, priceHigh, priceMid, priceLow, numOfStep, energyUnit, price_v2g, priceV2GHigh, priceV2GMid, priceV2GLow, profit_hourly_QL,...
    demand_bldg, demand_v2g, supply_pv, episode, timeZoneBorder1, timeZoneBorder2,...
    timeZoneBorder3, timeZoneBorder4, timeZoneBorder5, timeZoneBorder6, SoCOfESS_QL, possibleAction, CHARGING, NORMAL, DISCHARGING, SELLING, Q, alpha, gamma, maxSoCOfESS, e )
    
    for step = 1:numOfStep
        
        % state indexing for ESS SoC
        if SoCOfESS_QL < energyUnit
            SoCOfESS_index = 1;
        elseif energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 2*energyUnit
            SoCOfESS_index = 2;
        elseif 2*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 3*energyUnit
            SoCOfESS_index = 3;
        elseif 3*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 4*energyUnit
            SoCOfESS_index = 4;
        elseif 4*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 5*energyUnit
            SoCOfESS_index = 5;
        elseif 5*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 6*energyUnit
            SoCOfESS_index = 6;
        elseif 6*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 7*energyUnit
            SoCOfESS_index = 7;
        elseif 7*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 8*energyUnit
            SoCOfESS_index = 8;
        elseif 8*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 9*energyUnit
            SoCOfESS_index = 9;
        elseif 9*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 10*energyUnit
            SoCOfESS_index = 10;
        elseif 10*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 11*energyUnit
            SoCOfESS_index = 11;
        elseif 11*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 12*energyUnit
            SoCOfESS_index = 12;
        elseif 12*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 13*energyUnit
            SoCOfESS_index = 13;
        elseif 13*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 14*energyUnit
            SoCOfESS_index = 14;
        elseif 14*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 15*energyUnit
            SoCOfESS_index = 15;
        elseif 15*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 16*energyUnit
            SoCOfESS_index = 16;
        elseif 16*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 17*energyUnit
            SoCOfESS_index = 17;
        elseif 17*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 18*energyUnit
            SoCOfESS_index = 18;
        elseif 18*energyUnit <= SoCOfESS_QL && SoCOfESS_QL < 19*energyUnit
            SoCOfESS_index = 19;
        elseif 19*energyUnit <= SoCOfESS_QL 
            SoCOfESS_index = 20;
        end
        
        % define net demand
        net_demand = demand_bldg(step)-supply_pv(step)+demand_v2g(step); 
        if step == numOfStep
            net_demand_next = 1;
        else
            net_demand_next = demand_bldg(step+1)-supply_pv(step+1)+demand_v2g(step+1);
        end
        
        % state indexing for net demand
        if net_demand < 25
            netDemand_index = 1;
        elseif 25 <= net_demand && net_demand < 50
            netDemand_index = 2;
        elseif 50 <= net_demand && net_demand < 75
            netDemand_index = 3;
        elseif 75 <= net_demand && net_demand < 100
            netDemand_index = 4;
        elseif 100 <= net_demand && net_demand < 125
            netDemand_index = 5;
        else
            netDemand_index = 6;
        end
        
        % state indexing for next net demand
        if step == numOfStep
            netDemand_index_next = ceil(6*rand());
        elseif step ~= numOfStep
            if net_demand_next < 25
                netDemand_index_next = 1;
            elseif 25 <= net_demand_next && net_demand_next < 50
                netDemand_index_next = 2;
            elseif 50 <= net_demand_next && net_demand_next < 75
                netDemand_index_next = 3;
            elseif 75 <= net_demand_next && net_demand_next < 100
                netDemand_index_next = 4;
            elseif 100 <= net_demand_next && net_demand_next < 125
                netDemand_index_next = 5;
            else
                netDemand_index_next = 6;
            end
        end
       
        % state indexing for time zone 
        if ((timeZoneBorder2<=step) && (step<timeZoneBorder3)) || ((timeZoneBorder4<=step) && (step<timeZoneBorder5))  % peak
            timeZone_index = 3;
        elseif ((timeZoneBorder1<=step) && (step<timeZoneBorder2)) || ((timeZoneBorder3<=step) && (step<timeZoneBorder4)) || ((timeZoneBorder5<=step) && (step<timeZoneBorder6))  % mid
            timeZone_index = 2;
        else
            timeZone_index = 1;
        end
        
        % state indexing for next time zone
        if step == numOfStep
            timeZone_index_next = 1;
        elseif step ~= numOfStep
            if ((timeZoneBorder2<=step+1) && (step+1<timeZoneBorder3)) || ((timeZoneBorder4<=step+1) && (step+1<timeZoneBorder5))  % peak
               timeZone_index_next = 3;
            elseif ((timeZoneBorder1<=step+1) && (step+1<timeZoneBorder2)) || ((timeZoneBorder3<=step+1) && (step+1<timeZoneBorder4)) || ((timeZoneBorder5<=step+1) && (step+1<timeZoneBorder6))  % mid
               timeZone_index_next = 2;
            else
               timeZone_index_next = 1;
            end
        end    
 
        % obain possible action set
        if SoCOfESS_QL < net_demand
            possibleAction = [CHARGING, NORMAL, 0, 0];
        elseif net_demand <= SoCOfESS_QL && SoCOfESS_QL < net_demand + energyUnit
            possibleAction = [CHARGING, NORMAL, DISCHARGING, 0];
        elseif net_demand + energyUnit <= SoCOfESS_QL && SoCOfESS_QL < maxSoCOfESS-energyUnit
            possibleAction = [CHARGING, NORMAL, DISCHARGING, SELLING];
        elseif maxSoCOfESS-energyUnit <= SoCOfESS_QL && SoCOfESS_QL < maxSoCOfESS
            possibleAction = [0, NORMAL, DISCHARGING, SELLING];
        end
     
        % obtain greedy action 
        possibleActionNonzero = nonzeros(possibleAction);
        possibleQ = Q(SoCOfESS_index, netDemand_index, timeZone_index, possibleActionNonzero(:));
        Qmax = max(possibleQ);
        actionMax_all = find(Qmax == Q(SoCOfESS_index, netDemand_index, timeZone_index, possibleActionNonzero(:)));
        actionMaxInPossibleActionNonzero = actionMax_all(randi(length(actionMax_all)));
        actionMax = possibleActionNonzero(actionMaxInPossibleActionNonzero);

        % apply e-greedy policy
        rndNum = rand();
        if rndNum > e
            action = actionMax;
        else
            action = possibleActionNonzero(randi(length(possibleActionNonzero)));
        end
        action_index = action;
        
        % reward (money earned) calculation & state indexing for next ESS SoC
        if action == CHARGING 
            reward = - (net_demand+energyUnit)*price_util(step) + demand_v2g(step)*price_v2g(step);
            SoCOfESS_QL_next = SoCOfESS_QL + energyUnit;
        elseif action == NORMAL 
            reward = - (net_demand)*price_util(step) + demand_v2g(step)*price_v2g(step);
            SoCOfESS_QL_next = SoCOfESS_QL + 0;
        elseif action == DISCHARGING 
            reward = demand_v2g(step) * price_v2g(step);
            SoCOfESS_QL_next = SoCOfESS_QL - net_demand;
        elseif action == SELLING 
            reward = + energyUnit * price_util(step) + demand_v2g(step)*price_v2g(step); 
            SoCOfESS_QL_next = SoCOfESS_QL - (net_demand+energyUnit);
        end
      
         % state indexing for next ESS SoC
         if step == numOfStep
             SoCOfESS_index_next = 10;
         elseif step ~= numOfStep
            if SoCOfESS_QL_next < energyUnit
                SoCOfESS_index_next = 1;
            elseif energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 2*energyUnit
                SoCOfESS_index_next = 2;
            elseif 2*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 3*energyUnit
                SoCOfESS_index_next = 3;
            elseif 3*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 4*energyUnit
                SoCOfESS_index_next = 4;
            elseif 4*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 5*energyUnit
                SoCOfESS_index_next = 5;
            elseif 5*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 6*energyUnit
                SoCOfESS_index_next = 6;
            elseif 6*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 7*energyUnit
                SoCOfESS_index_next = 7;
            elseif 7*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 8*energyUnit
                SoCOfESS_index_next = 8;
            elseif 8*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 9*energyUnit
                SoCOfESS_index_next = 9;
            elseif 9*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 10*energyUnit
                SoCOfESS_index_next = 10;
            elseif 10*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 11*energyUnit
                SoCOfESS_index_next = 11;
            elseif 11*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 12*energyUnit
                SoCOfESS_index_next = 12;
            elseif 12*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 13*energyUnit
                SoCOfESS_index_next = 13;
            elseif 13*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 14*energyUnit
                SoCOfESS_index_next = 14;
            elseif 14*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 15*energyUnit
                SoCOfESS_index_next = 15;
            elseif 15*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 16*energyUnit
                SoCOfESS_index_next = 16;
            elseif 16*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 17*energyUnit
                SoCOfESS_index_next = 17;
            elseif 17*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 18*energyUnit
                SoCOfESS_index_next = 18;
            elseif 18*energyUnit <= SoCOfESS_QL_next && SoCOfESS_QL_next < 19*energyUnit
                SoCOfESS_index_next = 19;
            elseif 19*energyUnit <= SoCOfESS_QL_next 
                SoCOfESS_index_next = 20;
            end
         end
        
        % Q-function Update
        Q(SoCOfESS_index, netDemand_index, timeZone_index, action_index) = (1-alpha)*Q(SoCOfESS_index, netDemand_index, timeZone_index, action_index) ...
                                             + alpha*( reward + gamma*max(Q(SoCOfESS_index_next, netDemand_index_next, timeZone_index_next, :)) );

        % State(SoC) update
        if action == CHARGING
            SoCOfESS_QL = SoCOfESS_QL + energyUnit;
        elseif action == NORMAL
            SoCOfESS_QL = SoCOfESS_QL + 0;
        elseif action == DISCHARGING
            SoCOfESS_QL = SoCOfESS_QL - net_demand;
        elseif action == SELLING
            SoCOfESS_QL = SoCOfESS_QL - (net_demand+energyUnit);
        end
        
    end
end

