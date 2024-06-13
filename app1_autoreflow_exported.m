classdef app1_autoreflow_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        LeftPanel                  matlab.ui.container.Panel
        DeviceConnect              matlab.ui.control.StateButton
        DeviceDisconnect           matlab.ui.control.StateButton
        channelChoice              matlab.ui.control.DropDown
        widthChoice                matlab.ui.control.DropDown
        paraConfirm                matlab.ui.control.Button
        paraDis                    matlab.ui.control.Label
        paraConfirm_2              matlab.ui.control.Button
        HzEditField_2              matlab.ui.control.EditField
        FSEditFieldLabel_2         matlab.ui.control.Label
        paraDis_2                  matlab.ui.control.Label
        ResolutionSpinnerLabel     matlab.ui.control.Label
        ResolutionSpinner          matlab.ui.control.Spinner
        paraDis_4                  matlab.ui.control.Label
        FreqRangeHzEditFieldLabel  matlab.ui.control.Label
        FreqRangeHzEditField       matlab.ui.control.EditField
        Lamp                       matlab.ui.control.Lamp
        Lamp_condition             matlab.ui.control.Label
        sig_receive_para           matlab.ui.control.DropDown
        sig_eject_para             matlab.ui.control.DropDown
        sig_eject_edit             matlab.ui.control.EditField
        sig_receive_edit           matlab.ui.control.EditField
        paraConfirm_4              matlab.ui.control.Button
        cd_edit                    matlab.ui.control.EditField
        sig_name_edit              matlab.ui.control.DropDown
        working_Lamp               matlab.ui.control.Lamp
        working_Lamp_condition     matlab.ui.control.Label
        TerminateButton            matlab.ui.control.Button
        sig_condition              matlab.ui.control.Label
        sig_condition_time_2       matlab.ui.control.Label
        sig_condition_time         matlab.ui.control.Label
        RightPanel                 matlab.ui.container.Panel
        recieve_ch1                matlab.ui.control.UIAxes
        recieve_ch1_2              matlab.ui.control.UIAxes
        recieve_ch1_3              matlab.ui.control.UIAxes
        recieve_ch1_4              matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        Property               % Description
        Obj                    % Device
        
        paraConfirm_choice     % device Para
        paraConfirm_choice_2   % eject Para
        
        chA_width              % ChannelA dynamic
        chB_width              % ChannelB dynamic
        chC_width              % ChannelC dynamic
        chD_width              % ChannelD dynamic
        channelResolution      % 
        prefs                  % preset frequency
        freq                   % eject frequency
        waveNum                % wave number
        Ulti_channel_choice    % channel Choice
        f_start                % eject starting frequency
        f_end                  % eject ending frequency
        cd                     % saving path
        sigNum                 % capture sig number toto
        pauseTime              % capturing sig Interval time
        Ulti_eject_choice      % eject sig choice
        
        Ulti_receive_choice    % recieve sig choice
        sigSampleNum           % capturing sig sampling number
        numCaptures            % sig number for one capture
        chA                    % 
        chB                    % 
        chC                    % 
        chD                    % 
        
        sig_name_choice        % saving Para
        fileName               % saving name Choice
        breakDown              % 
        figureNameChannelA     %
        figureNameChannelB     %
        figureNameChannelC     %
        figureNameChannelD     %
    end
    
    methods (Access = private)
        
        %% AWG ÿ1ÿ (sin form)
        function sig_cw(app,Obj,timebaseIndex,f,N)
            PS5000aConfig;
            sigGenGroupObj = get(Obj, 'Signalgenerator');
            sigGenGroupObj = sigGenGroupObj(1);
            Tinterval = (timebaseIndex-2)/125000000;
            % sig frequency fÿwave number for one capture N
            if ~exist('f','var');f = 25e5;end
            if ~exist('N','var');N = 3;end
            fsstart = 1/(N/f-Tinterval);
            set(sigGenGroupObj, 'startFrequency', fsstart);
            set(sigGenGroupObj, 'stopFrequency', fsstart*2);
            set(sigGenGroupObj, 'offsetVoltage', 0.0);
            set(sigGenGroupObj, 'peakToPeakVoltage', 4000.0);
            % -----
            increment 			= 0; % Hz
            dwellTime 			= 0; % seconds
            sweepType 			= ps5000aEnuminfo.enPS5000ASweepType.PS5000A_UP;
            operation 			= ps5000aEnuminfo.enPS5000AExtraOperations.PS5000A_ES_OFF;
            indexMode 			= ps5000aEnuminfo.enPS5000AIndexMode.PS5000A_SINGLE;
            shots 				= 1;
            sweeps 				= 0;
            triggerType 		= ps5000aEnuminfo.enPS5000ASigGenTrigType.PS5000A_SIGGEN_RISING;
            triggerSource 		= ps5000aEnuminfo.enPS5000ASigGenTrigSource.PS5000A_SIGGEN_SCOPE_TRIG;
            extInThresholdMv 	= 0;
            % ----
            SigFs = 1/Tinterval;
            to = 1/fsstart;
            n = 0:1/SigFs:to;
            x  =sin(2*pi*f*n(1:floor(length(n)/2)));
            x = (x'.*hanning(length(x)))';
            y = [zeros(1,1),x,zeros(1,1)];
            [status.setSigGenArbitrary] = invoke(sigGenGroupObj, 'setSigGenArbitrary', ...
                increment, dwellTime, y , sweepType, ...
                operation, indexMode, shots, sweeps,...
                triggerType, triggerSource, extInThresholdMv);
        end
        % ÿ2ÿAWG:chirp
        function sig_chirp(app,Obj,timebaseIndex,f,N,f_start,f_end)
            PS5000aConfig;
            sigGenGroupObj = get(Obj, 'Signalgenerator');
            sigGenGroupObj = sigGenGroupObj(1);
            Tinterval = (timebaseIndex-2)/125000000;
            % sig frequency fÿwave number for one capture N
            if ~exist('f','var');f = 25e5;end
            if ~exist('N','var');N = 3;end
            if ~exist('f_start','var');f_start = f/sqrt(2);end
            if ~exist('f_end','var');f_end = f*sqrt(2);end
            fsstart = 1/(N/f-Tinterval);
            set(sigGenGroupObj, 'startFrequency', fsstart);
            set(sigGenGroupObj, 'stopFrequency', fsstart*2);
            set(sigGenGroupObj, 'offsetVoltage', 0.0);
            set(sigGenGroupObj, 'peakToPeakVoltage', 4000.0);
            % -----
            increment 			= 0; % Hz
            dwellTime 			= 0; % seconds
            sweepType 			= ps5000aEnuminfo.enPS5000ASweepType.PS5000A_UP;
            operation 			= ps5000aEnuminfo.enPS5000AExtraOperations.PS5000A_ES_OFF;
            indexMode 			= ps5000aEnuminfo.enPS5000AIndexMode.PS5000A_SINGLE;
            shots 				= 1;
            sweeps 				= 0;
            triggerType 		= ps5000aEnuminfo.enPS5000ASigGenTrigType.PS5000A_SIGGEN_RISING;
            triggerSource 		= ps5000aEnuminfo.enPS5000ASigGenTrigSource.PS5000A_SIGGEN_SCOPE_TRIG;
            extInThresholdMv 	= 0;
            % ----
            SigFs = 1/Tinterval;
            to = 1/fsstart;
            n = 0:1/SigFs:to;
            x = chirp(n,f_start,to,f_end);
            x = (x'.*hanning(length(x)))';
            y = [zeros(1,1),x,zeros(1,1)];
            [status.setSigGenArbitrary] = invoke(sigGenGroupObj, 'setSigGenArbitrary', ...
                increment, dwellTime, y , sweepType, ...
                operation, indexMode, shots, sweeps,...
                triggerType, triggerSource, extInThresholdMv);
        end
        %% 
        function [chA,chB,chC,chD,fs] = func_rapidBlockCap(app,Obj,timebaseIndex,numSSamples,numCaptures)
            if ~exist('numsamples','var');numSSamples = 15000;end
            if ~exist('numCaptures','var');numCaptures = 50;end
            PS5000aConfig;
            nSegments = 100;
            Tinterval = (timebaseIndex-2)/125000000;
            [status.memorySegments, ~] = invoke(Obj, 'ps5000aMemorySegments', nSegments);
            set(Obj, 'timebase', timebaseIndex);
            rapidBlockGroupObj = get(Obj, 'Rapidblock');
            rapidBlockGroupObj = rapidBlockGroupObj(1);
            blockGroupObj = get(Obj, 'Block');
            blockGroupObj = blockGroupObj(1);
            [status.setNoOfCaptures] = invoke(rapidBlockGroupObj, 'ps5000aSetNoOfCaptures', numCaptures);
            [status.runBlock, ~] = invoke(blockGroupObj, 'runBlock', 0);
            [status.getNoOfCaptures, numCaptures] = invoke(rapidBlockGroupObj, 'ps5000aGetNoOfCaptures');
            set(Obj, 'numPreTriggerSamples', 0);
            set(Obj, 'numPostTriggerSamples',numSSamples);
            [status.runBlock] = invoke(blockGroupObj, 'runBlock', 0);
            downsamplingRatio       = 1;
            downsamplingRatioMode   = ps5000aEnuminfo.enPS5000ARatioMode.PS5000A_RATIO_MODE_NONE;
            [numSamples, overflow, chA, chB, chC, chD] = invoke(rapidBlockGroupObj, 'getRapidBlockData', numCaptures, ...
                downsamplingRatio, downsamplingRatioMode);
            [status.getNoOfCaptures, numCaptures] = invoke(rapidBlockGroupObj, 'ps5000aGetNoOfCaptures');
            fs = 1/Tinterval;
            
        end
        
        function results = this2double(app, thisKind)
            if ischar(thisKind) || isstring(thisKind)
                results = str2double(thisKind);
            elseif isnumeric(thisKind)
                results = double(thisKind);
            else
                results = NaN;
            end
        end
        
%         function responsive_pause(app,event, total_pause_time)
%             interval = 0.1;
%             iterations = round(total_pause_time / interval);
%             
%             for i = 1:iterations
%                 pause(interval);
%                 
%                 if event == true
%                     break;  
%                 end
%             end
%         end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            set(app.Lamp,'color','red');              % lamp for connecting
            set(app.working_Lamp,'color','black');    % lamp for waorking 
            
            app.Lamp_condition.Text        = strcat('Device Is Not Connectedÿ');
            app.chA_width                  = 7;
            app.chB_width                  = 7;
            app.chC_width                  = 7;
            app.chD_width                  = 7;
            app.channelResolution          = 15;
            app.prefs                      = 1.25e8;
            app.freq                       = 25e5;
            app.waveNum                    = 3;
            app.f_start                    = app.freq /sqrt(2);
            app.f_end                      = app.freq *sqrt(2);
            app.Ulti_channel_choice        = 'channel A';
            app.Ulti_eject_choice          = 'Frequency Setting';
            app.FreqRangeHzEditField.Value = num2str(app.freq/sqrt(2));
            app.HzEditField_2.Value        = num2str(app.freq*sqrt(2));
            app.cd                         = [fullfile(getenv('USERPROFILE'), 'Desktop'),'\'];
            app.sigNum                     = 20;
            app.pauseTime                  = 30; 
            app.Ulti_receive_choice        = 'Number of Captured Signals';
            app.sigSampleNum               = 15e3;
            app.sig_name_choice            = 'saving Path';
            app.fileName                   = 'forTest.mat';
            app.numCaptures                = 50;
            app.breakDown                  = false;
            app.paraConfirm_choice         = false;
            app.paraConfirm_choice_2       = false;
            app.figureNameChannelA         = 'The real-time waveform displays channelA';
            app.figureNameChannelB         = 'The real-time waveform displays channelB';
            app.figureNameChannelC         = 'The real-time waveform displays channelC';
            app.figureNameChannelD         = 'The real-time waveform displays channelD';
        end

        % Value changed function: DeviceConnect
        function DeviceConnectValueChanged(app, event)
            value = app.DeviceConnect.Value;
            if value == true
                %% loading cfg
                PS5000aConfig;
                %% connecting
                if (exist('Obj', 'var') && app.Obj.isvalid && strcmp(app.Obj.status, 'open'))
                    openDevice = questionDialog(['Device Object ps5000aDeviceObject has an open connection. ' ...
                        'Do you wish to close the connection and continue?'], ...
                        'Device Object Connection Open');
                    if (openDevice == PicoConstants.TRUE)
                        disconnect(app.Obj);
                        delete(app.Obj);
                    else
                        return;
                    end
                end
                app.Obj = icdevice('picotech_ps5000a_generic', '');
                connect(app.Obj);
                set(app.Lamp,'color','green');
                app.DeviceDisconnect.Value = false;
                app.Lamp_condition.Text = strcat('Device Is Connected Successfullyÿ');
            end
        end

        % Value changed function: DeviceDisconnect
        function DeviceDisconnectValueChanged(app, event)
            app.paraConfirm_choice   = false;
            app.paraConfirm_choice_2 = false;
            value = app.DeviceDisconnect.Value;
            if value == true
                if app.DeviceConnect.Value == true
                    disconnect(app.Obj);
                    delete(app.Obj);
                    app.DeviceConnect.Value = false;
                    set(app.Lamp,'color','red');
                    app.Lamp_condition.Text = strcat('Device Is Not Connectedÿ');
                end
            end
        end

        % Value changed function: channelChoice
        function channelChoiceValueChanged(app, event)
            value = app.channelChoice.Value;
            app.Ulti_channel_choice = value;
            switch app.Ulti_channel_choice
                case 'channel A'
                    app.widthChoice.Value = num2str(app.chA_width);
                case 'channel B'
                    app.widthChoice.Value = num2str(app.chB_width);
                case 'channel C'
                    app.widthChoice.Value = num2str(app.chC_width);
                case 'channel D'
                    app.widthChoice.Value = num2str(app.chD_width);
            end
        end

        % Value changed function: widthChoice
        function widthChoiceValueChanged(app, event)
            value = app.widthChoice.Value;
            switch app.Ulti_channel_choice
                case 'channel A'
                    app.chA_width = str2double(value);
                case 'channel B'
                    app.chB_width = str2double(value);
                case 'channel C'
                    app.chC_width = str2double(value);
                case 'channel D'
                    app.chD_width = str2double(value);

            end
        end

        % Button pushed function: paraConfirm
        function paraConfirmPushed(app, event)
            if app.paraConfirm_choice == false
                app.paraConfirm_choice = true;
            end
            [status.currentPowerSource] = invoke(app.Obj, 'ps5000aCurrentPowerSource');
            [status.setChA] = invoke(app.Obj, 'ps5000aSetChannel', 0, 1, 1, app.chA_width, 0.0);
            [status.setChB] = invoke(app.Obj, 'ps5000aSetChannel', 1, 1, 1, app.chB_width , 0.0);
            if (app.Obj.channelCount == PicoConstants.QUAD_SCOPE && status.currentPowerSource == PicoStatus.PICO_POWER_SUPPLY_CONNECTED)
                [status.setChC] = invoke(app.Obj, 'ps5000aSetChannel', 2, 1, 1, app.chC_width, 0.0);
                [status.setChD] = invoke(app.Obj, 'ps5000aSetChannel', 3, 1, 1, app.chD_width, 0.0);
            end
            % Resolution Max. resolution with 2 channels enabled is 15 bits.
            validResolution = [8,12,14,15,16];
            if ismember(app.channelResolution,validResolution)
                [status.resolution, resolution] = invoke(app.Obj, 'ps5000aSetDeviceResolution', app.channelResolution);
            else
                warningMessage = sprintf('ps5000aSetDeviceResolution: Resolution must be 8, 12, 14, 15 or 16 bits.');
                warndlg(warningMessage, 'Incorrect using');
            end
            
        end

        % Value changed function: ResolutionSpinner
        function ResolutionSpinnerValueChanged(app, event)
            value = app.ResolutionSpinner.Value;
            app.channelResolution = value;
        end

        % Callback function
        function FSEditValueChanged(app, event)
            value = app.FSEdit.Value;
            app.prefs = value;
        end

        % Callback function
        function FreqEditValueChanged(app, event)
            value = app.FreqEdit.Value;
            app.freq = value;
            app.FreqRangeHzEditField.Value = num2str(value/sqrt(2));
            app.HzEditField_2.Value = num2str(value*sqrt(2));
        end

        % Callback function
        function WaveNumEditValueChanged(app, event)
            value = app.WaveNumEdit.Value;
            app.waveNum = value;
        end

        % Button pushed function: paraConfirm_2
        function paraConfirm_2ButtonPushed(app, event)
            if app.paraConfirm_choice_2 == false
                app.paraConfirm_choice_2 = true;
            end
            timebaseIndex        = floor(125000000/app.prefs) + 2;
            % ----
            Tinterval = (timebaseIndex-2)/125000000;
            fsstart = 1/(app.waveNum/app.freq-Tinterval);
            SigFs = 1/Tinterval;
            to = 1/fsstart;
            n = 0:1/SigFs:to;
            x = chirp(n,app.this2double(app.f_start),to,app.this2double(app.f_end));
            x = (x'.*hanning(length(x)))';
            y = [zeros(1,1),x,zeros(1,1)];
            plot(app.recieve_ch1,y);
            xlabel(app.recieve_ch1,'Sampling Point');
            ylabel(app.recieve_ch1,'Amplitude');
            title(app.recieve_ch1,'Setting Signal');
        end

        % Value changed function: FreqRangeHzEditField
        function FreqRangeHzEditFieldValueChanged(app, event)
            value = app.FreqRangeHzEditField.Value;
            app.f_start = value;
        end

        % Value changed function: HzEditField_2
        function HzEditField_2ValueChanged(app, event)
            value = app.HzEditField_2.Value;
            app.f_start = value;
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            if app.DeviceConnect.Value == true
                disconnect(app.Obj);
                delete(app.Obj);
            end
            delete(app)
            
        end

        % Value changed function: sig_eject_para
        function sig_eject_paraValueChanged(app, event)
            value = app.sig_eject_para.Value;
            switch value
                case 'signal main frequency'
                    app.sig_eject_edit.Value = num2str(app.freq);
                case 'Number of pulses'
                    app.sig_eject_edit.Value = num2str(app.waveNum);
                case 'Preset sample rate'
                    app.sig_eject_edit.Value = num2str(app.prefs);
            end
            app.Ulti_eject_choice = value;
        end

        % Value changed function: sig_eject_edit
        function sig_eject_editValueChanged(app, event)
            value = app.sig_eject_edit.Value;
            switch app.Ulti_eject_choice
                case 'signal main frequency'
                    app.freq = app.this2double(value);
                case 'Number of pulses'
                    app.waveNum = app.this2double(value);
                case 'Preset sample rate'
                    app.prefs = app.this2double(value);
            end
        end

        % Value changed function: sig_receive_para
        function sig_receive_paraValueChanged(app, event)
            value = app.sig_receive_para.Value;
            switch value
                case 'Number of Captured Signals'
                    app.sig_receive_edit.Value = num2str(app.sigNum);
                case 'Sampling Points Number'
                    app.sig_receive_edit.Value = num2str(app.sigSampleNum);
                case 'Interval Time'
                    app.sig_receive_edit.Value = num2str(app.pauseTime);
                case 'Signal number for one capture'
                    app.sig_receive_edit.Value = num2str(app.numCaptures);
            end
            app.Ulti_receive_choice = value;
        end

        % Value changed function: sig_receive_edit
        function sig_receive_editValueChanged(app, event)
            value = app.sig_receive_edit.Value;
            switch app.Ulti_receive_choice
                case 'Number of Captured Signals'
                    app.sigNum = app.this2double(value);
                case 'Sampling Points Number'
                    app.sigSampleNum = app.this2double(value);
                case 'Interval Time'
                    app.pauseTime = app.this2double(value);
                case 'Signal number for one capture'
                    app.numCaptures = app.this2double(value);
            end
        end

        % Button pushed function: paraConfirm_4
        function paraConfirm_4ButtonPushed(app, event)
            startTime   = datetime('now');
            if app.paraConfirm_choice == false
                [status.currentPowerSource] = invoke(app.Obj, 'ps5000aCurrentPowerSource');
                [status.setChA] = invoke(app.Obj, 'ps5000aSetChannel', 0, 1, 1, app.chA_width, 0.0);
                [status.setChB] = invoke(app.Obj, 'ps5000aSetChannel', 1, 1, 1, app.chB_width , 0.0);
                if (app.Obj.channelCount == PicoConstants.QUAD_SCOPE && status.currentPowerSource == PicoStatus.PICO_POWER_SUPPLY_CONNECTED)
                    [status.setChC] = invoke(app.Obj, 'ps5000aSetChannel', 2, 1, 1, app.chC_width, 0.0);
                    [status.setChD] = invoke(app.Obj, 'ps5000aSetChannel', 3, 1, 1, app.chD_width, 0.0);
                end
                % ÿÿÿ Max. resolution with 2 channels enabled is 15 bits.
                [status.resolution, resolution] = invoke(app.Obj, 'ps5000aSetDeviceResolution', app.channelResolution);
                app.paraConfirm_choice = true;
            end
            app.breakDown                   = false;
            app.working_Lamp_condition.Text = 'Collecting Is Underway!';
            sigNum_output_text              = 'Captured Signal Number:';
            restTime_output_text            = 'Acquisition Duration::';
            restTime_output_text_2          = 'Remaining for Acquisition:';
            timebaseIndex                   = floor(125000000/app.prefs) + 2;
            filename                        = [app.cd,app.fileName];
            test                            = matfile(filename, 'Writable', true);
            maxFileSize                     = 2 * 1024^3; % 2G
            fileCount                       = 1;
            %----
            getFileSize = @(fname) dir(fname).bytes;
            generateFilename = @(count) [app.cd, app.fileName(1:end-4), sprintf('%03d', count), '.mat'];
            if app.DeviceConnect.Value == true
                for ii = 1:app.sigNum
                    set(app.working_Lamp,'color','yellow');
                    ccTime = datetime('now', 'Format', 'MM_dd_HH_mm_ss');
                    ccStr = char(ccTime);
                    app.sig_chirp(app.Obj,timebaseIndex,app.this2double(app.freq),app.this2double(app.waveNum),app.this2double(app.f_start),app.this2double(app.f_end));
                    
                    [thischA,thischB,thischC,thischD,fs] = app.func_rapidBlockCap(app.Obj,timebaseIndex,app.this2double(app.sigSampleNum),app.this2double(app.numCaptures));
                    
                    % Check the file size
                    % Get the current file size
                    if isfile(filename)
                        currentFileSize = getFileSize(filename);
                        % Check whether the current file size exceeds the maximum allowable size
                        if currentFileSize > maxFileSize
                            % Increment the file count
                            fileCount = fileCount + 1;
                            % Generate a new file name
                            newFilename = generateFilename(fileCount);
                            % Create a new writable MAT file
                            test = matfile(newFilename, 'Writable', true);
                            % The updated file name is New File
                            filename = newFilename;
                        end
                    end
                    % Save the data
                    if ~isempty(thischC)||~isempty(thischD)
                        test.(['chA_',ccStr]) = thischA;
                        test.(['chB_',ccStr]) = thischB;
                        test.(['chC_',ccStr]) = thischC;
                        test.(['chD_',ccStr]) = thischD;
                        plot(app.recieve_ch1,detrend(mean(thischA,2)));
                        app.recieve_ch1.Title.String = app.figureNameChannelA;
                        plot(app.recieve_ch1_2,detrend(mean(thischB,2)));
                        app.recieve_ch1_2.Title.String = app.figureNameChannelB;
                        plot(app.recieve_ch1_3,detrend(mean(thischC,2)));
                        app.recieve_ch1_3.Title.String = app.figureNameChannelC;
                        plot(app.recieve_ch1_4,detrend(mean(thischD,2)));
                        app.recieve_ch1_4.Title.String = app.figureNameChannelD;
                        app.recieve_ch1.YLabel.String   = 'Amplitude';
                        app.recieve_ch1_2.YLabel.String = 'Amplitude';
                        app.recieve_ch1_3.YLabel.String = 'Amplitude';
                        app.recieve_ch1_4.YLabel.String = 'Amplitude';
                        app.recieve_ch1.XLabel.String   = 'Sampling Point';
                        app.recieve_ch1_2.XLabel.String = 'Sampling Point';
                        app.recieve_ch1_3.XLabel.String = 'Sampling Point';
                        app.recieve_ch1_4.XLabel.String = 'Sampling Point';
                    elseif ~isempty(thischD)
                        test.(['chA_',ccStr]) = thischA;
                        test.(['chB_',ccStr]) = thischB;
                        test.(['chC_',ccStr]) = thischC;
                        plot(app.recieve_ch1,detrend(mean(thischA,2)));
                        app.recieve_ch1.Title.String = app.figureNameChannelA;
                        plot(app.recieve_ch1_2,detrend(mean(thischB,2)));
                        app.recieve_ch1_2.Title.String = app.figureNameChannelB;
                        plot(app.recieve_ch1_3,detrend(mean(thischC,2)));
                        app.recieve_ch1_3.Title.String = app.figureNameChannelC;
                        app.recieve_ch1.YLabel.String   = 'Amplitude';
                        app.recieve_ch1_2.YLabel.String = 'Amplitude';
                        app.recieve_ch1_3.YLabel.String = 'Amplitude';
                        app.recieve_ch1.XLabel.String   = 'Sampling Point';
                        app.recieve_ch1_2.XLabel.String = 'Sampling Point';
                        app.recieve_ch1_3.XLabel.String = 'Sampling Point';
                    else
                        test.(['chA_',ccStr]) = thischA;
                        test.(['chB_',ccStr]) = thischB;
                        plot(app.recieve_ch1,detrend(mean(thischA,2)));
                        app.recieve_ch1.Title.String = app.figureNameChannelA;
                        plot(app.recieve_ch1_2,detrend(mean(thischB,2)));
                        app.recieve_ch1_2.Title.String = app.figureNameChannelB;
                        app.recieve_ch1.YLabel.String   = 'Amplitude';
                        app.recieve_ch1_2.YLabel.String = 'Amplitude';
                        app.recieve_ch1.XLabel.String   = 'Sampling Point';
                        app.recieve_ch1_2.XLabel.String = 'Sampling Point';
                    end
                    test.(['fs',ccStr]) = fs; 
                    
                    app.sig_condition.Text = [sigNum_output_text,num2str(ii)];
                    totalSeconds = (app.sigNum-1) * app.pauseTime;
                    
                    if ii ~= app.sigNum
                        interval_time = 1;
                        for idx = 1:app.pauseTime/interval_time
                            if mod(idx,2) == 0
                                set(app.working_Lamp,'color','blue');
                            else
                                set(app.working_Lamp,'color','yellow');
                            end
                            pause(interval_time);
                            currentTime                       = datetime('now');
                            durationTime                      = abs(startTime - currentTime);
                            app.sig_condition_time.Text       = sprintf('%s\n %s',restTime_output_text,string(durationTime));
                            dur                               = seconds(totalSeconds) - durationTime;
                            app.sig_condition_time_2.Text     = sprintf('%s\n %s',restTime_output_text_2,datestr(dur, 'HH:MM:SS'));
                            app.sig_condition_time_2.FontName = 'Times New Roman';
                            if app.breakDown == true
                                this_choice = true;
                                break;
                            else
                                this_choice = false;
                            end
                        end
                        if this_choice == true
                            break
                        end
                    end
                end
            end
            set(app.working_Lamp,'color','black');
            app.working_Lamp_condition.Text = 'capture has not started';
            app.breakDown                   = false;
            pause('on');
        end

        % Value changed function: sig_name_edit
        function sig_name_editValueChanged(app, event)
            value = app.sig_name_edit.Value;
            switch value
                case 'SavingPath'
                    app.cd_edit.Value = app.cd;
                case 'SavingName'
                    app.cd_edit.Value = 'forTest.mat';
            end
            app.sig_name_choice = value;
        end

        % Value changed function: cd_edit
        function cd_editValueChanged(app, event)
            value = app.cd_edit.Value;
            switch app.sig_name_edit.Value
                case 'SavingPath'
                    app.cd = value;
                case 'SavingName'
                    if endsWith(value,'.mat')
                        app.fileName = value;
                    else
                        app.fileName = [value,'.mat'];
                    end
            end
        end

        % Button pushed function: TerminateButton
        function TerminateButtonPushed(app, event)
            app.breakDown = true;
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {995, 995};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {242, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1493 995];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {242, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create DeviceConnect
            app.DeviceConnect = uibutton(app.LeftPanel, 'state');
            app.DeviceConnect.ValueChangedFcn = createCallbackFcn(app, @DeviceConnectValueChanged, true);
            app.DeviceConnect.VerticalAlignment = 'top';
            app.DeviceConnect.Text = 'CONNECT';
            app.DeviceConnect.BackgroundColor = [0.8 0.8 0.8];
            app.DeviceConnect.FontName = 'Times New Roman';
            app.DeviceConnect.FontSize = 35;
            app.DeviceConnect.FontWeight = 'bold';
            app.DeviceConnect.FontColor = [0 0 1];
            app.DeviceConnect.Position = [6 939 230 50];

            % Create DeviceDisconnect
            app.DeviceDisconnect = uibutton(app.LeftPanel, 'state');
            app.DeviceDisconnect.ValueChangedFcn = createCallbackFcn(app, @DeviceDisconnectValueChanged, true);
            app.DeviceDisconnect.VerticalAlignment = 'top';
            app.DeviceDisconnect.Text = 'Disconnect';
            app.DeviceDisconnect.BackgroundColor = [0.8 0.8 0.8];
            app.DeviceDisconnect.FontName = 'Times New Roman';
            app.DeviceDisconnect.FontSize = 35;
            app.DeviceDisconnect.FontWeight = 'bold';
            app.DeviceDisconnect.FontColor = [1 0 0];
            app.DeviceDisconnect.Position = [5 14 230 50];

            % Create channelChoice
            app.channelChoice = uidropdown(app.LeftPanel);
            app.channelChoice.Items = {'channel A', 'channel B', 'channel C', 'channel D'};
            app.channelChoice.ValueChangedFcn = createCallbackFcn(app, @channelChoiceValueChanged, true);
            app.channelChoice.FontName = 'Times New Roman';
            app.channelChoice.FontSize = 25;
            app.channelChoice.FontWeight = 'bold';
            app.channelChoice.BackgroundColor = [0.902 0.902 0.902];
            app.channelChoice.Position = [11 820 170 40];
            app.channelChoice.Value = 'channel A';

            % Create widthChoice
            app.widthChoice = uidropdown(app.LeftPanel);
            app.widthChoice.Items = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
            app.widthChoice.ValueChangedFcn = createCallbackFcn(app, @widthChoiceValueChanged, true);
            app.widthChoice.FontName = 'Times New Roman';
            app.widthChoice.FontSize = 20;
            app.widthChoice.FontWeight = 'bold';
            app.widthChoice.BackgroundColor = [0.902 0.902 0.902];
            app.widthChoice.Position = [191 820 45 40];
            app.widthChoice.Value = '7';

            % Create paraConfirm
            app.paraConfirm = uibutton(app.LeftPanel, 'push');
            app.paraConfirm.ButtonPushedFcn = createCallbackFcn(app, @paraConfirmPushed, true);
            app.paraConfirm.VerticalAlignment = 'top';
            app.paraConfirm.BackgroundColor = [0.8 0.8 0.8];
            app.paraConfirm.FontName = 'Times New Roman';
            app.paraConfirm.FontSize = 35;
            app.paraConfirm.FontWeight = 'bold';
            app.paraConfirm.FontColor = [0 0 1];
            app.paraConfirm.Position = [7 731 230 50];
            app.paraConfirm.Text = 'CONFIRM';

            % Create paraDis
            app.paraDis = uilabel(app.LeftPanel);
            app.paraDis.HorizontalAlignment = 'center';
            app.paraDis.FontName = 'Times New Roman';
            app.paraDis.FontSize = 2;
            app.paraDis.FontWeight = 'bold';
            app.paraDis.FontAngle = 'italic';
            app.paraDis.Position = [14 707 222 22];
            app.paraDis.Text = 'Signal parameter setting area';

            % Create paraConfirm_2
            app.paraConfirm_2 = uibutton(app.LeftPanel, 'push');
            app.paraConfirm_2.ButtonPushedFcn = createCallbackFcn(app, @paraConfirm_2ButtonPushed, true);
            app.paraConfirm_2.VerticalAlignment = 'top';
            app.paraConfirm_2.BackgroundColor = [0.8 0.8 0.8];
            app.paraConfirm_2.FontName = 'Times New Roman';
            app.paraConfirm_2.FontSize = 35;
            app.paraConfirm_2.FontWeight = 'bold';
            app.paraConfirm_2.FontColor = [0 0 1];
            app.paraConfirm_2.Position = [6 548 230 50];
            app.paraConfirm_2.Text = 'DRAW';

            % Create HzEditField_2
            app.HzEditField_2 = uieditfield(app.LeftPanel, 'text');
            app.HzEditField_2.ValueChangedFcn = createCallbackFcn(app, @HzEditField_2ValueChanged, true);
            app.HzEditField_2.FontName = 'Times New Roman';
            app.HzEditField_2.FontSize = 15;
            app.HzEditField_2.FontWeight = 'bold';
            app.HzEditField_2.Position = [141 605 95 20];
            app.HzEditField_2.Value = '3.5e6';

            % Create FSEditFieldLabel_2
            app.FSEditFieldLabel_2 = uilabel(app.LeftPanel);
            app.FSEditFieldLabel_2.HorizontalAlignment = 'right';
            app.FSEditFieldLabel_2.FontName = 'Times New Roman';
            app.FSEditFieldLabel_2.FontSize = 15;
            app.FSEditFieldLabel_2.FontWeight = 'bold';
            app.FSEditFieldLabel_2.Position = [106 601 25 28];
            app.FSEditFieldLabel_2.Text = '~';

            % Create paraDis_2
            app.paraDis_2 = uilabel(app.LeftPanel);
            app.paraDis_2.HorizontalAlignment = 'center';
            app.paraDis_2.FontName = 'Times New Roman';
            app.paraDis_2.FontWeight = 'bold';
            app.paraDis_2.FontAngle = 'italic';
            app.paraDis_2.Position = [19 523 206 22];
            app.paraDis_2.Text = 'Receiving parameter setting area';

            % Create ResolutionSpinnerLabel
            app.ResolutionSpinnerLabel = uilabel(app.LeftPanel);
            app.ResolutionSpinnerLabel.HorizontalAlignment = 'right';
            app.ResolutionSpinnerLabel.FontName = 'Times New Roman';
            app.ResolutionSpinnerLabel.FontSize = 25;
            app.ResolutionSpinnerLabel.FontWeight = 'bold';
            app.ResolutionSpinnerLabel.Position = [27 784 119 31];
            app.ResolutionSpinnerLabel.Text = 'Resolution';

            % Create ResolutionSpinner
            app.ResolutionSpinner = uispinner(app.LeftPanel);
            app.ResolutionSpinner.Limits = [8 16];
            app.ResolutionSpinner.ValueChangedFcn = createCallbackFcn(app, @ResolutionSpinnerValueChanged, true);
            app.ResolutionSpinner.FontName = 'Times New Roman';
            app.ResolutionSpinner.FontSize = 20;
            app.ResolutionSpinner.FontWeight = 'bold';
            app.ResolutionSpinner.BackgroundColor = [0.902 0.902 0.902];
            app.ResolutionSpinner.Position = [181 783 54 32];
            app.ResolutionSpinner.Value = 15;

            % Create paraDis_4
            app.paraDis_4 = uilabel(app.LeftPanel);
            app.paraDis_4.HorizontalAlignment = 'center';
            app.paraDis_4.FontName = 'Times New Roman';
            app.paraDis_4.FontWeight = 'bold';
            app.paraDis_4.FontAngle = 'italic';
            app.paraDis_4.Position = [1 859 186 22];
            app.paraDis_4.Text = 'Device parameter setting area';

            % Create FreqRangeHzEditFieldLabel
            app.FreqRangeHzEditFieldLabel = uilabel(app.LeftPanel);
            app.FreqRangeHzEditFieldLabel.HorizontalAlignment = 'center';
            app.FreqRangeHzEditFieldLabel.FontName = 'Times New Roman';
            app.FreqRangeHzEditFieldLabel.FontSize = 15;
            app.FreqRangeHzEditFieldLabel.FontWeight = 'bold';
            app.FreqRangeHzEditFieldLabel.Position = [6 618 229 37];
            app.FreqRangeHzEditFieldLabel.Text = 'Freq-Range (Hz)';

            % Create FreqRangeHzEditField
            app.FreqRangeHzEditField = uieditfield(app.LeftPanel, 'text');
            app.FreqRangeHzEditField.ValueChangedFcn = createCallbackFcn(app, @FreqRangeHzEditFieldValueChanged, true);
            app.FreqRangeHzEditField.FontName = 'Times New Roman';
            app.FreqRangeHzEditField.FontSize = 15;
            app.FreqRangeHzEditField.FontWeight = 'bold';
            app.FreqRangeHzEditField.Position = [6 605 106 21];
            app.FreqRangeHzEditField.Value = '1.8e6';

            % Create Lamp
            app.Lamp = uilamp(app.LeftPanel);
            app.Lamp.Position = [175 875 60 60];

            % Create Lamp_condition
            app.Lamp_condition = uilabel(app.LeftPanel);
            app.Lamp_condition.FontName = 'Times New Roman';
            app.Lamp_condition.FontSize = 15;
            app.Lamp_condition.FontAngle = 'italic';
            app.Lamp_condition.Position = [20 885 118 37];
            app.Lamp_condition.Text = {'Device acquisition'; ' has not started'};

            % Create sig_receive_para
            app.sig_receive_para = uidropdown(app.LeftPanel);
            app.sig_receive_para.Items = {'Number of Captured Signals', 'Sampling Points Number', 'Interval Time', 'Signal number for one capture'};
            app.sig_receive_para.ValueChangedFcn = createCallbackFcn(app, @sig_receive_paraValueChanged, true);
            app.sig_receive_para.FontName = 'Times New Roman';
            app.sig_receive_para.FontSize = 15;
            app.sig_receive_para.FontWeight = 'bold';
            app.sig_receive_para.BackgroundColor = [0.902 0.902 0.902];
            app.sig_receive_para.Position = [6 486 230 30];
            app.sig_receive_para.Value = 'Number of Captured Signals';

            % Create sig_eject_para
            app.sig_eject_para = uidropdown(app.LeftPanel);
            app.sig_eject_para.Items = {'signal main frequency', 'Number of pulses', 'Preset sample rate'};
            app.sig_eject_para.ValueChangedFcn = createCallbackFcn(app, @sig_eject_paraValueChanged, true);
            app.sig_eject_para.FontName = 'Times New Roman';
            app.sig_eject_para.FontSize = 15;
            app.sig_eject_para.FontWeight = 'bold';
            app.sig_eject_para.BackgroundColor = [0.902 0.902 0.902];
            app.sig_eject_para.Position = [6 675 230 31];
            app.sig_eject_para.Value = 'signal main frequency';

            % Create sig_eject_edit
            app.sig_eject_edit = uieditfield(app.LeftPanel, 'text');
            app.sig_eject_edit.ValueChangedFcn = createCallbackFcn(app, @sig_eject_editValueChanged, true);
            app.sig_eject_edit.FontName = 'Times New Roman';
            app.sig_eject_edit.FontSize = 15;
            app.sig_eject_edit.FontWeight = 'bold';
            app.sig_eject_edit.Position = [6 652 229 24];
            app.sig_eject_edit.Value = '2.5e6';

            % Create sig_receive_edit
            app.sig_receive_edit = uieditfield(app.LeftPanel, 'text');
            app.sig_receive_edit.ValueChangedFcn = createCallbackFcn(app, @sig_receive_editValueChanged, true);
            app.sig_receive_edit.FontName = 'Times New Roman';
            app.sig_receive_edit.FontSize = 15;
            app.sig_receive_edit.FontWeight = 'bold';
            app.sig_receive_edit.Position = [6 463 230 24];
            app.sig_receive_edit.Value = '20';

            % Create paraConfirm_4
            app.paraConfirm_4 = uibutton(app.LeftPanel, 'push');
            app.paraConfirm_4.ButtonPushedFcn = createCallbackFcn(app, @paraConfirm_4ButtonPushed, true);
            app.paraConfirm_4.VerticalAlignment = 'top';
            app.paraConfirm_4.BackgroundColor = [0.8 0.8 0.8];
            app.paraConfirm_4.FontName = 'Times New Roman';
            app.paraConfirm_4.FontSize = 35;
            app.paraConfirm_4.FontWeight = 'bold';
            app.paraConfirm_4.FontColor = [0 0 1];
            app.paraConfirm_4.Position = [6 353 230 50];
            app.paraConfirm_4.Text = 'CAPTURE';

            % Create cd_edit
            app.cd_edit = uieditfield(app.LeftPanel, 'text');
            app.cd_edit.ValueChangedFcn = createCallbackFcn(app, @cd_editValueChanged, true);
            app.cd_edit.FontName = 'Times New Roman';
            app.cd_edit.FontSize = 15;
            app.cd_edit.FontWeight = 'bold';
            app.cd_edit.Position = [6 408 230 25];
            app.cd_edit.Value = 'DESKTOP';

            % Create sig_name_edit
            app.sig_name_edit = uidropdown(app.LeftPanel);
            app.sig_name_edit.Items = {'SavingPath', 'SavingName'};
            app.sig_name_edit.ValueChangedFcn = createCallbackFcn(app, @sig_name_editValueChanged, true);
            app.sig_name_edit.FontName = 'Times New Roman';
            app.sig_name_edit.FontSize = 15;
            app.sig_name_edit.FontWeight = 'bold';
            app.sig_name_edit.BackgroundColor = [0.902 0.902 0.902];
            app.sig_name_edit.Position = [5 432 231 25];
            app.sig_name_edit.Value = 'SavingPath';

            % Create working_Lamp
            app.working_Lamp = uilamp(app.LeftPanel);
            app.working_Lamp.Position = [6 321 20 20];

            % Create working_Lamp_condition
            app.working_Lamp_condition = uilabel(app.LeftPanel);
            app.working_Lamp_condition.FontName = 'Times New Roman';
            app.working_Lamp_condition.FontSize = 15;
            app.working_Lamp_condition.FontAngle = 'italic';
            app.working_Lamp_condition.Position = [39 320 185 21];
            app.working_Lamp_condition.Text = 'Device acquisition has not started';

            % Create TerminateButton
            app.TerminateButton = uibutton(app.LeftPanel, 'push');
            app.TerminateButton.ButtonPushedFcn = createCallbackFcn(app, @TerminateButtonPushed, true);
            app.TerminateButton.BackgroundColor = [0.9882 0.6941 0.6941];
            app.TerminateButton.FontName = 'Times New Roman';
            app.TerminateButton.FontSize = 25;
            app.TerminateButton.FontWeight = 'bold';
            app.TerminateButton.Position = [55 283 125 38];
            app.TerminateButton.Text = 'Terminate';

            % Create sig_condition
            app.sig_condition = uilabel(app.LeftPanel);
            app.sig_condition.FontName = 'Times New Roman';
            app.sig_condition.FontSize = 15;
            app.sig_condition.FontAngle = 'italic';
            app.sig_condition.Position = [6 237 230 22];
            app.sig_condition.Text = 'Device acquisition has not started';

            % Create sig_condition_time_2
            app.sig_condition_time_2 = uilabel(app.LeftPanel);
            app.sig_condition_time_2.FontSize = 15;
            app.sig_condition_time_2.FontAngle = 'italic';
            app.sig_condition_time_2.Position = [119 56 117 112];
            app.sig_condition_time_2.Text = '';

            % Create sig_condition_time
            app.sig_condition_time = uilabel(app.LeftPanel);
            app.sig_condition_time.FontName = 'Times New Roman';
            app.sig_condition_time.FontSize = 15;
            app.sig_condition_time.FontAngle = 'italic';
            app.sig_condition_time.Position = [5 127 230 111];
            app.sig_condition_time.Text = 'Device acquisition has not started';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create recieve_ch1
            app.recieve_ch1 = uiaxes(app.RightPanel);
            title(app.recieve_ch1, 'The real-time waveform displays channelA')
            xlabel(app.recieve_ch1, '')
            ylabel(app.recieve_ch1, '')
            app.recieve_ch1.FontName = 'Times New Roman';
            app.recieve_ch1.FontSize = 15;
            app.recieve_ch1.TitleFontWeight = 'bold';
            app.recieve_ch1.Position = [1 729 1244 260];

            % Create recieve_ch1_2
            app.recieve_ch1_2 = uiaxes(app.RightPanel);
            title(app.recieve_ch1_2, 'The real-time waveform displays channelB')
            xlabel(app.recieve_ch1_2, '')
            ylabel(app.recieve_ch1_2, '')
            app.recieve_ch1_2.FontName = 'Times New Roman';
            app.recieve_ch1_2.FontSize = 15;
            app.recieve_ch1_2.TitleFontWeight = 'bold';
            app.recieve_ch1_2.Position = [1 499 1244 230];

            % Create recieve_ch1_3
            app.recieve_ch1_3 = uiaxes(app.RightPanel);
            title(app.recieve_ch1_3, 'The real-time waveform displays channelC')
            xlabel(app.recieve_ch1_3, '')
            ylabel(app.recieve_ch1_3, '')
            app.recieve_ch1_3.FontName = 'Times New Roman';
            app.recieve_ch1_3.FontSize = 15;
            app.recieve_ch1_3.TitleFontWeight = 'bold';
            app.recieve_ch1_3.Position = [1 262 1244 237];

            % Create recieve_ch1_4
            app.recieve_ch1_4 = uiaxes(app.RightPanel);
            title(app.recieve_ch1_4, 'The real-time waveform displays channelD')
            xlabel(app.recieve_ch1_4, '')
            ylabel(app.recieve_ch1_4, '')
            app.recieve_ch1_4.FontName = 'Times New Roman';
            app.recieve_ch1_4.FontSize = 15;
            app.recieve_ch1_4.TitleFontWeight = 'bold';
            app.recieve_ch1_4.Position = [4 7 1241 252];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app1_autoreflow_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end