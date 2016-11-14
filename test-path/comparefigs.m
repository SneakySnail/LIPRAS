
function comparefigs(figfile1, figfile2)
fig1 = getFigObj(figfile1);


% get handles of fig1 and fig2
hfig1 = findobj(fig1);
hfig2 = findobj(fig2);

len1 = length(hfig1);
len2 = length(hfig2);


function fig = getFigObj(file)



