clear; clc;

n = 10;               % Number of qubits to be exchanged in the protocol
p_attack = 0.6;       % Probability that Eve (the attacker) interferes with a qubit

fprintf("=== EKSQPC DEMO ===\n");

% Initialize Alice and Bob
alice = alice();  % Create Alice instance
alice = alice.generateEPRPairs(n);  % Alice generates n EPR entangled pairs

bob = bob();  % Create Bob instance
attackDetected = false(1, n);  % Boolean array to store MRAD detection results

% Counters for analysis
probeCount = 0;
detectedCount = 0;
dataCount = 0;

for k = 1:n
    [action, ~] = bob.reflectOrMeasure(); % Bob decides randomly: 0 = Probe, 1 = Measure

    eveAttacks = rand() < p_attack;    % Simulate whether Eve attacks this qubit

    if action == 0
    % For probes: MRAD is used to detect eavesdropping
    probeCount = probeCount + 1;
    attackDetected(k) = alice.checkMRAD(k, eveAttacks);  % Check for Eve's interference
    fprintf("[Q%d - Probe] Attack Detected: %d\n", k, attackDetected(k));
    else
    % For data: Bob measures, Alice uses Tele-Fetch to infer the bit
    dataCount = dataCount + 1;
    [e1, e2] = alice.bellMeasurement(alice.eprStates{k}); % Alice performs Bell measurement
    uB = alice.teleFetch(alice.ik_values(k), e1, e2);   % Alice infers Bob's measured bit
    fprintf("[Q%d - Data] Bob measured. Alice inferred bit: %d\n", k, uB);
    end
end

% Final summary
fprintf("\n=== SUMMARY ===\n");
fprintf("Detected %d attacks out of %d qubits\n", sum(attackDetected), n);

% === Plot Summary ===
figure;
bar([probeCount, sum(attackDetected), dataCount]);
xticklabels({'Probes', 'Attacks Detected', 'Data Qubits'});
ylabel('Count');
title('EKSQPC Protocol Summary');
grid on;