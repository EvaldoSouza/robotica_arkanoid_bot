function input = buttom(varargin)
    % Maps string inputs to the NES controller array:
    % [start, select, up, down, left, right, a, b]
    input = zeros(1, 8);
    
    if isempty(varargin)
        return;
    end
    
    valid_buttons = {"START", "SELECT", "UP", "DOWN", "LEFT", "RIGHT", "A", "B"};
    
    for i = 1:length(varargin)
        % Find the index where the input matches the valid_buttons array
        % strcmpi automatically handles upper/lower case differences
        idx = find(strcmpi(valid_buttons, varargin{i})); 
        
        if ~isempty(idx)
            input(idx) = 1;
        end
    end
end
