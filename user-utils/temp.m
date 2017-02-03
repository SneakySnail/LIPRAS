% Shortcut summary goes here
num = 4;
menuitem = jmenu.getComponent(num);
disp(menuitem.getName)
for i=0:menuitem.getMenuComponentCount-1
    if ~isempty(menuitem.getMenuComponent(i).getName)
        disp([num2str(i) ': ' menuitem.getMenuComponent(i).getName.toCharArray'])
    else
        disp([num2str(i) ': '])
    end
end