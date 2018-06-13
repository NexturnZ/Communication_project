%% QPSK Receiver with USRP(R) Hardware
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


% Receiver parameter structure
prmQPSKReceiver = sdru4qamreceiver_init(platform)
prmQPSKReceiver.Platform = platform;
prmQPSKReceiver.Address = address;
compileIt  = false; % true if code is to be compiled for accelerated execution
useCodegen = false; % true to run the latest generated code (mex file) instead of MATLAB code





%% Execution and Results
% Before running the script, first turn on the USRP(R) and connect it to the
% computer. To ensure data reception, first start the
% <matlab:edit('sdruQPSKTransmitter.m') QPSK Transmitter with USRP(R)
% Hardware> example.

if compileIt
    codegen('runSDRuQPSKReceiver', '-args', {coder.Constant(prmQPSKReceiver)});
end
if useCodegen
   clear runSDRuQPSKReceiver_mex %#ok<UNRCH>
   BER = runSDRuQPSKReceiver_mex(prmQPSKReceiver);
else
   BER = runSDRu4QAMReceiver(prmQPSKReceiver); 
end

fprintf('Error rate is = %f.\n',BER(1));
fprintf('Number of detected errors = %d.\n',BER(2));
fprintf('Total number of compared samples = %d.\n',BER(3));



%% Appendix
% This example uses the following script and helper functions:
%
% * <matlab:edit('runSDRuQPSKReceiver.m') runSDRuQPSKReceiver.m>
% * <matlab:edit('sdruqpskreceiver_init.m') sdruqpskreceiver_init.m>
% * <matlab:edit('sdruQPSKRx.m') sdruQPSKRx.m>
% * <matlab:edit('sdruQPSKDataDecoder.m') sdruQPSKDataDecoder.m>
% * <matlab:edit('QPSKCoarseFrequencyCompensator.m') QPSKCoarseFrequencyCompensator.m>
% * <matlab:edit('QPSKFineFrequencyCompensator.m') QPSKFineFrequencyCompensator.m>
% * <matlab:edit('QPSKTimingRecovery.m') QPSKTimingRecovery.m>

%% References
% 1. Rice, Michael. _Digital Communications - A Discrete-Time
% Approach_. 1st ed. New York, NY: Prentice Hall, 2008.

%% Copyright Notice
% Universal Software Radio Peripheral(R) and USRP(R) are trademarks of
% National Instruments Corp.
