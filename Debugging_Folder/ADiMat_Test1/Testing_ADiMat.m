clear; clc; close all;
opts = admOptions();
opts.flags = '--cgi-param auth=0190d42f-62ac-46ee-8a43';

a = [9 1 6];
b = [2 5 3];
% compute Jacobian via forward-mode
J = admDiffFor(@Test_Function, 1, a, b, opts)
% compute Jacobian via reverse-mode
Jrev = admDiffRev(@Test_Function, 1, a, b, opts)