function shifted=brk_shift_zeropad(ts,num)
%shifts 1D
B = circshift(ts,num);
if num>0
    B(1:num) = 0;
else
    B((size(B)+double(num)+1):end) = 0;
end

shifted=B;