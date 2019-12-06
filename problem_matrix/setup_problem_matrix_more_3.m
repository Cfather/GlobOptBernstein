function [cost,constraints,feasible_point] = setup_problem_matrix_more_3(num)
cost = [[   0,   0,                           43456.4]
        [ 1.0,   0,                          -190208.0]
        [ 2.0,   0,                           285952.0]
        [ 3.0,   0,                          -322560.0]
        [ 4.0,   0,                           554496.0]
        [ 5.0,   0,                          -655360.0]
        [ 6.0,   0,                           524288.0]
        [ 7.0,   0,                          -262144.0]
        [ 8.0,   0,                            65536.0]
        [   0, 1.0,                           -30209.6]
        [   0, 2.0,                           125953.6]
        [   0, 3.0,                          -322560.0]
        [   0, 4.0,                           554496.0]
        [   0, 5.0,                          -655360.0]
        [   0, 6.0,                           524288.0]
        [   0, 7.0,                          -262144.0]
        [   0, 8.0,                            65536.0]
        [ 1.0, 1.0,                           191488.0]
        [ 2.0, 1.0,                          -584704.0]
        [ 3.0, 1.0,                          1048576.0]
        [ 4.0, 1.0,                         -1179648.0]
        [ 5.0, 1.0,                           786432.0]
        [ 6.0, 1.0,                          -262144.0]
        [ 1.0, 2.0,                          -584704.0]
        [ 2.0, 2.0,                          1371136.0]
        [ 3.0, 2.0,                         -1835008.0]
        [ 4.0, 2.0,                          1572864.0]
        [ 5.0, 2.0,                          -786432.0]
        [ 6.0, 2.0,                           262144.0]
        [ 1.0, 3.0,                          1048576.0]
        [ 2.0, 3.0,                         -1835008.0]
        [ 3.0, 3.0,                          1572864.0]
        [ 4.0, 3.0,                          -786432.0]
        [ 1.0, 4.0,                         -1179648.0]
        [ 2.0, 4.0,                          1572864.0]
        [ 3.0, 4.0,                          -786432.0]
        [ 4.0, 4.0,                           393216.0]
        [ 1.0, 5.0,                           786432.0]
        [ 2.0, 5.0,                          -786432.0]
        [ 1.0, 6.0,                          -262144.0]
        [ 2.0, 6.0,                           262144.0]];

degree = [   0,     0;
             2,     0;
             0,     2;
             1,     1;
             1,     0;
             0,     1];
         
constraints = cell(num,1);

feasible_point = rand(2,1);

for i = 1:num
    rand_num = 10 * rand(5,1) - 5;
    coef = [0;rand_num];
    con_mat = [degree,coef];
    diff = evaluate_function(con_mat,feasible_point);
    if diff >= 0
        con_mat(1,3) = con_mat(1,3) - diff - rand() / 10;
    end
    
    constraints(i) = {con_mat};
end

end