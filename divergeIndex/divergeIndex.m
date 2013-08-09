function [ portfolio, newStateMatrix ] = divergeIndex( decisionData, stateMatrix )

% @Author = Charles Lai
% divergeIndex - Divergence Index Strategy
% Type: Trend Following Strategy
% Parameters: tenDayMom - Today's CP - 10 Day Ago CP
%             fortyDayMom - Today's CP - 40 Day Ago CP
%             fortyDayVar - Price Variance of the last 40 CPs
%			  divIndex - (Ten Day Momentum * Forty Day Momentum)/Forty Day Price Variance
%
% Description: More times than not, the 10-day and 40-day trend are the
% 			   same when measured by simple momentum. When both momentum values are
%			   of the same sign (positive or negative), it leads to positive values for the
%			   Divergence Index. If we multiply two positive numbers together, the product is
%			   positive. Multiplying two negative numbers also leads to a positive value. 
%
%			   We focus on the negative values of the Divergence Index for establishing new
%			   entries. If one momentum measure is positive while the other is negative, it suggests
%			   that a short-term divergence in the longer term trend is occurring. When
%			   the Divergence Index is negative, we want to make trades in the direction of the
%			   longer term trend.
%
%			   Long entries are established when the Divergence Index is less than â€?0 and
%			   40-day momentum is greater than zero. Sell signals are generated when the
%			   Divergence Index is less than â€?0 and 40-day momentum is less than zero.
%
% NOTE: This strategy is ineffective if you dont already start with a position in the security.
%       This will have to be fixed at a later date.
	
	% Initialize the stateMatrix and the portfolio with zero positions
    if isempty(stateMatrix)
        portfolio = zeros(1,1);
        stateMatrix.portfolio = portfolio;
    end
    % Calculate the required variables: the price vector, Ten/Forty Day Momentum.
    % the Forty Day Price Variance, and the Divergence Index
    portfolio = stateMatrix.portfolio;
    cp = decisionData.CP_DAY01.data;
    tenDayMom = cp(end) - cp(end-10);
    fortyDayMom = cp(end) - cp(end-40);
    fortyDayVar = var(cp(end-40:end));
    divIndex = (tenDayMom*fortyDayMom)/fortyDayVar;
    % Determine the correct position for the security. If the Divergence Index is < -10
    % and the Forty Day Momentum is >0 or <0 - long or short the security respectively
    if (divIndex < (-10) && fortyDayMom > 0)
      	portfolio = 1;
    elseif (divIndex < (-10) && fortyDayMom < 0)
       	portfolio = -1;
    % Else keep the same position as the last iteration.
    else
       	portfolio = stateMatrix.portfolio;
    end
    % Update the stateMatrix and our portfolio
    newStateMatrix = stateMatrix;
    newStateMatrix.portfolio = portfolio;
end