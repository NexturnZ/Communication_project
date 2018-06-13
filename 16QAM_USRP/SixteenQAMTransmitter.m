classdef SixteenQAMTransmitter < matlab.System  
%#codegen
% Generates the QPSK signal to be transmitted
    
%   Copyright 2012-2016 The MathWorks, Inc.
    
    properties (Nontunable)
        UpsamplingFactor = 4;
        MessageLength = 112;
        DataLength = 174;
        TransmitterFilterCoefficients = 1;
        ScramblerBase = 2;
        ScramblerPolynomial = [1 1 1 0 1];
        ScramblerInitialConditions = [0 0 0 0];
    end
    
     properties (Access=private)
        pBitGenerator
        p16QAMModulator 
        pTransmitterFilter
    end
    
    methods
        function obj = SixteenQAMTransmitter(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj)
            obj.pBitGenerator = SixteenQAMBitsGenerator(...
                'MessageLength', obj.MessageLength, ...
                'BernoulliLength', obj.DataLength-obj.MessageLength, ...
                'ScramblerBase', obj.ScramblerBase, ...
                'ScramblerPolynomial', obj.ScramblerPolynomial, ...
                'ScramblerInitialConditions', obj.ScramblerInitialConditions);
            
            
%             obj.p16QAMModulator  = comm.GeneralQAMModulator();
%             const = [-3-3i, -3-1i, -3+1i, -3+3i,...
%                      -1-3i, -1-1i, -1+1i, -1+3i,...
%                       1-3i,  1-1i,  1+1i,  1+3i,...
%                       3-3i,  3-1i,  3+1i,  3+3i];
%             const = const/sqrt(norm(const));
%             obj.p16QAMModulator.Constellation = const;

            
             obj.p16QAMModulator  = comm.RectangularQAMModulator(...
                 16, 'BitInput',true,...
                 'NormalizationMethod','Average power',...
                 'SymbolMapping', 'Custom', ...
                 'CustomSymbolMapping', [11 10 14 15 9 8 12 13 1 0 4 5 3 2 6 7]);


            obj.pTransmitterFilter = dsp.FIRInterpolator(obj.UpsamplingFactor, ...
                obj.TransmitterFilterCoefficients);
        end
        
        function transmittedSignal = stepImpl(obj)
           
            [transmittedData_bin, ~] = obj.pBitGenerator();                 % Generates the data to be transmitted           
            % trun bits into value between 0  and 15
%             transmittedData_temp = reshape(transmittedData_bin,4,50);
%             transmittedData_dec = sum(transmittedData_temp.'.*[8,4,2,1],2);
            
            modulatedData = obj.p16QAMModulator(transmittedData_bin);       % Modulates the bits into QPSK symbols     
            
%             transmittedSignal = modulatedData;
            transmittedSignal = obj.pTransmitterFilter(modulatedData);  % Square root Raised Cosine Transmit Filter
        end
        
        function resetImpl(obj)
            reset(obj.pBitGenerator);
            reset(obj.p16QAMModulator );
            reset(obj.pTransmitterFilter);
        end
        
        function releaseImpl(obj)
            release(obj.pBitGenerator);
            release(obj.p16QAMModulator );
            release(obj.pTransmitterFilter);
        end
        
        function N = getNumInputsImpl(~)
            N = 0;
        end
    end
end

