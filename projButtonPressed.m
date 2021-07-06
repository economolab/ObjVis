function projButtonPressed(~, ~, fig)

h = guidata(fig);

switch h.projMenu.Value
    case 1
        codingVector(fig);
    case 2
        allActivityModes(fig);
end


end % alignData