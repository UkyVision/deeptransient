%
% given 2 sets of timestamps, return the shared timestamps with a tolerent
% error
%
function [Iids, Jids, Nids] = shared_frames(tsI, tsJ, minSlot)

minT = min([tsI(:); tsJ(:)]);
maxT = max([tsI(:); tsJ(:)]);

edges = minT:minSlot:(maxT+minSlot);

[bincI, indI] = histc(tsI, edges);
[bincJ, indJ] = histc(tsJ, edges);

% find time-shared frames
[~, Iids, Jids] = intersect(indI, indJ);

Nids = numel(Iids);

%
% test
%
if Nids
  delta = abs(tsI(Iids) - tsJ(Jids));
  assert(max(delta) < minSlot)
end