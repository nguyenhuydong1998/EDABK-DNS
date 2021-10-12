function mae = MAE(a,b)
    la = length(a);
    lb = length(b);
    mae =0;
    for i = 1:min(la,lb)
        mae = mae + abs(a(i)-b(i));
    end
    mae = mae/min(la,lb);
end