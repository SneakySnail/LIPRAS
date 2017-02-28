classdef XRDMLData < model.DiffractionData
%XRDMLDATA extends model.DiffractionData to include XRDML data.
    properties
        ScanID
        KAlpha1
        KAlpha2
        kBeta
        RKa1Ka2
        Temperature
    end
    
    methods
        function this = XRDMLData(data, filename, scanIndex)
        this@model.DiffractionData(data,filename,scanIndex);
        this.KAlpha1 = data.KAlpha1;
        this.KAlpha2 = data.KAlpha2;
        this.kBeta = data.kBeta;
        this.RKa1Ka2 = data.RKa1Ka2;
%         this.Temperature = data.Temperature(scanIndex);
%         this.ScanID = scanIndex;
        end
    end
    
    methods (Static)
        function answer = isXRDML()
        answer = true;
        end
    end
    
end