 % The "alice" class simulates the behavior of Alice in the EKSQPC protocol.
    % Alice generates EPR pairs, performs Bell measurements, and detects attacks.

classdef alice
    properties
        ik_values % Array storing Alice's initialization key values (0 or 1) for each EPR pair
        eprStates %stores quantum EPR states for each qubit pair
    end
    methods

        % Generates n EPR pairs based on Alice's ik_values
        function obj = generateEPRPairs(obj, n) 
            obj.ik_values = floor(rand(1, n) * 2); % Randomly generate 0 or 1 for each qubit
            obj.eprStates = cell(1, n);   % Initialize cell array to store quantum states
            
            for k = 1:n
                % Create the initial gate based on ik_values (00 or 10 basis)
                if obj.ik_values(k) == 0
                    init = initGate(1:2, "00");  % Prepare |00⟩ state
                else
                    init = initGate(1:2, "10");  % Prepare |10⟩ state
                end
                % Apply H gate on qubit 1, followed by CNOT (CX) gate
                gates = [init; hGate(1); cxGate(1,2)];
                qc = quantumCircuit(gates);  % Create the quantum circuit
                obj.eprStates{k} = simulate(qc); % Simulate and store the EPR state
            end
        end
        
        % Performs a Bell measurement on the EPR state
        % Returns Bell indices (e1, e2) interpreted from the state
        function [e1, e2] = bellMeasurement(~, state)
            result = formula(state); % Extract the formula of the quantum state
            if contains(result, '|00>') && contains(result, '|11>')
                e1 = 0; e2 = 0;  % Represents Bell state Φ+
            elseif contains(result, '|00>') && contains(result, '-0.70711 * |11>')
                e1 = 1; e2 = 0; % Represents Bell state Φ-
            else
                % For unknown or noisy results, return random values
                e1 = randi([0 1]); e2 = randi([0 1]);
            end
        end
        
        % Performs MRAD (Measure and Reflect Attack Detection)
        % Compares Bell measurement with expected values to detect Eve's attack
        function attack = checkMRAD(obj, k, eveAttacked)
            state = obj.eprStates{k};
            [e1, e2] = obj.bellMeasurement(state);  % Perform Bell measurement
            ik = obj.ik_values(k);  % Get Alice's basis key for this qubit
            
            % Based on expected Bell results for each basis, check for inconsistency
            if ik == 0 && ~(e1 == 0 && e2 == 0)
                attack = true;
            elseif ik == 1 && ~(e1 == 1 && e2 == 0)
                attack = true;
            else
                attack = false;
            end
        end

        % Infers Bob's bit using Tele-Fetch logic based on Bell measurement outcomes
        function uB = teleFetch(obj, ik, e1, e2)
            if ik == 0
                if e1 == 0 && e2 == 0
                    uB = 0;
                elseif e1 == 1 && e2 == 0
                    uB = 1;
                else
                    error('Unexpected Bell result for ik=0');
                end
            elseif ik == 1
                if e1 == 1 && e2 == 0
                    uB = 0;
                elseif e1 == 0 && e2 == 0
                    uB = 1;
                else
                    error('Unexpected Bell result for ik=1');
                end
            else
                error('ik must be 0 or 1');
            end
        end
    end
end
