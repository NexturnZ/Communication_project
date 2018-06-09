%% QPSK Transmitter with USRP(R) Hardware
clear all;clc
%% Discover Radio
% Discover radio(s) connected to your computer. This example uses the first
% USRP(R) radio found using the |findsdru| function. Check if the radio is
% available and record the radio type. If no available radios are found,
% the example uses a default configuration for the system.

connectedRadios = findsdru;
if strncmp(connectedRadios(1).Status, 'Success', 7) && strncmp(connectedRadios(2).Status,'Success',7)
  platform = connectedRadios(1).Platform;
  switch connectedRadios(1).Platform
    case {'B200','B210'}
      address1 = connectedRadios(1).SerialNum;
    case {'N200/N210/USRP2','X300','X310'}
      address1 = connectedRadios(1).IPAddress;
      address2 = connectedRadios(2).IPAddress;
  end
else
  address1 = '192.168.10.2';
  address2 = '192.168.10.4';
  platform = 'N200/N210/USRP2';
end

%% Initialization
% The <matlab:edit('sdruqpsktransmitter_init.m')
% sdruqpsktransmitter_init.m> script initializes the simulation parameters
% and generates the structure prmQPSKTransmitter.

% Transmitter parameter structure
prmQPSKTransmitter = sdruqpsktransmitter_init(platform)
prmQPSKTransmitter.Platform = platform;
prmQPSKTransmitter.Address = [address1 ,',' ,address2];
compileIt  = false; % true if code is to be compiled for accelerated execution 
useCodegen = false; % true to run the latest generated mex file

%% Execution
% Before running the script, first turn on the USRP(R) radio and connect it
% to the computer. As already mentioned, you can check the correct data
% transmission by running the
% <matlab:edit('sdruQPSKReceiver.m') QPSK Receiver with USRP(R) Hardware> 
% example while running the transmitter script.

if compileIt
    codegen('runSDRuQPSKTransmitter', '-args', {coder.Constant(prmQPSKTransmitter)}); %#ok<UNRCH>
end
if useCodegen
   clear runSDRuQPSKTransmitter_mex %#ok<UNRCH>
   runSDRuQPSKTransmitter_mex(prmQPSKTransmitter);
else
   runSDRuQPSKTransmitter(prmQPSKTransmitter);
end

