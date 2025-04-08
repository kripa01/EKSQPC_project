clear; clc;

n = 10;               % Number of qubits
p_attack = 0.6;       % Eve's attack probability

fprintf("=== EKSQPC DEMO ===\n");

% Initialize Alice and Bob
alice = alice();
alice = alice.generateEPRPairs(n);

bob = bob();
attackDetected = false(1, n);

for k = 1:n
    [action, ~] = bob.reflectOrMeasure();

    eveAttacks = rand() < p_attack;  % Simulate Eve's attack

    if action == 0
        % Probing bit (MRAD)
        attackDetected(k) = alice.checkMRAD(k, eveAttacks);
        fprintf("[Q%d - Probe] Attack Detected: %d\n", k, attackDetected(k));

    else
        % Data bit (OBP + Tele-Fetch)
        [e1, e2] = alice.bellMeasurement(alice.eprStates{k});
        uB = alice.teleFetch(alice.ik_values(k), e1, e2);
        fprintf("[Q%d - Data] Bob measured. Alice inferred bit: %d\n", k, uB);
    end
end

% Final summary
fprintf("\n=== SUMMARY ===\n");
fprintf("Detected %d attacks out of %d qubits\n", sum(attackDetected), n);

% === Plot Summary ===
%figure to be displayed 
figure;
bar([probeCount, sum(attackDetected), dataCount]);
xticklabels({'Probes', 'Attacks Detected', 'Data Qubits'});
ylabel('Count');
title('EKSQPC Protocol Summary');
grid on;