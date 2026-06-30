function next_input = translate_action_to_input(action_idx, frame_counter)
    % Translates the RL action index to emulator button inputs.
    % Maps agent logic (1, 2, 3) to physical emulator I/O.
    %
    % Usage:
    %   input_struct = translate_action_to_input(2, 150);

    % STREAMING_CHUNK: Handling menu sequence bypass...
    if action_idx == 0 || isempty(action_idx)
        if mod(frame_counter, 60) < 5
            next_input = button("START");
        else
            next_input = button();
        end
        return;
    end

    % STREAMING_CHUNK: Mapping policy to emulator struct...
    if action_idx == 1
        next_input = button("LEFT", "A");
    elseif action_idx == 2
        next_input = button("RIGHT", "A");
    else
        next_input = button("A"); % IDLE
    end
end
