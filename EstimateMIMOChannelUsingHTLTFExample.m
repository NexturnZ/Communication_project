%% Estimate MIMO Channel Using HT-LTF
% Estimate the channel coefficients of a 2x2 MIMO channel by using the high
% throughput long training field. Recover the HT-data field and determine
% the number of bit errors.

%%
% Create an HT-mixed format configuration object for a channel having two
% spatial streams and four transmit antennas. Transmit a complete HT
% waveform.
cfg = wlanHTConfig('NumTransmitAntennas',2, ...
    'NumSpaceTimeStreams',2,'MCS',11);
txPSDU = randi([0 1],8*cfg.PSDULength,1);
txWaveform = wlanWaveformGenerator(txPSDU,cfg);

%%
% Pass the transmitted waveform through a 2x2 TGn channel.
tgnChan = wlanTGnChannel('SampleRate',20e6, ...
    'NumTransmitAntennas',2, ...
    'NumReceiveAntennas',2, ...
    'LargeScaleFadingEffect','Pathloss and shadowing');
rxWaveformNoNoise = tgnChan(txWaveform);
%%
% Create an AWGN channel with noise power, |nVar|, corresponding to a
% receiver having a 9 dB noise figure. The noise power is equal to _kTBF_,
% where _k_ is Boltzmann's constant, _T_ is the ambient noise temperature
% (290K), _B_ is the bandwidth (20 MHz), and _F_ is the noise figure (9
% dB).
nVar = 10^((-228.6 + 10*log10(290) + 10*log10(20e6) + 9)/10);
awgnChan = comm.AWGNChannel('NoiseMethod','Variance', ...
    'Variance',nVar);
%%
% Pass the signal through the AWGN channel.
rxWaveform = awgnChan(rxWaveformNoNoise);
%%
% Determine the indices for the HT-LTF. Extract the HT-LTF from the
% received waveform. Demodulate the HT-LTF.
indLTF  = wlanFieldIndices(cfg,'HT-LTF');
rxLTF = rxWaveform(indLTF(1):indLTF(2),:);
ltfDemodSig = wlanHTLTFDemodulate(rxLTF,cfg);

%%
% Generate the channel estimate by using the demodulated HT-LTF signal.
% Specify a smoothing filter span of three subcarriers.
chEst = wlanHTLTFChannelEstimate(ltfDemodSig,cfg,3);
%%
% Extract the HT-data field from the received waveform.
indData = wlanFieldIndices(cfg,'HT-Data');
rxDataField = rxWaveform(indData(1):indData(2),:);
%%
% Recover the data and verify that there no bit errors occurred.
rxPSDU = wlanHTDataRecover(rxDataField,chEst,nVar,cfg);

numErrs = biterr(txPSDU,rxPSDU)