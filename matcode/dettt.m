function ans1 = dettt(a)
[row, column] = size(a);
list_ans = [];
for i = 1:row
    row_list = [];
    for j = 1:column
        if (a(i,j) ~= 1)
            row_list = [row_list, a(i,j)];
        end 
    end
    list_ans = [list_ans, row_list];
end
ans1 = list_ans;
end