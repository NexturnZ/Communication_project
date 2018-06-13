clear all;
dbstop if error;
%% Discover Radio

connectedRadios = findsdru;
if strncmp(connectedRadios(1).Status, 'Success', 7)
  platform = connectedRadios(1).Platform;
  switch connectedRadios(1).Platform
    case {'B200','B210'}
      address = connectedRadios(1).SerialNum;
    case {'N200/N210/USRP2','X300','X310'}
      address = connectedRadios(1).IPAddress;
  end
else
  address = '192.168.10.2';
  platform = 'N200/N210/USRP2';
end

%% Initialization
% Transmitter parameter structure
prmQPSKTransmitter = sdruQAMtransmitter_init(platform);
prmQPSKTransmitter.Platform = platform;
prmQPSKTransmitter.Address = address;
compileIt  = false; 
useCodegen = false;

%% Execution

if compileIt
    codegen('runSDRuQPSKTransmitter', '-args', {coder.Constant(prmQPSKTransmitter)}); %#ok<UNRCH>
end
if useCodegen
   clear runSDRuQPSKTransmitter_mex %#ok<UNRCH>
   runSDRuQPSKTransmitter_mex(prmQPSKTransmitter);
else
   runSDRuQAMTransmitter(prmQPSKTransmitter);
end


