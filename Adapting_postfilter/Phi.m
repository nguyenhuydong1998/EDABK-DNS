function sum = Phi(s,a,b)
    % input s = previous speech frame + current frame; 
    % a, b = pitch lag;
    % output : value of function phi 
    l = length(s)/2;
    sum = 0;
    for i = 1:1:l
        sum = sum + s(i+(l-a))*s(i+(l-b));
    end
end

