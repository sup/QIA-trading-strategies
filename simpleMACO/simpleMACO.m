function [ portfolio, newStateMatrix ] = simpleMACO( decisionData, stateMatrix )

% @Author = Charles Lai
% simpleMACO - Simple Moving Average Crossover Strategy
% Type: Trend Following Strategy
% Parameters: leadMA - the leading moving average line
%			  lagMA - the lagging moving average line

% Description: The Simple Moving Average Crossover Strategy is a basic, yet effective
%			   trading strategy in trending markets. Simply buy when the lead>lag and 
%			   short/sell if the lead<lag.
%
%			   However, if there aren't measures in place to prevent rapid buy/sell signals 
%              in a stagnant market, the basic Simple Moving Average Crossover will cause a 
%			   significant loss of capital. 
%
% NOTE: I've noticed that Chinese stocks seems to behave contrary to the traditional MACO strategy
%		In that it is very profitable to short uptrends and long downtrends. I have no clue why.

	% Initialize the stateMatrix/Portfolio with zero postions and any starting global variables
	if isempty(stateMatrix)
        portfolio = zeros(1,1);
        stateMatrix.portfolio = portfolio;
    end
	% Calculate the required variables: Price Vector
	portfolio = stateMatrix.portfolio;
	cp = decisionData.CP_DAY01.data;
	% Calculate the dual simple moving averages: In this case with a lead of 21 days
	% and a lag of 55 days. 
	[leadMA, lagMA] = movavg(cp, 21, 55);
	% Using these variables, recalulate the appropraite postion for our portfolio
	if (leadMA(end) > lagMA(end))
		portfolio = 1;
	elseif (leadMA(end) < lagMA(end))
		portfolio = -1;
	%Else our portfolio remains the same
	else
		portfolio = stateMatrix.portfolio;
	end
	% Update the stateMatrix/Portfolio postions
	newStateMatrix = stateMatrix;
	newStateMatrix.portfolio = portfolio;
end