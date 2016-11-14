function profiledata = profiledata(num, handles)
	objs = findobj(handles.uipanel3);
	v_ind = isprop(objs, 'value');
	value = get(objs(v_ind), 'value');
	
	d_ind = isprop(objs, 'data');
	data = get(objs(d_ind), 'value');
	
	profiles.Value(num) = value;
	profiles.Visible(num) = get(objs(v_ind), 'visible');
	
	
	
	
	
	profiles.objs = objs;
	profiles.v_ind = v_ind;
	profiles.d_ind = d_ind;
	profiles.data = get(objs(d_ind), 'data');