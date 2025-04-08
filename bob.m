% The "bob" class simulates Bob's actions in the EKSQPC protocol.
% Bob decides whether to reflect the incoming qubit or measure it.
classdef bob
    methods
        function [action, measurement] = reflectOrMeasure(~)
            %   action: 0 = reflect (for probing), 1 = measure (for data)
            %   measurement: if action = 1, it's Bob's measurement result (0 or 1)
            %                if action = 0, measurement is NaN (not applicable)
            
            action = floor(rand() * 2);   % Randomly choose 0 or 1
            
            if action == 1
                measurement = floor(rand() * 2); 
            else
                measurement = NaN; 
            end
        end
    end
end
