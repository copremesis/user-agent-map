f=->(n){n<1?1:n*f[n-1]};0.upto(33){|n|0.upto(n){|r|print"#{f[n]/(f[r]*f[n-r])} "};puts}
