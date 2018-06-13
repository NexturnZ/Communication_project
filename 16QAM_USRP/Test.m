function BER = Test()
platform = 'N200/N210/USRP2';
prmQPSKReceiver = sdruQAMreceiver_init(platform);
prmQPSKReceiver.Platform = platform;
persistent hRx
if isempty(hRx)
    hRx = sdruQAMRx( ...
        'DesiredAmplitude',               1/sqrt(prmQPSKReceiver.Upsampling), ...
        'ModulationOrder',                prmQPSKReceiver.M, ...
        'DownsamplingFactor',             prmQPSKReceiver.Downsampling, ...
        'CoarseCompFrequencyResolution',	prmQPSKReceiver.CoarseCompFrequencyResolution, ...
        'PhaseRecoveryLoopBandwidth',     prmQPSKReceiver.PhaseRecoveryLoopBandwidth, ...
        'PhaseRecoveryDampingFactor',     prmQPSKReceiver.PhaseRecoveryDampingFactor, ...
        'TimingRecoveryLoopBandwidth',    prmQPSKReceiver.TimingRecoveryLoopBandwidth, ...
        'TimingRecoveryDampingFactor',    prmQPSKReceiver.PhaseRecoveryDampingFactor, ...
        'PostFilterOversampling',         prmQPSKReceiver.Upsampling/prmQPSKReceiver.Downsampling, ...
        'PhaseErrorDetectorGain',         prmQPSKReceiver.PhaseErrorDetectorGain, ...
        'PhaseRecoveryGain',              prmQPSKReceiver.PhaseRecoveryGain, ...
        'TimingErrorDetectorGain',        prmQPSKReceiver.TimingErrorDetectorGain, ...
        'TimingRecoveryGain',             prmQPSKReceiver.TimingRecoveryGain, ...
        'FrameSize',                      prmQPSKReceiver.FrameSize, ...
        'BarkerLength',                   prmQPSKReceiver.BarkerLength, ...
        'MessageLength',                  prmQPSKReceiver.MessageLength, ...
        'SampleRate',                     prmQPSKReceiver.Fs, ...
        'DataLength',                     prmQPSKReceiver.DataLength, ...
        'ReceiverFilterCoefficients',     prmQPSKReceiver.ReceiverFilterCoefficients, ...
        'DescramblerBase',                prmQPSKReceiver.ScramblerBase, ...
        'DescramblerPolynomial',          prmQPSKReceiver.ScramblerPolynomial, ...
        'DescramblerInitialConditions',   prmQPSKReceiver.ScramblerInitialConditions,...
        'PrintOption',                    true);
end
% load('IQSignal.mat');
% load('Signal.mat');
load('signal200.mat');
% a1 = load('signal1.mat');
% a2 = load('signal2.mat');
% a3 = load('signal3.mat');
% a4 = load('signal4.mat');
% Output = [a1.transmittedSignal,a2.transmittedSignal,a3.transmittedSignal,a4.transmittedSignal];
for i1 = 1:100
    signal = S(:,i1);
%     signal = Output(:,i1);
    BER= step(hRx, signal);
end
end
