function out = organize_ecu_signals(csvPath)
% Model-side signal metadata grouping only; no DBC or CAN frame decoding.
if nargin<1 || isempty(csvPath)
    root=fileparts(fileparts(mfilename('fullpath')));
    csvPath=fullfile(root,'data','ecu_signal_catalog.csv');
end
T=readtable(csvPath,'TextType','string');
required=["ECU","SignalName","DataType","Direction","Unit","Description"];
missing=setdiff(required,string(T.Properties.VariableNames));
if ~isempty(missing), error('Issue13:MissingColumns','Missing: %s',strjoin(missing,', ')); end
if any(ismissing(T.ECU)) || any(ismissing(T.SignalName)) || ...
        numel(unique(T.SignalName))~=height(T)
    error('Issue13:InvalidSignalIdentity','ECU and signal names must be present and unique.');
end
allowed=["boolean","uint8","int16","single","double"];
if any(~ismember(T.DataType,allowed)), error('Issue13:InvalidDataType','Unsupported teaching type.'); end
names=unique(T.ECU,'stable'); counts=zeros(numel(names),1);
for k=1:numel(names), counts(k)=sum(T.ECU==names(k)); end
out.Signals=T;
out.Summary=table(names,counts,'VariableNames',{'ECU','SignalCount'});
end
