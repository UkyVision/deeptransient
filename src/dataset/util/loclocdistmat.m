function d = loclocdistmat(loc1, loc2)
%
% size(loc1) = mxp, size(loc2) = nxp
% size(d) = mxn
%

m = size(loc1,1);
n = size(loc2,1);

[Y, X] = meshgrid(1:n, 1:m);  % row --> Y, col --> X
d = distance(loc1(X(:), :), loc2(Y(:), :), referenceSphere('earth', 'km'));
d = reshape(d, m, n);

%
% testing script
%
% lt1 = rand(3,2);
% lt2 = rand(4,2);
% 
% test0 = loclocdistmat(lt1, lt2);
% 
% test = nan(size(lt1,1), size(lt2,1));
% for i = 1:size(lt1,1)
%   for j = 1:size(lt2,1)
%     test(i,j) = distance(lt1(i,:), lt2(j,:), referenceSphere('earth', 'km'));
%   end
% end
% disp(test0)
% disp(test)