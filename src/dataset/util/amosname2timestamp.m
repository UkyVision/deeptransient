function yyyymm = amosname2timestamp(amosname)

[~, name] = fileparts(amosname);

if isempty(strfind(name, '_'))
  yyyymm = [];
  return;
end

temp = strsplit(name, '_');
temp = temp{1};
yyyymm = [temp(1:4) '-' temp(5:6)];