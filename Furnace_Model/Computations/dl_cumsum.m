function cum_alpha = dl_cumsum(alpha)
    % alpha is a row vector dlarray
    N = numel(alpha);
    cum_alpha = dlarray(zeros(1,N));
    cum_alpha(1) = alpha(1);
    for k = 2:N
        cum_alpha(k) = cum_alpha(k-1) + alpha(k);
    end
end