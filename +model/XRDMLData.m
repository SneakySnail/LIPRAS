classdef XRDMLData < model.DiffractionData
    properties
        Temperature
        KAlpha1
        KAlpha2
        KBeta
        RKa1Ka2
    end
    
    methods
        function this = XRDMLData(data, filename, fileIndex)
        this@model.DiffractionData(data, filename, fileIndex);
        this.Temperature = data.Temperature(fileIndex);
        this.KAlpha1 = data.KAlpha1(fileIndex);
        this.KAlpha2 = data.KAlpha2(fileIndex);
        this.KBeta = data.KBeta(fileIndex);
        this.RKa1Ka2 = data.RKa1Ka2(fileIndex);
        end
        
    end
end