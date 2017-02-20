classdef CuKAlpha2Function
   properties
       Function
       KAlpha1
       KAlpha2
   end
   
   methods
       function this = CuKAlpha1Function(funcObj, Ka1, Ka2)
       this.Function = funcObj;
       this.KAlpha1 = Ka1;
       this.KAlpha2 = Ka2;
       end
   end
end