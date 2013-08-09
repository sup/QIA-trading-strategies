function [ portfolio, newStateMatrix ] = bollingerBands( decisionData, stateMatrix )

% @Author = Charles Lai
% bollingerBands - A Bollinger Band Strategy
% Type: Trend Following - Channel Breakout Strategy
% Parameters: 
% Description: The Bollinger Band strategy is a type of channel breakout trading 
%			   strategy using a volatility indicator similar to a Keltner Channel.
%			
%			   Specifiically, this is a simple Bollinger Band strategy that works
%			   well for securities that never trend. The theory is that the stock
% 			   valuation is fair and that the price shouldn't deviate much from a
%			   historical moving average. If the price does deviate from that MA,
%			   we bet in the opposite direction, i.e., that the stock should return
%			   to its fair valuation. This is similar to a contrarian moving average
%			   crossover strategy, but utilizing volatility as a channel for arbitrage.
%
% NOTE: I've noticed that Chinese stocks seems to behave contrary to some traditional strategies
%		In that it is very profitable to use a contrarian trading strategy. Adjust as needed.

	% Initialize the stateMatrix/Portfolio with zero postions and any starting global variables
	if isempty(stateMatrix)
        portfolio = zeros(1,1);
        stateMatrix.portfolio = portfolio;
    end
	% Calculate the required variables: Price Vector
	portfolio = stateMatrix.portfolio;
	cp = decisionData.CP_DAY01.data;
	% Calculate the Bollinger Bands and the Moving Average.
	[~, upperBand, lowerBand] = bollinger(cp);
	% Using these variables, recalulate the appropriate postion for our portfolio
	% In this case, we bet in the opposite direction of the trend
	if (cp(end) < lowerBand(end))
		portfolio = 1;
	elseif (cp(end) > upperBand(end))
		portfolio = -1;
	%Else our portfolio remains the same as the las position.
	else
		portfolio = stateMatrix.portfolio;
	end
	% Update the stateMatrix/Portfolio postions
	newStateMatrix = stateMatrix;
	newStateMatrix.portfolio = portfolio;
end
