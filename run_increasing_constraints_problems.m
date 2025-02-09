%% Introduction
% This is the script that runs the results for the problems in
% our paper V.C. All the results all stored in 'Increasing_Number_of_Constraints/'
% named with 'more_X_infos.mat' and they are consistent with what is shown 
% in this section of our paper. If you want a different comparison, 
% try to save the results in a different path.

%% setup the problem
clear all; clc;
problem_index = 1;
total_steps = 20;
step = 10;
load(['problem_matrix/more_',num2str(problem_index),'.mat']);
raw_cost = more_problem.cost;
numDimension = size(raw_cost,2) - 1;

fmincon_num = 50;
fmincon_time_set = nan(fmincon_num,total_steps);
fmincon_value_set = nan(fmincon_num,total_steps);
fmincon_exit_flag = nan(fmincon_num,total_steps); % 1 means successful, 0 means not
bernstein_time_set = nan(total_steps,1);
bernstein_value_set = nan(total_steps,1);
bernstein_mem_set = cell(total_steps,1);
DIRECT_time_set = nan(total_steps,1);
DIRECT_value_set = nan(total_steps,1);

for i = 1:total_steps
    clc;
    disp(i);
    %% setup the constraints
    raw_constraints = more_problem.constraints(1:(i*step));
    
    %% Bernstein Algorithm
    [bernstein_cost,bernstein_constraint,cons_length] = setup_problem_bernstein(raw_cost,raw_constraints);
    verboseMode = 0;
    memoryRecordMode = 1;
    pcba_options = memoryRecordMode * 2 + verboseMode;
    bernstein_start_t = tic;
    [bernstein_opt,bernstein_accuracy,bernstein_memory] = PCBA(bernstein_cost,bernstein_constraint,cons_length,0,0,pcba_options);
    bernstein_time = toc(bernstein_start_t);
    bernstein_time_set(i) = bernstein_time;
    bernstein_mem_set{i} = bernstein_memory;
    if bernstein_opt == -12345
        bernstein_exitflag = -1;
    else
        bernstein_opt = bernstein_opt(:,1);
        bernstein_exitflag = 1;
        [bernstein_value,bernstein_feasibility,bernstein_violate_terms,bernstein_difference] = evaluate_opt_result(raw_cost,raw_constraints,bernstein_opt);
        bernstein_value_set(i) = bernstein_value;
    end
    
    %% DIRECT
    options.maxevals  = 5000;
    options.maxits    = 100;
    options.testflag  = 0;
    options.showits   = 1;
    options.tol       = bernstein_accuracy;
    DIRECT_start_t = tic;
    eval(strcat('[DIRECT_result,DIRECT_opt] = DIRECT_increasing_constraints(i*step,',num2str(problem_index),',options);'));
    DIRECT_time_set(i) = toc(DIRECT_start_t);
    [DIRECT_value,DIRECT_feasibility,DIRECT_violate_terms,DIRECT_difference] = evaluate_opt_result(raw_cost,raw_constraints,DIRECT_opt);
    DIRECT_value_set(i) = DIRECT_value;
    
    %% fmincon
    fmincon_cost = @(k) setup_cost_fmincon(raw_cost,k);
    fmincon_nonlcon = @(k) setup_constraints_fmincon(raw_constraints,{},k);

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
        fmincon_time_set(j,i) = fmincon_time;
        if fmincon_exitflag ~= -1
            [fmincon_value,fmincon_feasibility,fmincon_violate_terms,fmincon_difference] = evaluate_opt_result(raw_cost,raw_constraints,fmincon_opt);
            fmincon_value_set(j,i) = fmincon_value;
            fmincon_exit_flag(j,i) = 1;
        else
            fmincon_exit_flag(j,i) = 0;
        end
    end
end

infos.fmincon_time_set = fmincon_time_set;
infos.fmincon_value_set = fmincon_value_set;
infos.fmincon_exit_flag = fmincon_exit_flag;
infos.bernstein_time_set = bernstein_time_set;
infos.bernstein_value_set = bernstein_value_set;
infos.bernstein_mem_set = bernstein_mem_set;
infos.DIRECT_time_set = DIRECT_time_set;
infos.DIRECT_value_set = DIRECT_value_set;

%% Lasserre
Lasserre_d_choice = [3,4,2,4,2,2,2,3,2,2];
Lasserre_k_choice = [3,4,2,4,2,2,2,3,2,2];
Lasserre_d = Lasserre_d_choice(problem_index+1);
Lasserre_k = Lasserre_k_choice(problem_index+1);
Lasserre_time_set = nan(total_steps,1);
Lasserre_value_set = nan(total_steps,1);

for i = 1:total_steps
    clc;
    disp(i);
    raw_constraints = more_problem.constraints(1:(i*step));
    BSOSsolver = 'sqlp';
    SBSOSsolver = 'sqlp';
    Lss_constraints = scale_for_lss(raw_constraints);
    setup_Lasserre = @()setup_problem_Lasserre(raw_cost,Lss_constraints,Lasserre_d,Lasserre_k);
    tag = 'setup_Lasserre';
    eval(['[pop.F,pop.G,pop.I,pop.J,pop.d,pop.k] = ',tag,'();']);
    k = pop.k;
    pop.n = size(pop.F,2)-1;
    psol_temp = NaN;
    Lasserre_start_t = tic;
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
    Lasserre_time = toc(Lasserre_start_t);
    Lasserre_time_set(i) = Lasserre_time;
    Lasserre_result = psol_temp.obj;
    Lasserre_value_set(i) = Lasserre_result; 
end

infos.Lasserre_time_set = Lasserre_time_set;
infos.Lasserre_value_set = Lasserre_value_set;

%% save the data
save(['increasing_constraints/more_',num2str(problem_index),'_info.mat'],'infos');
