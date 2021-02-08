%% Remove the default boxing of the figures and the legend.
function format_figure(gca, leg)
set(gca, 'Box', 'Off');

if exist('leg','var')
    set(leg, 'box', 'off');
end


end