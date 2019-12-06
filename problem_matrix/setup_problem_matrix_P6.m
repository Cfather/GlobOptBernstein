function [cost,constraints] = setup_problem_matrix_P6(num)
cost = [[   0,   0,   0,   0, 6395.507828125]
        [ 1.0,   0,   0,   0, 567.11175]
        [ 2.0,   0,   0,   0, 40.070953125]
        [   0, 1.0,   0,   0, 1504.439296875]
        [   0,   0, 1.0,   0, 907.1534375]
        [   0,   0, 2.0,   0, 27.7828125]
        [ 1.0,   0, 1.0,   0, 37.2]
        [   0, 1.0, 1.0,   0, 316.7240625]
        [   0, 1.0, 2.0,   0, 16.6696875]
        [   0,   0,   0, 1.0, 720.0622]
        [ 1.0,   0,   0, 1.0, 52.24065]
        [ 2.0,   0,   0, 1.0, 9.795121875]
        [   0,   0, 1.0, 1.0, 68.464]];

g1 = [[     0,   0,   0,   0, -0.08325]
        [ 1.0,   0,   0,   0, -0.375]
        [   0,   0,   1.0, 0,  0.0965]];
  
g2 = [[   0,   0,   0,   0, -0.17185]
    [     0, 1.0,   0,   0,  -0.375]
    [     0,   0, 1.0,   0,  0.0477]];
       
g3 = [[   0,   0,   0,     0, -1086109.9856481687165796756744385]
        [ 0,   0,   1.0,   0, -276067.45443420308082990478730569]
        [ 0,   0,   2.0,   0, -21991.148575128552669238503682957]
        [ 0,   0,   3.0,   0, -523.59877559829887307710723054658]
        [ 0,   0,   0,   1.0, -155940.80534256336187418946093754]
        [ 0,   0,   1.0, 1.0, -32829.643230013339341934623355271]
        [ 0,   0,   2.0, 1.0, -1727.8759594743862811544538608037]];

g4 = [0  0  0  0  -150;
      0  0  0  1    22];
  
constraints = {g1;g2;g3;g4};

end

