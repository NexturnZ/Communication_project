%% QPSK Transmitter with USRP(R) Hardware
clear all;clc



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
prmQPSKTransmitter = sdru4QAMtransmitter_init(platform)
prmQPSKTransmitter.Platform = platform;
prmQPSKTransmitter.Address = address;
compileIt  = false; % true if code is to be compiled for accelerated execution 
useCodegen = false; % true to run the latest generated mex file




if compileIt
    codegen('runSDRuQPSKTransmitter', '-args', {coder.Constant(prmQPSKTransmitter)}); %#ok<UNRCH>
end
if useCodegen
   clear runSDRuQPSKTransmitter_mex %#ok<UNRCH>
   runSDRuQPSKTransmitter_mex(prmQPSKTransmitter);
else
   runSDRu4QAMTransmitter(prmQPSKTransmitter);
end


%% Appendix
% This example uses the following script and helper functions:
%
% * <matlab:edit('runSDRuQPSKTransmitter.m') runSDRuQPSKTransmitter.m>
% * <matlab:edit('sdruqpsktransmitter_init.m') sdruqpsktransmitter_init.m>
% * <matlab:edit('QPSKTransmitter.m') QPSKTransmitter.m>
% * <matlab:edit('QPSKBitsGenerator.m') QPSKBitsGenerator.m>

%% Copyright Notice
% Universal Software Radio Peripheral(R) and USRP(R) are trademarks of
% National Instruments Corp.
