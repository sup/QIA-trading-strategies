function [ portfolio, newStateMatrix ] = keltnerChannel( decisionData, stateMatrix )

% @Author = Charles Lai
% keltnerChannel - Baseline Keltner Channel Trading Strategy
% Type: Trend Following - Channel Breakout Strategy
% Parameters: typicalPrice - 10 day simple moving average of typical price = (high+low+close)/3
%			  tradingRange - 10 day simple moving average of the past 10 days' trading ranges.
%
% Description: The basic Keltner channel trading strategy is a trend-following, channel breakout
%			   trading strategy that utilizes a typicalRange 10-day moving average as the center 
%			   line with an upper band and lower band generated from the basic trading range
%			   derived from the difference between the high price of the day and the low price
%			   of the day. A buy signal is generated when
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
	% Calculate the typicalPrice and tradingRange moving averages.
	counter = 0;
    typicalPrice = zeros(1, 1000);
    tradingRange = zeros(1, 1000);
    % Find each point for the moving averages
    while (counter < 1000)
        counter = counter + 1;
    	typicalPricePoint = ((hip(counter)+lop(counter)+cp(counter))/3);
    	tradingRangePoint = (hip(counter)-lop(counter));
        typicalPrice(1,counter) = typicalPricePoint;
        tradingRange(1,counter) = tradingRangePoint;
    end
    % Reverse the vectors so that the most recent price is at the end of the vector
    typicalPrice = fliplr(typicalPrice);
    tradingRange = fliplr(tradingRange);
    % Calculate the moving averages
	[typicalPrice] = movavg(typicalPrice, 10, 10);
	[tradingRange] = movavg(tradingRange, 10, 10);
	% Calculate the upper and lower bands
	upperBand = typicalPrice(end) + tradingRange(end);
	lowerBand = typicalPrice(end) - tradingRange(end);
	% Using these variables, recalulate the appropriate postion for our portfolio
	if (cp(end) > upperBand)
		portfolio = 1;
	elseif (cp(end) < lowerBand)
		portfolio = -1;
	%Else our portfolio remains the same
	else
		portfolio = stateMatrix.portfolio;
	end
	% Update the stateMatrix/Portfolio postions
	newStateMatrix = stateMatrix;
	newStateMatrix.portfolio = portfolio;
end