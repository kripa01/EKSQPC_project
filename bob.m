classdef bob
    methods
        function [action, measurement] = reflectOrMeasure(~)
            % Bob randomly decides to reflect (0) or measure (1)
            action = floor(rand() * 2);  % 0 = reflect, 1 = measure
            
            if action == 1
                measurement = floor(rand() * 2);  % Z-basis result: 0 or 1
            else
                measurement = NaN;
            end
        end
    end
end
