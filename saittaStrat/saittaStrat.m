function [ portfolio, newStateMatrix ] = saittaStrat( decisionData, stateMatrix )

% @Author = Charles Lai
% saittaStrat - Saitta's Support and Resistance Strategy
% Type: Trend Following Strategy
% Parameters: highMA = 20-Day Moving Average of Highs
%			  lowMA = 20-Day Moving Average of Lows
%
% Description: The strategy begins with a 20-day simple moving average of highs and lows. When prices
%			   rise above the average of highs, the market has ended a negative phase and entered a
%			   positive phase. When the market falls below the average of lows, a positve trend has 
%			   ended and a negative trend has started. This is combined with determining previous
%			   tops and bottoms. At the time of a new uptrend, the method looks for the lowest closing
%			   price over the prior downtrend for the market bottom, and at the time of a new downtrend,
%			   the method looks for the highest closing price over the prior uptrend for the market top.
%			   These tops and bottoms define support and resistance points. Long positions for the strategy
%			   are entered when prices rise above a previous market top, while short positions are entered when
%			   prices fall below a previous market bottom.
%
% NOTE: I've noticed that a low of strategies are more profitable when created in a contrarian way
%       I have no idea why.
	
	% Initialize the stateMatrix/Portfolio with zero postions and any starting global variables
	if isempty(stateMatrix)
        portfolio = zeros(1,1);
        stateMatrix.portfolio = portfolio;
        stateMatrix.bottom = 0;
        stateMatrix.top = 10000;
        stateMatrix.count = 0;
        stateMatrix.isUpTrend = 0;
        stateMatrix.isDownTrend = 0;
    end
	% Calculate the required variables: Price Vectors for closing, highs, and lows.
	portfolio = stateMatrix.portfolio;
    bottom = stateMatrix.bottom;
    top = stateMatrix.top;
    count = stateMatrix.count;
    isUpTrend = stateMatrix.isUpTrend;
    isDownTrend = stateMatrix.isDownTrend;
	cp = decisionData.CP_DAY01.data;
	hip = decisionData.HIP_DAY01.data;
	lop = decisionData.LOP_DAY01.data;
	volume = decisionData.CQ_DAY01.data;
	% Calculate the 20-moving averages for highs and lows.
	highMA = movavg(hip, 20, 20);
	lowMA = movavg(lop, 20, 20);
	% Using these variables dynamically find the Saitta Support and Resistance Points according
	% to the above description given.
	% New Uptrend
	if (cp(end) > highMA(end) && ~isUpTrend)   
		bottom = min(cp(end-count:end)');
		count = 0;
		isUpTrend = 1;    % Update our uptrend/downtrend status
		isDownTrend = 0;
	% New Downtrend
	elseif (cp(end) < lowMA(end) && ~isDownTrend)
        top = max(cp(end-count:end)');
		count = 0;
		isDownTrend = 1;  % Update our uptrend/downtrend status
		isUpTrend = 0;
	end
	% Using the support and resistance points, recalculate our portfolio positions
	if (cp(end) > top)
		portfolio = 1;
	elseif (cp(end) < bottom)
		portfolio = -1;
	% Else our portfolio remains the same
	else
		portfolio = stateMatrix.portfolio;
	end
	% Update the stateMatrix/Portfolio postions
	newStateMatrix = stateMatrix;
	newStateMatrix.portfolio = portfolio;
	count = count + 1;
    newStateMatrix.count = count;
    newStateMatrix.top = top;
    newStateMatrix.bottom = bottom;
    newStateMatrix.isUpTrend = isUpTrend;
    newStateMatrix.isDownTrend = isDownTrend;
end