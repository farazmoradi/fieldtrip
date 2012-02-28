function test_ft_timelockanalysis(datainfo, writeflag, version)

% TEST test_ft_timelockanalysis
% ft_timelockanalysis test_datasets

% writeflag determines whether the output should be saved to disk
% version determines the output directory

if nargin<1
  datainfo = test_datasets;
end
if nargin<2
  writeflag = 0;
end
if nargin<3
  version = 'latest';
end

for k = 1:numel(datainfo)
  datanew = timelockanalysis10trials(datainfo(k), writeflag, version);
  
  fname = fullfile(datainfo(k).origdir,version,'timelock',datainfo(k).type,['timelock_',datainfo(k).datatype]);
  tmp = load(fname);
  if isfield(tmp, 'data')
    data = tmp.data;
  elseif isfield(tmp, 'datanew')
    data = tmp.datanew;
  else isfield(tmp, 'timelock')
    data = tmp.timelock;
  end
  
  datanew = rmfield(datanew, 'cfg'); % these are per construction different if writeflag = 0;
  data    = rmfield(data,    'cfg');
  assert(isequalwithequalnans(data, datanew));
end

function [timelock] = timelockanalysis10trials(dataset, writeflag, version)

% --- HISTORICAL --- attempt forward compatibility with function handles
if ~exist('ft_timelockanalysis') && exist('timelockanalysis')
  eval('ft_timelockanalysis = @timelockanalysis;');
end

cfg = [];
cfg.inputfile  = fullfile(dataset.origdir,version,'raw',dataset.type,['preproc_',dataset.datatype]);
if writeflag
  cfg.outputfile = fullfile(dataset.origdir,version,'timelock',dataset.type,['timelock_',dataset.datatype]);
end

if ~strcmp(version, 'latest') && str2num(version)<20100000
  % -- HISTORICAL --- older fieldtrip versions don't support inputfile and outputfile
  load(cfg.inputfile, 'data');
  timelock = ft_timelockanalysis(cfg, data);
  save(cfg.outputfile, 'timelock');
else
  timelock = ft_timelockanalysis(cfg);
end

