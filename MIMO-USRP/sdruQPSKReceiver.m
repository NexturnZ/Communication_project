%% QPSK Receiver with USRP(R) Hardware
%% Discover Radio
% Discover radio(s) connected to your computer. This example uses the first
% USRP(R) radio found using the |findsdru| function. Check if the radio is
% available and record the radio type. If no available radios are found,
% the example uses a default configuration for the system.

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
% The <matlab:edit('sdruqpskreceiver_init.m') sdruqpskreceiver_init.m>
% script initializes the simulation parameters and generates the structure
% _prmQPSKReceiver_.

% Receiver parameter structure
prmQPSKReceiver = sdruqpskreceiver_init(platform);
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
   BER = runSDRuQPSKReceiver(prmQPSKReceiver); 
end

fprintf('Error rate is = %f.\n',BER(1));
fprintf('Number of detected errors = %d.\n',BER(2));
fprintf('Total number of compared samples = %d.\n',BER(3));




