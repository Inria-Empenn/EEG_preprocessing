cfg = [];
cfg.dataset = '/home/StageEEGpre/data/NDARAA075AMK/EEG/raw/mff_format/NDARAA075AMK';
% file=load('/home/StageEEGpre/data/NDARAA075AMK/EEG/raw/mat_format/RestingState.mat');
% file=file.EEG.data;
% 
% cfg.dataset = file;

cfg.reref       = 'yes';
cfg.refmethod='avg' ;
cfg.refchannel = 'all';
cfg.channel     = 'all';
cfg.bpfilter      = 'yes' ;
cfg.bpfreq        =[1 45];
cfg.continous='yes';


cfg.artfctdef.eog.bpfilter   = 'yes'
    cfg.artfctdef.eog.bpfilttype = 'but'
    cfg.artfctdef.eog.bpfreq     = [1 15]
    cfg.artfctdef.eog.bpfiltord  = 4
    cfg.artfctdef.eog.hilbert    = 'yes' 
      cfg.artfctdef.eog.channel='all';
data_eeg    = ft_preprocessing(cfg)
cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
% artifact_eog=ft_artifact_eog(data_eeg);
cfg.channel     = 'all';
data_eeg.channel     = 'all';

%  [cfg, artifact] = ft_artifact_zvalue(cfg, data_eeg)
[cfg, artifact] = ft_artifact_eog(cfg,data_eeg);
cfg.artfctdef.reject = 'complete'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
cfg.artfctdef.eog.artifact = artifact;
data_no_artifacts = ft_rejectartifact(cfg,data_eeg);
% comp = ft_componentanalysis(cfg, data_eeg);
