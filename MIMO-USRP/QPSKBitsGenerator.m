classdef QPSKBitsGenerator < matlab.System
%#codegen
% Generates the bits for each frame

%   Copyright 2012-2016 The MathWorks, Inc.

    properties (Nontunable)
        MessageLength = 105;
        BernoulliLength = 243;  %%!!!!!69    243   
        ScramblerBase = 2;
        ScramblerPolynomial = [1 1 1 0 1];
        ScramblerInitialConditions = [0 0 0 0];
    end
    
    properties (Access=private)
        pHeader
        pScrambler
        pMsgStrSet
        pCount
    end
    
    methods
        function obj = QPSKBitsGenerator(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj, ~)
            bbc = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 ]; % Bipolar Barker Code
            ubc = ((bbc + 1) / 2)'; % Unipolar Barker Code
            temp = (repmat(ubc,1,2))';   %  ������2
            obj.pHeader = temp(:);
            obj.pCount = 0;
            obj.pScrambler = comm.Scrambler(obj.ScramblerBase, ...
                obj.ScramblerPolynomial, obj.ScramblerInitialConditions);
            obj.pMsgStrSet = ['Hello world 000';...
              'Hello world 001';...
              'Hello world 002';...
              'Hello world 003';...
              'Hello world 004';...
              'Hello world 005';...
              'Hello world 006';...
              'Hello world 007';...
              'Hello world 008';...
              'Hello world 009';...
              'Hello world 010';...
              'Hello world 011';...
              'Hello world 012';...
              'Hello world 013';...
              'Hello world 014';...
              'Hello world 015';...
              'Hello world 016';...
              'Hello world 017';...
              'Hello world 018';...
              'Hello world 019';...
              'Hello world 020';...
              'Hello world 021';...
              'Hello world 022';...
              'Hello world 023';...
              'Hello world 024';...
              'Hello world 025';...
              'Hello world 026';...
              'Hello world 027';...
              'Hello world 028';...
              'Hello world 029';...
              'Hello world 030';...
              'Hello world 031';...
              'Hello world 032';...
              'Hello world 033';...
              'Hello world 034';...
              'Hello world 035';...
              'Hello world 036';...
              'Hello world 037';...
              'Hello world 038';...
              'Hello world 039';...
              'Hello world 040';...
              'Hello world 041';...
              'Hello world 042';...
              'Hello world 043';...
              'Hello world 044';...
              'Hello world 045';...
              'Hello world 046';...
              'Hello world 047';...
              'Hello world 048';...
              'Hello world 049';...
              'Hello world 050';...
              'Hello world 051';...
              'Hello world 052';...
              'Hello world 053';...
              'Hello world 054';...
              'Hello world 055';...
              'Hello world 056';...
              'Hello world 057';...
              'Hello world 058';...
              'Hello world 059';...
              'Hello world 060';...
              'Hello world 061';...
              'Hello world 062';...
              'Hello world 063';...
              'Hello world 064';...
              'Hello world 065';...
              'Hello world 066';...
              'Hello world 067';...
              'Hello world 068';...
              'Hello world 069';...
              'Hello world 070';...
              'Hello world 071';...
              'Hello world 072';...
              'Hello world 073';...
              'Hello world 074';...
              'Hello world 075';...
              'Hello world 076';...
              'Hello world 077';...
              'Hello world 078';...
              'Hello world 079';...
              'Hello world 080';...
              'Hello world 081';...
              'Hello world 082';...
              'Hello world 083';...
              'Hello world 084';...
              'Hello world 085';...
              'Hello world 086';...
              'Hello world 087';...
              'Hello world 088';...
              'Hello world 089';...
              'Hello world 090';...
              'Hello world 091';...
              'Hello world 092';...
              'Hello world 093';...
              'Hello world 094';...
              'Hello world 095';...
              'Hello world 096';...
              'Hello world 097';...
              'Hello world 098';...
              'Hello world 099']; 
        end
        
        function [y,msg] = stepImpl(obj)
            
            % Converts the message string to bit format
            cycle = mod(obj.pCount,100);
            msgStr = obj.pMsgStrSet(cycle+1,:);
            msgBin = de2bi(int8(msgStr),7,'left-msb');
            msg = reshape(double(msgBin).',obj.MessageLength,1);
            data = [msg ; randi([0 1], obj.BernoulliLength, 1)];
            
            % Scramble the data
            scrambledData = obj.pScrambler(data);
            
            % Append the scrambled bit sequence to the header
            y = [obj.pHeader ; scrambledData];
            
            obj.pCount = obj.pCount+1;
        end
        
        function resetImpl(obj)
            obj.pCount = 0;
            reset(obj.pScrambler);
        end
        
        function releaseImpl(obj)
            release(obj.pScrambler);
        end
        
        function N = getNumInputsImpl(~)
            N = 0; 
        end
        
        function N = getNumOutputsImpl(~)
            N = 2;
        end
    end
end
