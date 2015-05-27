function save_siamese_pairs(siamese_pairs, save_path)

outputDir = fileparts(save_path);

if ~exist(outputDir, 'dir')
  mkdir(outputDir)
end

%
% saving
%
fid = fopen(save_path, 'w');

for ix = 1:size(siamese_pairs,1)
  fprintf(fid, '%s %s %d\n', siamese_pairs{ix,1}, siamese_pairs{ix,2}, siamese_pairs{ix,3});
end

fclose(fid);