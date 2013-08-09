function [ portfolio, newStateMatrix ] = MACDHist( decisionData, stateMatrix )

% @Author = Charles Lai
% MACDHist - MACD Histogram Retracement Strategy
% Type: Oscillator Strategy
% Parameters: MACDVec - 12-Day EMA of close - 26-Day EMA of close
%             MACDSignal - 9-Day EMA of MACDVec
%             hist - MACDVec - MACDSignal

% Description: This is a technique based on the widely used Moving Average 
%              Convergence/Divergence indicator that creates buy and sell
%              signals from cross-overs. This is a varaition of the MACD strat:
%              we create a histogram based off prior min and max spreads between
%              the MACD line and the signal line to predict retracement and thus
%              enter the market on a trend faster. This specific strategy generates
%              a buy signal if the histogram retraces 45% of its prior trough when
%              below zero and generates a sell signal if the histogram retraces 45%
%              of its prior peak above zero.
%              
% NOTE: Add a threshold histogram level to prevent whipsawing back and forth

% Initialize the starting varaibles and potfolio if not initialized
    global histMax histMin
    if isempty(stateMatrix)
        portfolio = zeros(1,1);
        histMax = 0; % Set the min/aax values as 0 to start
        histMin = 0;
        stateMatrix.portfolio = portfolio;
    end
    % Calculate the the required variables: Price Vector
    portfolio = stateMatrix.portfolio;
    cp = decisionData.CP_DAY01.data;
    % Calculate the MACD/Signal Line/Histogram
    [MACDVec, MACDSignal] = macd(cp(:));
    hist = MACDVec(end) - MACDSignal(end);
    % Update the histogram minimums and maximums: 
    % If we are negative, set peak to 0 and update the histogram minimum
    if (hist < 0 && hist < histMin)
        histMax = 0;
        histMin = hist;
    % If we are positive set minimum to 0 and update the histogram maximum
    elseif (hist > 0 && hist > histMax)
        histMax = hist;
        histMin = 0;
    % Calculate if we generate a buy signal or not based on our retracement parameters
    elseif (hist < 0 && hist > histMin+.45*(-histMin))
        portfolio = 1;
    elseif(hist > 0 && hist < histMax+.45*(-histMin))
        portfolio = -1;
    % Else, keep our portfolio position the same
    else
        portfolio = stateMatrix.portfolio;
    end
    % Update the stateMatrix/Portfolio Positions
    newStateMatrix = stateMatrix;
    newStateMatrix.portfolio = portfolio;
    %End iterative calculations
end