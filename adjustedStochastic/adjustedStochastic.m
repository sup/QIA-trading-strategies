function [ portfolio, newStateMatrix ] = adjustedStochastic( decisionData, stateMatrix )

% @Author = Charles Lai
% adjustedStochastic - Kestner's Adjusted CounterTrend Stochastics Strategy
% Type: Price Oscillator
% Parameters: kStoch - slow %K Stochastic = a 3-Day SMA of the fast %K stochastic
%    		  newStoch - (14-day Slow %K stochastic - 50)*(highest high of the past 14
%			  days - lowest low of past 14 days)/(highest high of past 100 days - lowest
%			  low of past 100 days) +50
%
% Description: Unlike the %K stochastic strategies included, Kestner's adjusted strategy does not utilize
%			   a %D stochastic cross-over. In this strategy, if the new Stochastic value rises above 65 
%			   and then falls below 65, we take counter trend short positions. Vice versa for a new stoch
%			   value of 35.
%
% NOTE: I've noticed that a low of strategies are more profitable when created in a contrarian way
%       I have no idea why.
	
	% Initialize the stateMatrix/Portfolio with zero postions and any starting global variables
	if isempty(stateMatrix)
        portfolio = zeros(1,1);
        stateMatrix.portfolio = portfolio;
        stateMatrix.isAbove65 = 0;
        stateMatrix.isBelow35 = 0;
        stateMatrix.isFirstRun = 1;
    end
	% Calculate the required variables: Price Vectors for closing, highs, and lows.
	cp = decisionData.CP_DAY01.data;
	hip = decisionData.HIP_DAY01.data;
	lop = decisionData.LOP_DAY01.data;
    isAbove65 = stateMatrix.isAbove65;
    isBelow35 = stateMatrix.isBelow35;
	% Calculate the raw %K Stochastic
	counter = 0;
	kStoch = zeros(1, 100);
    dStoch = zeros(1,100); %Initialize the raw %D Stochastic
	while (counter < 100)
		fourteenLow = min(lop(end-counter-14:end-counter)');
		fourteenHigh = max(hip(end-counter-14:end-counter)');
		counter = counter + 1;
		kStoch(1, counter) = ((cp(end) - fourteenLow)/(fourteenHigh-fourteenLow))*100;
	end
	% Reverse the %K Stochastic Vector in order to do have the most recent value at the end
	% Smooth the raw %K Stochastic with a 3-day moving average and then calculate the adjusted stoch
	% as per the above description.
	kStoch = fliplr(kStoch);
	[kStoch] = movavg(kStoch, 3, 3);
	fourteenLow = min(lop(end-14:end)');
	fourteenHigh = max(hip(end-14:end)');
	hundredLow = min(lop(end-100:end)');
	hundredHigh = max(hip(end-100:end)');
	newStoch = ((kStoch(end)-50)*(fourteenHigh-fourteenLow))/(hundredHigh-hundredLow) + 50;

	% Initialize default isAbove65 and isBelow35 boolean values
    if (stateMatrix.isFirstRun)
        if(newStoch(end) > 65)
            isAbove65 = 1;
        elseif(newStoch(end) < 35)
            isBelow35 = 1;
        end
        stateMatrix.isFirstRun = 0; %Finally, set isFirstRun to 1 to stop first run initializations on the next iteration.
    end
	% Recalculate our portfolio positions as per the description above
    portfolio = stateMatrix.portfolio;
    if (isBelow35 == 1)
        if (newStoch(end) > 35)
        portfolio = 1;
        isBelow35 = 0;
        end
    elseif (isAbove65 == 1)
        if (newStoch(end) < 65)
        portfolio = -1;
        isAbove65 = 0;
        end
    % Then reset and update the isAbove65 or isBelow35 boolean values
    elseif(isBelow35 == 0)
        if (newStoch(end) < 35)
            isBelow35 = 1;
        end
    elseif(isAbove65 == 0)
        if (newStoch(end) > 65)
            isAbove65 =1;
        end
    % Else, keep everything the same for the next iteration.
    else
        portfolio = stateMatrix.portfolio;
    end
    % Update the stateMatrix/Portfolio Positions
    newStateMatrix = stateMatrix;
    newStateMatrix.portfolio = portfolio;
    newStateMatrix.isAbove65 = isAbove65;
    newStateMatrix.isBelow35 = isBelow35;
end
    