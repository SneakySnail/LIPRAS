%******************************************************************%
%  Save properties of profile
%******************************************************************%
objs = findobj(h.uipanel3);
v_ind = isprop(objs, 'value');
value = get(objs(v_ind), 'value');

%******************************************************************%
% Set values of properties
%******************************************************************%
 [objs(v_ind).Value] = deal(value{:});





d_ind = isprop(objs, 'data');

profiledata.objs = objs;
