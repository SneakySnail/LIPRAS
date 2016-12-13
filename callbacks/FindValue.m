        function arrayposition=FindValue(data,value2theta)
            % function arrayposition=Find2theta(data,value2theta)
            % Finds the nearest position in a vector
            % MUST be a single array of 2theta values only (most common error)
            
            if nargin~=2
                error('Incorrect number of arguments')
                arrayposition=0;
            else
                % conditional to increase the accuracy of the selected cell                
                test = find(data >= value2theta);
                test2 = find(data <= value2theta);
                % test or test2 can be empty if the value sits at the edge
                % of a data set
                    if isempty(test);
                        test=test2;
                    elseif isempty(test2);
                        test2=test;
                    end
                a=abs(data(test(1))-value2theta);
                b=abs(value2theta-data(test2(end)));

                            if a<=b
                                test(1)=test(1);                                
                            else
                                test(1)=test2(end);
                            end
                
                if isempty(test);
                    arrayposition = length(data)-1;
                else
                    arrayposition = test(1);                    
                end
            end
		end