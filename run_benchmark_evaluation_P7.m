%% Introduction
% This is the script that runs the results for benchmark problems P7 in
% our paper V.B. All the results all stored in 'Benchmark_Evaluation/'
% named with 'P7_infos.mat' and they are consistent with what is shown 
% in this section of our paper. If you want a different comparison, 
% try to save the results in a different path.

%% setup the problem
clear; clc;
ground_truth = 1.0898639714;

eval(strcat('[raw_cost,raw_constraints] = setup_problem_matrix_P7();'));
P7_equalites = [4           0           0        0        -625;
                4           4           0        0      390625;
                0           4           1        0       -3125];
numDimension = size(raw_cost,2) - 1;

%% Bernstein Algorithm
[bernstein_cost,bernstein_constraint,cons_length] = setup_problem_bernstein(raw_cost,raw_constraints);
% run for memory analysis
verboseMode = 0;
memoryRecordMode = 1;
pcba_options = memoryRecordMode * 2 + verboseMode;
[bernstein_opt,bernstein_accuracy,bernstein_memory] = PCBA(bernstein_cost,bernstein_constraint,cons_length,P7_equalites',[3],pcba_options);

% run another 50 times to get an average time
pcba_num = 50;
verboseMode = 0;
memoryRecordMode = 0;
pcba_options = memoryRecordMode * 2 + verboseMode;
bernstein_time_set = nan(pcba_num,1);
for num = 1:pcba_num
    bernstein_start_t = tic;
    [bernstein_opt,bernstein_accuracy] = PCBA(bernstein_cost,bernstein_constraint,cons_length,P7_equalites',[3],pcba_options);
    bernstein_time_set(num) = toc(bernstein_start_t);
end

if bernstein_opt == -12345
    bernstein_exitflag = -1;
else
    bernstein_opt = bernstein_opt(:,1);
    bernstein_exitflag = 1;
    [bernstein_value,bernstein_feasibility,bernstein_violate_terms,bernstein_difference] = evaluate_opt_result(raw_cost,raw_constraints,bernstein_opt);
end

%% fmincon
clc;
fmincon_num = 50;
fmincon_time_set = nan(fmincon_num, 1);
fmincon_value_set = nan(fmincon_num, 1);
fmincon_exit_flag = nan(fmincon_num, 1); % 1 means successful, 0 means not
fmincon_cost = @(k) setup_cost_fmincon(raw_cost,k);
fmincon_nonlcon = @(k) setup_constraints_fmincon(raw_constraints,{P7_equalites},k);

% create optimization options
options =  optimoptions('fmincon',...
                'MaxFunctionEvaluations',1e5,...
                'MaxIterations',1e4,...
                'OptimalityTolerance',bernstein_accuracy,...
                'CheckGradients',false,...
                'FiniteDifferenceType','central',...
                'Diagnostics','off',...
                'SpecifyConstraintGradient',true,...
                'SpecifyObjectiveGradient',true);

% call fmincon
for j = 1:fmincon_num
    fmincon_start_t = tic;
    initial_guess = rand(size(raw_cost,2)-1,1);
    try
        [fmincon_opt,~,fmincon_exitflag] = fmincon(fmincon_cost,...
                                    initial_guess,...
                                    [],[],... % linear inequality constraints
                                    [],[],... % linear equality constraints
                                    zeros(1,numDimension),... % lower bounds
                                    ones(1,numDimension),... % upper bounds
                                    fmincon_nonlcon,...
                                    options) ;
    catch
        fmincon_exitflag = -1 ;
    end
    fmincon_time = toc(fmincon_start_t);
    fmincon_time_set(j) = fmincon_time;
    if fmincon_exitflag ~= -1
        [fmincon_value,fmincon_feasibility,fmincon_violate_terms,fmincon_difference] = evaluate_opt_result(raw_cost,raw_constraints,fmincon_opt);
        fmincon_value_set(j) = fmincon_value;
        fmincon_exit_flag(j) = 1;
    else
        fmincon_exit_flag(j) = 0;
    end
end

%% Lasserre
Lasserre_number = 50;
BSOSsolver = 'sqlp';
SBSOSsolver = 'sqlp';
Lasserre_d = 1;
Lasserre_k = 1;
Lss_raw_constraitns = raw_constraints;
% one equality constraint is decomposed to two inequality constraints
Lss_raw_constraitns{7} = P7_equalites;
Lss_raw_constraitns{8} = [P7_equalites(:,1:4), -P7_equalites(:,5)];
Lasserre_time_set = nan(Lasserre_number,1);
Lss_constraints = scale_for_lss(Lss_raw_constraitns);
setup_Lasserre = @()setup_problem_Lasserre(raw_cost,Lss_constraints,Lasserre_d,Lasserre_k);
tag = 'setup_Lasserre';
for i = 1:Lasserre_number
    clc;
    Lasserre_start_t = tic;
    eval(['[pop.F,pop.G,pop.I,pop.J,pop.d,pop.k] = ',tag,'();']);
    k = pop.k;
    pop.n = size(pop.F,2)-1;
    psol_temp = NaN;
    for d = 1:pop.d
        %% BSOS
        algo = 'BSOS';
        solver = eval([algo,'solver',';']);
        pop.d = d; pop.k = k;
        psol_temp = lss(pop,tag,algo,solver);
        clear sdp sol psol;

        %% SBSOS
    %         algo = 'SBSOS';
    %         solver = eval([algo,'solver',';']);
    %         pop.d = d; pop.k = k;
    %         psol_temp = lss(pop,tag,algo,solver);
    %         clear sdp sol psol;
    end
    Lasserre_time_set(i) = toc(Lasserre_start_t);
    Lasserre_value = psol_temp.obj;
end

%% save the data
infos.fmincon_time_set = fmincon_time_set;
infos.fmincon_value_set = fmincon_value_set;
infos.fmincon_exit_flag = fmincon_exit_flag;
infos.bernstein_time_set = bernstein_time_set;
infos.bernstein_value = bernstein_value;
infos.bernstein_mem = bernstein_memory;
infos.bernstein_accuracy = bernstein_accuracy;
infos.Lasserre_time_set = Lasserre_time_set;
infos.Lasserre_value = Lasserre_value;
infos.Lasserre_d = Lasserre_d;
infos.Lasserre_k = Lasserre_k;
% save(strcat('Benchmark_Evaluation/P7_infos.mat'),'infos');

%% data analysis
disp('PCBA time:')
disp(median(infos.bernstein_time_set));
disp('PCBA error:')
disp(infos.bernstein_value - ground_truth);
disp('PCBA stopping crtieria:')
disp(infos.bernstein_accuracy);
disp(' ')
disp('BSOS time:')
disp(median(infos.Lasserre_time_set));
disp('BSOS error:')
disp(infos.Lasserre_value - ground_truth);
disp('BSOS d & k choice:')
disp([infos.Lasserre_d,infos.Lasserre_k]);
disp(' ')
disp('fmincon time median:')
disp(median(infos.fmincon_time_set));
disp('fmincon error median:')
disp(median(infos.fmincon_value_set) - ground_truth);