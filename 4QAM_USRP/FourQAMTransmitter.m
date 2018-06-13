classdef FourQAMTransmitter < matlab.System  
%#codegen
% Generates the QPSK signal to be transmitted
    
%   Copyright 2012-2016 The MathWorks, Inc.
    
    properties (Nontunable)
        UpsamplingFactor =4;%!!!!!!4
        MessageLength = 105;
        DataLength = 348;%%%   174    348
        TransmitterFilterCoefficients = 1;
        ScramblerBase = 2;
        ScramblerPolynomial = [1 1 1 0 1];
        ScramblerInitialConditions = [0 0 0 0];
    end
    
     properties (Access=private)
        pBitGenerator
        qamModulator 
        pTransmitterFilter
    end
    
    methods
        function obj = FourQAMTransmitter(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj)
            obj.pBitGenerator =FourQAMBitsGenerator(...
                'MessageLength', obj.MessageLength, ...
                'BernoulliLength', obj.DataLength-obj.MessageLength, ...
                'ScramblerBase', obj.ScramblerBase, ...
                'ScramblerPolynomial', obj.ScramblerPolynomial, ...
                'ScramblerInitialConditions', obj.ScramblerInitialConditions);
              obj.qamModulator  = comm.RectangularQAMModulator('ModulationOrder',4,'BitInput',true);  %%  
            obj.pTransmitterFilter = dsp.FIRInterpolator(obj.UpsamplingFactor, ...
                obj.TransmitterFilterCoefficients);
           
        end
        
        function transmittedSignal = stepImpl(obj)
           
            [transmittedData, ~] = obj.pBitGenerator();
             modulatedData =step(obj.qamModulator,transmittedData); % Generates the data to be transmitted                  
            transmittedSignal = obj.pTransmitterFilter(modulatedData); % Square root Raised Cosine Transmit Filter
        end
        
        function resetImpl(obj)
            reset(obj.pBitGenerator);
            reset(obj.qamModulator );
            reset(obj.pTransmitterFilter);
        end
        
        function releaseImpl(obj)
            release(obj.pBitGenerator);
            release(obj.qamModulator );
            release(obj.pTransmitterFilter);
        end
        
        function N = getNumInputsImpl(~)
            N = 0;
        end
    end
end

