function edited = PulseTrainSettings(pulseTrainDetector, varargin)
    handles.detector = pulseTrainDetector;
    handles.reporters = pulseTrainDetector.recording.reporters;
    
    if isempty(handles.reporters)
        msgbox('You must find or import pulses before you can detect pulse trains.', 'Pulse Train Detector', 'warn', 'modal');
        edited = false;
    else
        editable = (nargin == 1 || (strcmp(varargin{1}, 'Editable') && varargin{2}));
        
        handles.figure = dialog(...
            'Units', 'points', ...
            'Name', 'Pulse Train Settings', ...
            'Position', [100, 100, 410, 190], ...
            'Visible', 'off', ...
            'WindowKeyPressFcn', @(hObject, eventdata)editPulseTrainKeyPress(hObject, eventdata, guidata(hObject)), ...
            'Tag', 'figure');
        
        % Add a pop-up menu for picking which reporter to get the pulses from.
        uicontrol(...
            'Parent', handles.figure,...
            'Units', 'points', ...
            'FontSize', 12, ...
            'HorizontalAlignment', 'right', ...
            'Position', [10 142 180 18], ...
            'String',  'Use pulses from:', ...
            'Style', 'text');
        handles.baseReporterPopup = uicontrol(...
            'Parent', handles.figure, ...
            'Units', 'points', ...
            'Position', [200 142 200 22], ...
            'Callback', @(hObject,eventdata)baseReporterPopupChanged(hObject, eventdata, guidata(hObject)), ...
            'String', cellfun(@(x)x.name(), handles.reporters, 'UniformOutput', false), ...
            'Style', 'popupmenu', ...
            'Value', 1, ...
            'Tag', 'baseReporterPopup');
        
        % Add a pop-up menu for picking the name of pulse features.
        featureTypes = handles.reporters{1}.featureTypes();
        uicontrol(...
            'Parent', handles.figure,...
            'Units', 'points', ...
            'FontSize', 12, ...
            'HorizontalAlignment', 'right', ...
            'Position', [10 110 180 18], ...
            'String',  'Pulse feature type:', ...
            'Style', 'text');
        handles.pulseFeatureTypePopup = uicontrol(...
            'Parent', handles.figure, ...
            'Units', 'points', ...
            'Position', [200 110 200 22], ...
            'Callback', @(hObject,eventdata)pulseFeatureTypePopupChanged(hObject, eventdata, guidata(hObject)), ...
            'String', featureTypes, ...
            'Style', 'popupmenu', ...
            'Value', 1, ...
            'Tag', 'pulseFeatureTypePopup');
        
        % Add a field for setting the minimum number of pulses
        uicontrol(...
            'Parent', handles.figure,...
            'Units', 'points', ...
            'FontSize', 12, ...
            'HorizontalAlignment', 'right', ...
            'Position', [10 80 180 18], ...
            'String',  'Minimum number of pulses:', ...
            'Style', 'text');
        handles.minPulsesEdit = uicontrol(...
            'Parent', handles.figure, ...
            'Units', 'points', ...
            'FontSize', 12, ...
            'HorizontalAlignment', 'left', ...
            'Position', [200 80 200 26], ...
            'String',  num2str(handles.detector.minPulses),...
            'Style', 'edit', ...
            'Tag', 'minPulsesEdit');
        
        % Add a field for setting the maximum gap between pulses
        uicontrol(...
            'Parent', handles.figure,...
            'Units', 'points', ...
            'FontSize', 12, ...
            'HorizontalAlignment', 'right', ...
            'Position', [10 50 180 18], ...
            'String',  'Maximum inter-pulse interval:', ...
            'Style', 'text');
        handles.maxIPIEdit = uicontrol(...
            'Parent', handles.figure, ...
            'Units', 'points', ...
            'FontSize', 12, ...
            'HorizontalAlignment', 'left', ...
            'Position', [200 50 200 26], ...
            'String',  num2str(handles.detector.maxIPI),...
            'Style', 'edit', ...
            'Tag', 'maxIPIEdit');
        
        handles.cancelButton = uicontrol(...
            'Parent', handles.figure,...
            'Units', 'points', ...
            'Callback', @(hObject,eventdata)cancelEditSettings(hObject,eventdata,guidata(hObject)), ...
            'Position', [410 - 56 - 10 - 56 - 10 10 56 20], ...
            'String', 'Cancel', ...
            'Tag', 'cancelButton');
        
        handles.saveButton = uicontrol(...
            'Parent', handles.figure,...
            'Units', 'points', ...
            'Callback', @(hObject,eventdata)saveEditSettings(hObject,eventdata,guidata(hObject)), ...
            'Position', [410 - 10 - 56 10 56 20], ...
            'String', 'Save', ...
            'Tag', 'saveButton');
        
        if ~editable
            set(handles.baseReporterPopup, 'Enable', 'off');
            set(handles.pulseFeatureTypePopup, 'Enable', 'off');
            set(handles.minPulsesEdit, 'Enable', 'off');
            set(handles.maxIPIEdit, 'Enable', 'off');
        end
        
        movegui(handles.figure, 'center');
        set(handles.figure, 'Visible', 'on');
        
        guidata(handles.figure, handles);
        
        % Wait for the user to cancel or save.
        uiwait;
        
        if ishandle(handles.figure)
            handles = guidata(handles.figure);
            edited = handles.edited;
            close(handles.figure);
        else
            edited = false;
        end
    end
end


function baseReporterPopupChanged(~, ~, handles)
    i = get(handles.baseReporterPopup, 'Value');
    featureTypes = handles.reporters{i}.featureTypes();
    set(handles.pulseFeatureTypePopup, 'String', featureTypes, 'Value', 1);
end


function editPulseTrainKeyPress(hObject, eventdata, handles)
    if strcmp(eventdata.Key, 'return')
        saveEditSettings(hObject, eventdata, handles);
    elseif strcmp(eventdata.Key, 'escape')
        cancelEditSettings(hObject, eventdata, handles);
    end
end


function cancelEditSettings(~, ~, handles)
    handles.edited = false;
    guidata(handles.figure, handles);
    uiresume;
end


function saveEditSettings(~, ~, handles)
    i = get(handles.baseReporterPopup, 'Value');
    handles.detector.baseReporter = handles.reporters{i};
    featureTypes = get(handles.pulseFeatureTypePopup, 'String');
    i = get(handles.pulseFeatureTypePopup, 'Value');
    handles.detector.pulseFeatureType = featureTypes{i};
    handles.detector.minPulses = str2double(get(handles.minPulsesEdit, 'String'));
    handles.detector.maxIPI = str2double(get(handles.maxIPIEdit, 'String'));
    handles.edited = true;
    guidata(handles.figure, handles);
    uiresume;
end
