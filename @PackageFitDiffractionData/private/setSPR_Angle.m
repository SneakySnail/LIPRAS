function setSPR_Angle(Stro,Angle)
	
	angles = fliplr([0:360/Stro.numAzim:90]);
	
	if nargin==2
		if isempty( angles(find(angles==Angle)) )
			Stro.setSPR_Angle()
		else
			Stro.SPR_Angle = angles(find(angles==Angle));
			if size(Stro.SPR_Data(:,:,find(angles==Angle)),2)==1
				Stro.data_fit = Stro.SPR_Data(:,:,find(angles==Angle))';
			else
				Stro.data_fit = Stro.SPR_Data(:,:,find(angles==Angle));
			end
		end
	else
		AngleString = {'Select SPR Angle to Fit  ('};
		AngleString = strcat(AngleString,{num2str(angles(1))},{' (Perpendicular), '});
		for i=2:length(angles)-1
			AngleString = strcat(AngleString,{num2str(angles(i))},{', '});
		end
		AngleString = strcat(AngleString,{'and '},{num2str(angles(i+1))},{'(Parallel))'});
		
		prompt = {strcat(AngleString,{':'})};
		dlg_title = 'Select Angle to Fit';
		num_lines = 1;
		def = {'0'};
		Angle = newid(prompt{1,1},dlg_title,num_lines,def);
		Angle = str2double(Angle{1});
		if ~isempty(angles(find(angles==Angle)))
			Stro.setSPR_Angle(angles(find(angles==Angle)))
		else
			Stro.setSPR_Angle
		end
	end
end