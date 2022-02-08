function do_preproces_MM(Subjectm)

cfg = [];
if nargin == 0
  disp('Not enough input arguments');
  return;
end
eval(Subjectm);
outputdir = 'AnalysisM';

%%% define trials
cfg.dataset             = [subjectdata.subjectdir filesep subjectdata.datadir];
cfg.trialdef.eventtype  = 'frontpanel trigger';
cfg.trialdef.prestim  = 1.5;
cfg.trialdef.poststim  = 1.5;
%cfg.continuous    = 'no';
cfg.lpfilter    = 'no';
cfg.continuous    = 'yes';
cfg.trialfun    = 'motormirror_trialfun';   % located in \Scripts
cfg.channel='EEG'; 
%cfg.channel    = 'MEG';
cfg.layout    = 'EEG1020.lay';
cfg       = ft_definetrial(cfg);

%%% if there are visual artifacts already in subject m-file use those. They will show up in databrowser
try
  cfg.artfctdef.eog.artifact = subjectdata.visualartifacts;
catch
end

%%% visual detection of jumps etc
cfg.continuous   = 'yes';
cfg.blocksize   = 20;
cfg.eventfile   = [];
cfg.viewmode   = 'butterfly';
cfg     = ft_databrowser(cfg);

%%% enter visually detected artifacts in subject m-file;
fid = fopen([subjectdata.mfiledir filesep Subjectm '.m'],'At');
fprintf(fid,'\n%s\n',['%%% Entered @ ' datestr(now)]);
fprintf(fid,'%s',['subjectdata.visualartifacts = [ ' ]);
if isempty(cfg.artfctdef.visual.artifact) == 0
  for i = 1 : size(cfg.artfctdef.visual.artifact,1)
    fprintf(fid,'%u%s%u%s',cfg.artfctdef.visual.artifact(i,1),' ',cfg.artfctdef.visual.artifact(i,2),';');
  end
end

fprintf(fid,'%s\n',[ ' ]; ']);
fclose all;

%%% reject artifacts
cfg.artfctdef.reject = 'complete';
cfg = ft_rejectartifact(cfg);

%%% make directory, if needed, to save all analysis data
if exist(outputdir) == 0
  mkdir(outputdir)
end

%%% Preprocess and SAVE
dataM = ft_preprocessing(cfg);
save([outputdir filesep subjectdata.subjectnr '_preproc_dataM'],'dataM','-V7.3')
clear all;
