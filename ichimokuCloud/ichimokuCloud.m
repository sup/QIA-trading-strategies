function [ portfolio, newStateMatrix ] = ichimokuCloud( decisionData, stateMatrix )

% @Author = Charles Lai
% ichimokuCloud - Ichimoku Kinko Hyo - (One Glance Equilibrium Chart)
% Type: Trend Following Strategy
% Parameters: tenkanSen - (Conversion Line) - (9-period high + 9 period low)/2)) 
%			  kijunSen - (Base Line) - (26-period high + 26-period low)/2
%			  senkouSpanA - (Leading Span A) - (Conversion Line + Base Line)/2
%			  senkouSpanB - (Leading Span B) - (52-period high + 52-period low)/2
%			  chikouSpan - (Lagging Span) - Close plotted 26 periods in the past
%			  kumoMax - (cloud Max) - The highest point in the cloud = max(senkouSpanA, senkouSpanB)
%		      kumoMin - (cloud Min) - The lowest point in the cloud = min(senkouSpanA,senkouSpanB)
%
% Description: This version of an Ichimoku Cloud automated trading strategy will only respond to 
%			   strong bearish or bullish signals. Medium or weak signals will be ignored. A strong
%			   buy signal is generated if: the tenkan-sen is crossing above the kijun-sen, the price
%			   action is above the kumo (cloud), chikouSpan is above the cloud, and the cross-over is
%			   above the cloud. A strong sell signal is generated if: the tenkan-sen is crossing below
%			   the kinjun-sen, the price action is below the cloud, the chikouSpan is below the cloud and
%			   the cross-over is below the cloud. Or if we have started on a strong bullish/bearish trend and 
%			   the first three conditions are met, we stay in the trade. Else we exit all trades and reset.
%
%			   Yes, there is a possibility that no positions will be taken.
%
%
% NOTE: I've noticed that Chinese stocks seems to behave contrary to the traditional MACO strategy
%		In that it is very profitable to short uptrends and long downtrends. I have no clue why.
	
	% Initialize the stateMatrix/Portfolio with zero postions and any starting global variables
	if isempty(stateMatrix)
        portfolio = zeros(1,1);
        stateMatrix.portfolio = portfolio;
        stateMatrix.isBullish = 0;
        stateMatrix.isBearish = 0;
    end
	% Calculate the required variables: Price Vectors of Close, Low, and High
	portfolio = stateMatrix.portfolio;
    isBullish = stateMatrix.isBullish;
    isBearish = stateMatrix.isBearish;
	cp = decisionData.CP_DAY01.data;
	hip = decisionData.HIP_DAY01.data;
	lop = decisionData.LOP_DAY01.data;
	% Calculate the tenkanSen, kijunSen, senkouSpanA, senkouSpanB, chikouSpan, and kumo values
	tenkanSen = (max(hip(end-9:end)')+min(lop(end-9:end)'))/2;
	kijunSen = (max(hip(end-26:end)')+min(lop(end-26:end)'))/2;
	senkouSpanA = (tenkanSen+kijunSen)/2;
	senkouSpanB = (max(hip(end-52:end)')+min(lop(end-52:end)'))/2;
	chikouSpan = cp(end-26);
	kumoMax = max(senkouSpanA, senkouSpanB);
	kumoMin = min(senkouSpanA, senkouSpanB);
	% Recalculate our portfolio positions according to the rules in the description
	if (tenkanSen > kijunSen && cp(end) > kumoMax && chikouSpan > kumoMax && kijunSen > kumoMax && tenkanSen > kumoMax)
		portfolio = 1;
		isBullish = 1;
		isBearish = 0;
	elseif (tenkanSen < kijunSen && cp(end) < kumoMin && chikouSpan < kumoMin && kijunSen < kumoMin && tenkanSen < kumoMin)
		portfolio = -1;
		isBearish = 1;
		isBullish = 0;
    end
	if (isBullish && tenkanSen > kijunSen && cp(end) > kumoMax && chikouSpan > kumoMax)
		portfolio = 1;
	elseif (isBearish && tenkanSen < kijunSen && cp(end) < kumoMax && chikouSpan < kumoMax)
		portfolio = -1;
	% Else we exit all of our trades and reset for the next iterations
	else
		portfolio = 0;
		isBullish = 0;
		isBearish = 0;
	end
	% Update the stateMatrix/Portfolio postions
	newStateMatrix = stateMatrix;
	newStateMatrix.portfolio = portfolio;
    newStateMatrix.isBullish = isBullish;
    newStateMatrix.isBearish = isBearish;
end