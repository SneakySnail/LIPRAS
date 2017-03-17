function fig = figAlwaysOnTop(fig)
%FIGALWAYSONTOP sets a specified figure to always be on top.
%
%   FIGALWAYSONTOP() creates a new figure if fig handle is 
%   not specified.
%
%   FIGALWAYSONTOP(FIG) modifies the underlying java frame of 
%   the figure specified in FIG so that it is always on top. 
%

if nargin < 1
    fig = figure;
end

try
    addlistener(fig, 'Visible', 'PostSet', @localFigVisiblePropChangedCallback);
    setJFrameOnTop(fig);
catch ME
    errordlg(getReport(ME, 'extended', 'hyperlinks', 'on'));
end

function localFigVisiblePropChangedCallback(~,e)
%FIG_VISIBLEPROPCHANGED_CALLBACK executes when the 'Visible' property of 
%   the figure set to always be on top changes. 
fig = e.AffectedObject;
setJFrameOnTop(fig);
    
function setJFrameOnTop(fig)
% If FIG is visible, get the underlying java frame and set it
%   to always be on top.
if isequal(fig.Visible, 'on')
    % make sure the figure is visible before getting jFrame
    drawnow 
    jf = getJFrame(fig);
    jWindow = jf.fHG2Client.getContentPane.getTopLevelAncestor;
    jWindow.setAlwaysOnTop(true);
end

function jframe = getJFrame(fig)
% Returns the underlying jFrame of the figure specified by FIG.
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe = get(fig, 'JavaFrame');
warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');