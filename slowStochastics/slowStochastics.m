function [ portfolio, newStateMatrix ] = slowStochastics( decisionData, stateMatrix )

% @Author = Charles Lai
% fastStochastics - Slow Stochastics %K Trading Strategy
% Type: Price Oscillator
% Parameters: kStoch - %K Stochastic = (Today's Close - Lowest Low)/(Highest High - Lowest Low)
%    		  dStoch - %D Stochastic = 3-Day SMA of the %K vector
%
% Description: The Fast %K Stochastics trading strategy is a price oscillator trading strategy
%			   that compares current prices to the high and low range over a look-back period
%			   (default = 2 week look-back period). If the fast %K rises above 30 with a cross
%			   above the fast %D stochastic, we buy. Else if the fast %K dips below 80 with a cross
%			   below the fast %D stochastic, we sell/short.
%
%			   This is the smoothed/slow version of the Fast %K Strategy. We simply take a 3-day
%			   simple moving average of the fast %K to create a slow %K, and then we take another
%			   3-day simple moving average of the slow %K to yield a slow %D.
%
% NOTE: I've noticed that a low of strategies are more profitable when created in a contrarian way
%       I have no idea why.
	
	% Initialize the stateMatrix/Portfolio with zero postions and any starting global variables
	if isempty(stateMatrix)
        portfolio = zeros(1,1);
        stateMatrix.portfolio = portfolio;
    end
	% Calculate the required variables: Price Vectors for closing, highs, and lows.
	portfolio = stateMatrix.portfolio;
	cp = decisionData.CP_DAY01.data;
	hip = decisionData.HIP_DAY01.data;
	lop = decisionData.LOP_DAY01.data;
	% Calculate the raw %K Stochastic
	counter = 0;
	kStoch = zeros(1, 100);
    dStoch = zeros(1, 100); %Initialize the raw %D Stochastic
	while (counter < 100)
		periodLow = min(lop(end-counter-14:end-counter));
		periodHigh = max(hip(end-counter-14:end-counter));
		counter = counter + 1;
		kStoch(1, counter) = ((cp(end) - periodLow)/(periodHigh-periodLow))*100;
	end
	% Reverse the %K Stochastic Vector in order to do have the most recent value at the end
	% Smooth the raw %K Stochastic with a 3-day moving average and then calculate the slow %D
	kStoch = fliplr(kStoch);
	[kStoch] = movavg(kStoch, 3, 3);
	[dStoch] = movavg(kStoch, 3, 3);
	% Recalculate our portfolio positions
	if (kStoch(end) > 30 && kStoch(end) > dStoch(end))
		portfolio = 1;
	elseif (kStoch(end) < 80 && kStoch(end) < dStoch(end))
		portfolio = -1;
	% Else our portfolio remains the same
	else
		portfolio = stateMatrix.portfolio;
	end
	% Update the stateMatrix/Portfolio postions
	newStateMatrix = stateMatrix;
	newStateMatrix.portfolio = portfolio;
end