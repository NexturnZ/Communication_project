classdef sdru4QAMRx < matlab.System
%#codegen
    
%   Copyright 2012-2014 The MathWorks, Inc.    
    
    properties (Nontunable)
        DesiredAmplitude
        ModulationOrder
        DownsamplingFactor
        CoarseCompFrequencyResolution
        PhaseRecoveryLoopBandwidth
        PhaseRecoveryDampingFactor
        TimingRecoveryLoopBandwidth
        TimingRecoveryDampingFactor
        PostFilterOversampling
        PhaseErrorDetectorGain
        PhaseRecoveryGain
        TimingErrorDetectorGain
        TimingRecoveryGain
        FrameSize
        BarkerLength
        MessageLength
        SampleRate
        DataLength
        ReceiverFilterCoefficients
        DescramblerBase
        DescramblerPolynomial
        DescramblerInitialConditions
        PrintOption
    end
    
    properties (Access=private)
        pAGC
        pRxFilter
        pCoarseFreqCompensator
        pFineFreqCompensator
        pTimingRec
        pDataDecod
        pCoarseFreqEstimator
        pPrbDet
        pFrameSync
        pBER
        pOldOutput 
        % Stores the previous output of fine frequency compensation which is used by the same System object for phase error detection
    end
    
    properties (Access = private, Constant)    %%!!!!
        pUpdatePeriod = 4 % Defines the size of vector that will be processed in AGC system object
        pBarkerCode = [1; 1; 1; 1; 1; 0; 0; 1; 1;0; 1;0;1]'; 
        pBarkerCodes= repmat(sdruQPSKRx.pBarkerCode,2,1);
        pModulatedHeader=qammod(sdruQPSKRx.pBarkerCodes(:),4,'InputType','bit');     
    end
    
    methods
        function obj = sdru4QAMRx(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj, ~)
            obj.pAGC = comm.AGC;
            obj.pRxFilter = dsp.FIRDecimator(...
                obj.DownsamplingFactor,obj.ReceiverFilterCoefficients);
       
            
            obj.pCoarseFreqCompensator = FourQAMCoarseFrequencyCompensator(...
                'ModulationOrder', obj.ModulationOrder, ...
                'CoarseCompFrequencyResolution', obj.CoarseCompFrequencyResolution, ...
                'SampleRate', obj.SampleRate, ...
                'DownsamplingFactor', obj.DownsamplingFactor);
            
            % Refer C.57 to C.61 in Michael Rice's "Digital Communications 
            % - A Discrete-Time Approach" for K1 and K2
            theta = obj.PhaseRecoveryLoopBandwidth/...
                (obj.PhaseRecoveryDampingFactor + ...
                0.25/obj.PhaseRecoveryDampingFactor)/obj.PostFilterOversampling;
            d = 1 + 2*obj.PhaseRecoveryDampingFactor*theta + theta*theta;
            K1 = (4*obj.PhaseRecoveryDampingFactor*theta/d)/...
                (obj.PhaseErrorDetectorGain*obj.PhaseRecoveryGain);
            K2 = (4*theta*theta/d)/...
                (obj.PhaseErrorDetectorGain*obj.PhaseRecoveryGain);
            obj.pOldOutput = complex(0); % used to store past value
            
          
            
            obj.pFineFreqCompensator = FourQAMFineFrequencyCompensator( ...
                'ProportionalGain', K1, ...
                'IntegratorGain', K2, ...
                'DigitalSynthesizerGain', -1*obj.PhaseRecoveryGain);
            
            % Refer C.57 to C.61 in Michael Rice's "Digital Communications 
            % - A Discrete-Time Approach" for K1 and K2
            theta = obj.TimingRecoveryLoopBandwidth/...
                (obj.TimingRecoveryDampingFactor + ...
                0.25/obj.TimingRecoveryDampingFactor)/obj.PostFilterOversampling;
            d = 1 + 2*obj.TimingRecoveryDampingFactor*theta + theta*theta;
            K1 = (4*obj.TimingRecoveryDampingFactor*theta/d)/...
                (obj.TimingErrorDetectorGain*obj.TimingRecoveryGain);
            K2 = (4*theta*theta/d)/...
                (obj.TimingErrorDetectorGain*obj.TimingRecoveryGain);
            
            
            
            obj.pTimingRec = FourQAMTimingRecovery('ProportionalGain', K1,...
                'IntegratorGain', K2, ...
                'PostFilterOversampling', obj.PostFilterOversampling, ...
                'BufferSize', obj.FrameSize);
            
            obj.pDataDecod = sdru4QAMDataDecoder('FrameSize', obj.FrameSize, ...
                'BarkerLength', obj.BarkerLength, ...
                'ModulationOrder', obj.ModulationOrder, ...
                'DataLength', obj.DataLength, ...
                'MessageLength', obj.MessageLength, ...
                'DescramblerBase', obj.DescramblerBase, ...
                'DescramblerPolynomial', obj.DescramblerPolynomial, ...
                'DescramblerInitialConditions', obj.DescramblerInitialConditions, ...
                'PrintOption', obj.PrintOption);
       
        end
        
        
        function BER =  stepImpl(obj, bufferSignal)
            
            % Apply automatic gain control to the signal
            AGCSignal = obj.DesiredAmplitude*step(obj.pAGC, bufferSignal);
            
            % Pass the signal through square root raised cosine received
            % filter
            RCRxSignal = step(obj.pRxFilter,AGCSignal);
            
            % Coarsely compensate for the frequency offset
            coarseCompSignal = step(obj.pCoarseFreqCompensator, RCRxSignal);
            
            % Buffers to store values required for plotting
            coarseCompBuffer = ...
                coder.nullcopy(complex(zeros(size(coarseCompSignal))));
            timingRecBuffer = coder.nullcopy(zeros(size(coarseCompSignal)));
%           Scalar processing for fine frequency compensation and timing
%           recovery 
            BER = zeros(3,1);   %!!!!
     
            
            
            for i=1:length(coarseCompSignal)
                
                % Fine frequency compensation
                fineCompSignal = obj.pFineFreqCompensator( [obj.pOldOutput; coarseCompSignal(i)]);   % !!!!!!
                coarseCompBuffer(i) = fineCompSignal;
                obj.pOldOutput = fineCompSignal;
                
                % Timing recovery of the received data
                [dataOut, isDataValid, timingRecBuffer(i)] = ...
                    step(obj.pTimingRec, fineCompSignal);
                
                if isDataValid
                    % Decoding the received data
                    BER = step(obj.pDataDecod, dataOut);
                end
            end
            
        end

    end
end
