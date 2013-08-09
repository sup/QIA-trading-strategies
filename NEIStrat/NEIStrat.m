function [ portfolio, newStateMatrix ] = NEIStrat( decisionData, stateMatrix )

% @Author = Charles Lai
% NEIStrat - Normalized Envelope Indicator Strategy
% Type: Trend Following strategy
% Parameters: NEI - (Close - Mean of Past 50 Closes)/STD of Past 50 Price Changes
%			  Upper NEI Band - Today's 50 Day MA + Value of 10th Ranked NEI (DESC)
%			  Lower NEI Band - Today's 50 Day MA + Value of 40th Ranked NEI (DESC)
%
% Description: Envelopes are formed by plotting two bands around the moving average—one above 
%			   and one below. Historically this had been accomplished by multiplying the 
%			   average by two constants. Typically, the moving average is multiplied by 105 
%			   percent to arrive at the upper band and 95 percent to calculate the lower band.
%			   Then traders would create a profitable oppurtunity - buy when prices touched the
%			   lower band and sell when prices touched the upper band.
%
%			   This NEI or Normalized Envelope Strategy seeks to automatically draw two envelopes
%			   based on recent optimal displacement. After the noted calculations, we enter
%			   short when prices rise above and then fall below the upper NEI band and enter 
%			   long when prices fall below and then rise above the lower NEI band.
%
% NOTE: Still need slight fixing. For some reason no positions are taken. Check if it is function
%       fault or if we need to backtest the strategy on a different security

    % Calculate the the required variables: Price Vector/50 Day MA/NEI Array/Upper NEI Band/Lower NEI Band
    global isFirstRun
    cp = decisionData.CP_DAY01.data;
    % Initialize the starting state matrix and portfolio. Set the logical variable indicating first run to 1.
    if (isempty(stateMatrix))
        portfolio = zeros(1, 1);
        stateMatrix.portfolio = portfolio;
        stateMatrix.isAboveUNEI = 0;
        stateMatrix.isBelowLNEI = 0;
        stateMatrix.counter = 0;
        isFirstRun = 1;
    end
    counter = stateMatrix.counter;
    isAboveUNEI = stateMatrix.isAboveUNEI;
    isBelowLNEI = stateMatrix.isBelowLNEI;
    % Calculate the fifty day mean and moving average
    fiftyDayMean = sum(cp(end-50:end))/50;
    fiftyDayMA = movavg(cp,50,50);
    % Calculate the array of NEI values iteratively and sort them
    NEIArray = zeros(1, 50);
    while (counter < 50)
        NEI = (cp(end-counter) - fiftyDayMean)/(std(cp(end-50:end)));
        counter = counter + 1;
        NEIArray(1,counter) = NEI;
    end
    NEIArray = sort(NEIArray, 'descend');
    % Calculate the Upper NEI Band and the Lower NEI Band
    upperNEIBand = fiftyDayMA(end) + NEIArray(1, 10);
    lowerNEIBand = fiftyDayMA(end) + NEIArray(1, 40);
    % Initialize default isAboveUNEI and isBelowLNEI boolean values
    if (isFirstRun)
        if(cp(end) > upperNEIBand)
            isAboveUNEI = 1;
        elseif(cp(end) < lowerNEIBand)
            isBelowLNEI = 1;
        end
        isFirstRun = 0; %Finally, set isFirstRun to 1 to stop first run initializations on the next iteration.
    end
    % Iterative calculation of our portfolio positions
    portfolio = stateMatrix.portfolio;
    % If the CP has crossed over a band again after crossing over it once, recalculate portfolio positions.
    if (isBelowLNEI == 1)
        if (cp(end) > lowerNEIBand)
        portfolio = 1;
        isBelowLNEI = 0;
        end
    elseif (isAboveUNEI == 1)
        if (cp(end) < upperNEIBand)
        portfolio = -1;
        isAboveUNEI = 0;
        end
    end
    % Then reset and update the isAboveUNEI or isBelowLNEI boolean values
    if(isBelowLNEI == 0)
        if (cp(end) < lowerNEIBand)
            isBelowLNEI = 1;
        end
    elseif(isAboveUNEI == 0)
        if (cp(end) > upperNEIBand)
            isAboveUNEI = 1;
        end
    % Else, keep everything the same for the next iteration.
    else
        portfolio = stateMatrix.portfolio;
    end
    % Update the stateMatrix/Portfolio Positions
    newStateMatrix = stateMatrix;
    newStateMatrix.portfolio = portfolio;    
    newStateMatrix.isAboveUNEI = isAboveUNEI;
    newStateMatrix.isBelowLNEI = isBelowLNEI;
end
    