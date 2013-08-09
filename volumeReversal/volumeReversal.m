function [ portfolio, newStateMatrix ] = volumeReversal( decisionData, stateMatrix )

% @Author = Charles Lai
% volumeReversal - Volume Reversal Trading Strategy
% Type: Trend Following Strategy
% Parameters: fiveDayRange - Five-Day absolute price change of the security
%			  fiveDayVolume - Five-Day Average Volume of the security
%			  oldFiveDayVolume - 10 Day Old, Five-Day Average Volume of the security
%			  hundredDaySTD - 100 Day Standard Deviation of Price Changes
%
% Description: A volume reversal trading strategy inspired by much of the work done by Michael Cooper
%			   at Purdue. For entries, we require that the five-day absolute price change be greater 
%			   than the 100-day standard deviation of price changes and the five-day average volume
%			   be less than 75 percent of the five-day average volume beginning 10 days prior.
%
%			   We enter long if the most recent five-day prive change is negative and we enter short
%			   if the most recent five-day price change is positive.
%
%			   	All entries exited on the 5th day of the trade.
%
% NOTE: I've noticed that Chinese stocks seems to behave contrary to the traditional MACO strategy
%		In that it is very profitable to short uptrends and long downtrends. I have no clue why.

	% Initialize the stateMatrix/Portfolio with zero postions and any starting global variables
	if isempty(stateMatrix)
        portfolio = zeros(1,1);
        stateMatrix.portfolio = portfolio;
        stateMatrix.count = 1;
        stateMatrix.inTrade = 0;
    end
	% Calculate the required variables: Price Vector and Volume Vector
    count = stateMatrix.count;
	portfolio = stateMatrix.portfolio;
    inTrade = stateMatrix.inTrade;
	cp = decisionData.CP_DAY01.data;
	volume = decisionData.CQ_DAY01.data;
	% Calculate 5 Day absolute price change/5 day Average Volume/10 day old 5 Day Average Volume/100 day STD
	fiveDayRange = cp(end) - cp(end-5);
	fiveDayVolume = volume(end) - volume(end-5);
	oldFiveDayVolume = volume(end-10) - volume(end-15);
	hundredDaySTD = std(cp(end-100:end));
	% Using these variables, recalulate the appropraite postion for our portfolio
	if (fiveDayRange < 0 && fiveDayRange > hundredDaySTD && fiveDayVolume < .75*oldFiveDayVolume && ~inTrade)
		portfolio = 1;
		inTrade = 1;
	elseif (fiveDayRange > 0 && fiveDayRange > hundredDaySTD && fiveDayVolume < .75*oldFiveDayVolume && ~inTrade)
		portfolio = -1;
		inTrade = 1;
	% If we are in the middle of a trade, stay in the trade and don't change
	elseif (inTrade == 1)
		portfolio = stateMatrix.portfolio;
		count = count + 1;
	% On the fifth day of the trade, we exit all entries and reset the count and inTrade
	elseif (count == 5)
		portfolio = 0;
		count = 0;
		inTrade = 0;
    end
	% Update the stateMatrix/Portfolio postions
	newStateMatrix = stateMatrix;
	newStateMatrix.portfolio = portfolio;
    newStateMatrix.inTrade = inTrade;
    newStateMatrix.count = count;
end
