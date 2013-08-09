function [ portfolio, newStateMatrix ] = timeFilterMACO( decisionData, stateMatrix )

% @Author = Charles Lai
% timeFilterMACO - Time Filtered Moving Average Crossover Strategy
% Type: Trend Following Strategy
% Parameters: leadMA - the leading moving average line
%			  lagMA - the lagging moving average line
%			  count - the number of days required for a trend to last before buying

% Description: The Simple Moving Average Crossover Strategy is a basic, yet effective
%			   trading strategy in trending markets. However, if there aren't measures 
%			   in place to prevent rapid buy/sell signals in a stagnant market, the basic Simple
%			   Moving Average Crossover will cause a significant loss of capital. 
%
%			   This strategy will attempt to augment the basic dual MACO strategy using a time filter
%			   in an attempt to prevent whipsawing. Specifically, we wait for an uptrend to last x
%			   amount of days before changing our portfolio positions. This is a delay time filter.
%
% NOTE: I've noticed that Chinese stocks seems to behave contrary to the traditional MACO strategy
%		In that it is very profitable to short uptrends and long downtrends. I have no clue why.

	% Initialize the stateMatrix/Portfolio with zero postions and any starting global variables
	if isempty(stateMatrix)
        portfolio = zeros(1,1);
        stateMatrix.portfolio = portfolio;
        stateMatrix.count = 0;
    end
	% Calculate the required variables: Price Vector
    count = stateMatrix.count;
	portfolio = stateMatrix.portfolio;
	cp = decisionData.CP_DAY01.data;
	% Calculate the dual simple moving averages: In this case with a lead of 21 days
	% and a lag of 55 days. 
	[leadMA, lagMA] = movavg(cp, 21, 55);
	% Using these variables, recalulate the appropraite postion for our portfolio
	if (leadMA(end) > lagMA(end))
		if (count < 0)
			count = 0; %Reset the count on a crossover
		end
		count = count + 1;
		% If and only if count is at least 3, change our position in the portfolio.
		% This filter should make rapid whipsaw less likely.
		if (count >= 3)
			portfolio = 1;
		end
	elseif (leadMA(end) < lagMA(end))
		if (count > 0)
			count = 0; %Reset the count on a crossover
		end
		count = count - 1;
		% If and only if count is at least 3, change our position in the portfolio.
		% This filter should make rapid whipsaw less likely.
		if (count <= -3)
			portfolio = -1;
		end
	%Else our portfolio remains the same
	else
		portfolio = stateMatrix.portfolio;
	end
	% Update the stateMatrix/Portfolio postions
	newStateMatrix = stateMatrix;
	newStateMatrix.portfolio = portfolio;
    newStateMatrix.count = count;
end