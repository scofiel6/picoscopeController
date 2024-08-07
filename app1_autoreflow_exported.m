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
        sig_condition_time         matlab.ui.control.Label
        toolBoxfilePath            matlab.ui.control.EditField
        addPath                    matlab.ui.control.StateButton
        sig_condition_time_2       matlab.ui.control.Label
        adjustconfirm              matlab.ui.control.Button
        Lamp_adjust                matlab.ui.control.Lamp
        adjustconfirm_2            matlab.ui.control.Button
        paraDis_5                  matlab.ui.control.Label
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
        targetfile
        
        
        adjustPARA
        
        channelASNR
        channelBSNR
        channelCSNR
        channelDSNR
        
        channelAmax
        channelBmax
        channelCmax
        channelDmax
        totoDynamicRange
    end
    
    methods (Access = private)
        
        %% AWG �1� (sin form)
        function sig_cw(app,Obj,timebaseIndex,f,N)
            PS5000aConfig;
            sigGenGroupObj = get(Obj, 'Signalgenerator');
            sigGenGroupObj = sigGenGroupObj(1);
            Tinterval = (timebaseIndex-2)/125000000;
            % sig frequency f�wave number for one capture N
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
        % �2�AWG:chirp
        function sig_chirp(app,Obj,timebaseIndex,f,N,f_start,f_end)
            PS5000aConfig;
            sigGenGroupObj = get(Obj, 'Signalgenerator');
            sigGenGroupObj = sigGenGroupObj(1);
            Tinterval = (timebaseIndex-2)/125000000;
            % sig frequency f�wave number for one capture N
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
%             if ~exist('numsamples','var');numSSamples = 15000;end
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
        
        function current_width = adjust_gain(app,current_width, channel_max, channel_snr, set_channel)
            if (sum(channel_snr < 10) > 3 && channel_snr(end) < 10)
                if current_width > 0
                    current_width = current_width - 1;
                    set_channel(current_width);
                end
            elseif (sum(channel_max > (app.totoDynamicRange(current_width + 1))-5) > 2 && channel_max(end) > (app.totoDynamicRange(current_width + 1))-5)
                if current_width < 10
                    current_width = current_width + 1;
                    set_channel(current_width);
                end
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
            set(app.Lamp_adjust,'color','red');       % lamp for dynamic adjust
            %             addpath(genpath('C:\Users\Admin\Desktop\file\mat for pico\envir_ps5000\github_repo'));
            %             addpath(genpath('C:\Users\Admin\Desktop\file\mat for pico\envir_ps5000\Pico Technology'));
            %
            app.Lamp_condition.Text         = strcat('Device Is Not Connected�');
            app.chA_width                   = 7;
            app.chB_width                   = 7;
            app.chC_width                   = 7;
            app.chD_width                   = 7;
            app.channelResolution           = 15;
            app.prefs                       = 1.25e8;
            app.freq                        = 25e5;
            app.waveNum                     = 3;
            app.f_start                     = app.freq /sqrt(2);
            app.f_end                       = app.freq *sqrt(2);
            app.Ulti_channel_choice         = 'channel A';
            app.Ulti_eject_choice           = 'Frequency Setting';
            app.FreqRangeHzEditField.Value  = num2str(app.freq/sqrt(2));
            app.HzEditField_2.Value         = num2str(app.freq*sqrt(2));
            app.cd                          = [fullfile(getenv('USERPROFILE'), 'Desktop'),'\'];
            app.sigNum                      = 20;
            app.pauseTime                   = 30;
            app.Ulti_receive_choice         = 'Number of Captured Signals';
            app.sigSampleNum                = 15e3;
            app.sig_name_choice             = 'saving Path';
            app.fileName                    = 'forTest.mat';
            app.numCaptures                 = 50;
            app.breakDown                   = false;
            app.paraConfirm_choice          = false;
            app.paraConfirm_choice_2        = false;
            app.figureNameChannelA          = 'The real-time waveform displays channelA';
            app.figureNameChannelB          = 'The real-time waveform displays channelB';
            app.figureNameChannelC          = 'The real-time waveform displays channelC';
            app.figureNameChannelD          = 'The real-time waveform displays channelD';
            app.toolBoxfilePath.Value       = pwd;
            app.targetfile                  = {'github_repo', 'Pico Technology'};
            app.recieve_ch1.YLabel.String   = 'Amplitude';
            app.recieve_ch1_2.YLabel.String = 'Amplitude';
            app.recieve_ch1_3.YLabel.String = 'Amplitude';
            app.recieve_ch1_4.YLabel.String = 'Amplitude';
            app.recieve_ch1.XLabel.String   = 'Sampling Point';
            app.recieve_ch1_2.XLabel.String = 'Sampling Point';
            app.recieve_ch1_3.XLabel.String = 'Sampling Point';
            app.recieve_ch1_4.XLabel.String = 'Sampling Point';
            app.totoDynamicRange            = [10,20,50,100,200,500,1e3,2e3,5e3,10e3,20e3,50e3];
            app.adjustPARA                  = 0;
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
                app.Lamp_condition.Text = strcat('Device Is Connected Successfully�');
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
                    app.Lamp_condition.Text = strcat('Device Is Not Connected�');
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
            fsstart   = 1/(app.waveNum/app.freq-Tinterval);
            SigFs     = 1/Tinterval;
            to        = 1/fsstart;
            n         = 0:1/SigFs:to;
            x         = chirp(n,app.this2double(app.f_start),to,app.this2double(app.f_end));
            x         = (x'.*hanning(length(x)))';
            y         = [zeros(1,1),x,zeros(1,1)];
            plot(app.recieve_ch1,y,'color','green');
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
            app.f_end = value;
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
                % ��� Max. resolution with 2 channels enabled is 15 bits.
                [status.resolution, resolution] = invoke(app.Obj, 'ps5000aSetDeviceResolution', app.channelResolution);
                app.paraConfirm_choice = true;
            end
            thisChannelA_width = app.chA_width;
            thisChannelB_width = app.chB_width;
            thisChannelC_width = app.chC_width;
            thisChannelD_width = app.chD_width;
            app.breakDown                   = false;
            app.working_Lamp_condition.Text = 'Collecting Is Underway!';
            sigNum_output_text              = 'Collected Signal Number:';
            restTime_output_text            = 'Collection Duration::';
            restTime_output_text_2          = 'Remaining for Collection:';
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
                        test.(['chA_',ccStr]) = detrend(mean(thischA,2));
                        test.(['chB_',ccStr]) = detrend(mean(thischB,2));
                        test.(['chC_',ccStr]) = detrend(mean(thischC,2));
                        test.(['chD_',ccStr]) = detrend(mean(thischD,2));
                        % plot the collected DATA
                        plot(app.recieve_ch1,detrend(mean(thischA,2)),'color','green');
                        app.recieve_ch1.Title.String = app.figureNameChannelA;
                        plot(app.recieve_ch1_2,detrend(mean(thischB,2)),'color','green');
                        app.recieve_ch1_2.Title.String = app.figureNameChannelB;
                        plot(app.recieve_ch1_3,detrend(mean(thischC,2)),'color','green');
                        app.recieve_ch1_3.Title.String = app.figureNameChannelC;
                        plot(app.recieve_ch1_4,detrend(mean(thischD,2)),'color','green');
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
                        test.(['chA_',ccStr]) = detrend(mean(thischA,2));
                        test.(['chB_',ccStr]) = detrend(mean(thischB,2));
                        test.(['chC_',ccStr]) = detrend(mean(thischC,2));
                        plot(app.recieve_ch1,detrend(mean(thischA,2)),'color','green');
                        app.recieve_ch1.Title.String = app.figureNameChannelA;
                        plot(app.recieve_ch1_2,detrend(mean(thischB,2)),'color','green');
                        app.recieve_ch1_2.Title.String = app.figureNameChannelB;
                        plot(app.recieve_ch1_3,detrend(mean(thischC,2)),'color','green');
                        app.recieve_ch1_3.Title.String = app.figureNameChannelC;
                        app.recieve_ch1.YLabel.String   = 'Amplitude';
                        app.recieve_ch1_2.YLabel.String = 'Amplitude';
                        app.recieve_ch1_3.YLabel.String = 'Amplitude';
                        app.recieve_ch1.XLabel.String   = 'Sampling Point';
                        app.recieve_ch1_2.XLabel.String = 'Sampling Point';
                        app.recieve_ch1_3.XLabel.String = 'Sampling Point';
                    else
                        test.(['chA_',ccStr]) = detrend(mean(thischA,2));
                        test.(['chB_',ccStr]) = detrend(mean(thischB,2));
                        plot(app.recieve_ch1,detrend(mean(thischA,2)),'color','green');
                        app.recieve_ch1.Title.String = app.figureNameChannelA;
                        plot(app.recieve_ch1_2,detrend(mean(thischB,2)),'color','green');
                        app.recieve_ch1_2.Title.String = app.figureNameChannelB;
                        app.recieve_ch1.YLabel.String   = 'Amplitude';
                        app.recieve_ch1_2.YLabel.String = 'Amplitude';
                        app.recieve_ch1.XLabel.String   = 'Sampling Point';
                        app.recieve_ch1_2.XLabel.String = 'Sampling Point';
                    end
                    test.(['fs',ccStr]) = fs;
                    
                    app.sig_condition.Text = [sigNum_output_text,num2str(ii)];
                    totalSeconds = (app.sigNum-1) * app.pauseTime;
                    
                    
                    
                    if app.adjustPARA == 1
                        update_max_and_snr = @(data) struct('max', max(abs(detrend(mean(data, 2)))),'snr', max(detrend(abs(mean(data, 2)))) / mean(abs(detrend(mean(data, 2)))));
                        update_recent_values = @(recent_values, new_value) recent_values(max(1, end-4):end);
                        
                        thischannelA = update_max_and_snr(thischA);
                        thischannelB = update_max_and_snr(thischB);
                        app.channelAmax = update_recent_values([app.channelAmax; thischannelA.max], thischannelA.max);
                        app.channelBmax = update_recent_values([app.channelBmax; thischannelB.max], thischannelB.max);
                        app.channelASNR = update_recent_values([app.channelASNR; thischannelA.snr], thischannelA.snr);
                        app.channelBSNR = update_recent_values([app.channelBSNR; thischannelB.snr], thischannelB.snr);
                        thisChannelA_width = app.adjust_gain(thisChannelA_width, app.channelAmax, app.channelASNR, @(width) invoke(app.Obj, 'ps5000aSetChannel', 0, 1, 1, width, 0.0));
                        thisChannelB_width = app.adjust_gain(thisChannelB_width, app.channelBmax, app.channelBSNR, @(width) invoke(app.Obj, 'ps5000aSetChannel', 1, 1, 1, width, 0.0));
                        
                        if ~isempty(thischC)
                            thischannelC = update_max_and_snr(thischC);
                            app.channelCmax = update_recent_values([app.channelCmax; thischannelC.max], thischannelC.max);
                            app.channelCSNR = update_recent_values([app.channelCSNR; thischannelC.snr], thischannelC.snr);
                            thisChannelC_width = app.adjust_gain(thisChannelC_width, app.channelCmax, app.channelCSNR, @(width) invoke(app.Obj, 'ps5000aSetChannel', 2, 1, 1, width, 0.0));
                        end
                        if ~isempty(thischD)
                            thischannelD = update_max_and_snr(thischD);
                            app.channelDmax = update_recent_values([app.channelDmax; thischannelD.max], thischannelD.max);
                            app.channelDSNR = update_recent_values([app.channelDSNR; thischannelD.snr], thischannelD.snr);
                            thisChannelD_width = app.adjust_gain(thisChannelD_width, app.channelDmax, app.channelDSNR, @(width) invoke(app.Obj, 'ps5000aSetChannel', 3, 1, 1, width, 0.0));
                        end
                    end
                    
                    
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
                            app.sig_condition_time.Text       = sprintf('%s\n %s',restTime_output_text,strrep(datestr(durationTime, 'dd HH:MM:SS'), ' ', ' days'));
                            dur                               = seconds(totalSeconds) - durationTime;
                            app.sig_condition_time_2.Text     = sprintf('%s\n %s',restTime_output_text_2,strrep(datestr(dur, 'dd HH:MM:SS'), ' ', ' days'));
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
            app.working_Lamp_condition.Text = 'Collection has not started';
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

        % Value changed function: addPath
        function addPathValueChanged(app, event)
            baseFolder = app.toolBoxfilePath.Value;
            if ~endsWith(baseFolder, '\')
                baseFolder = [baseFolder, '\'];
            end
            foundPaths = cell(1, numel(app.targetfile));
            
            folderList = strsplit(genpath(baseFolder), pathsep);
            
            for ii = 1:numel(folderList)-1
                currentFolder = folderList{ii};
                
                for jj = 1:numel(app.targetfile)
                    if isempty(foundPaths{jj})
                        targetFilePath = fullfile(currentFolder, app.targetfile{jj});
                        if exist(targetFilePath, 'dir') == 7
                            foundPaths{jj} = targetFilePath;
                            addpath(genpath(foundPaths{jj}));
                        end
                    end
                end
            end
            for jj = 1:numel(app.targetfile)
                if isempty(foundPaths{jj})
                    messages{jj} = sprintf('The target file %s was not found in the specified path.', app.targetfile{jj});
                else
                    messages{jj} = sprintf('Found %s at %s', app.targetfile{jj}, foundPaths{jj});
                end
            end
            warndlg(messages, 'File Search Results');
            app.addPath.Value = 0;
        end

        % Value changed function: toolBoxfilePath
        function toolBoxfilePathValueChanged(app, event)
            
           

        end

        % Button pushed function: adjustconfirm
        function adjustconfirmButtonPushed(app, event)
            app.adjustPARA = 1;
            set(app.Lamp_adjust,'color','green');
        end

        % Button pushed function: adjustconfirm_2
        function adjustconfirm_2ButtonPushed(app, event)
            app.adjustPARA = 0;
            set(app.Lamp_adjust,'color','red');
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
                app.GridLayout.ColumnWidth = {256, '1x'};
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
            app.GridLayout.ColumnWidth = {256, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.ForegroundColor = [1 0 0];
            app.LeftPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.FontName = 'Times New Roman';

            % Create DeviceConnect
            app.DeviceConnect = uibutton(app.LeftPanel, 'state');
            app.DeviceConnect.ValueChangedFcn = createCallbackFcn(app, @DeviceConnectValueChanged, true);
            app.DeviceConnect.Text = 'CONNECT';
            app.DeviceConnect.BackgroundColor = [0.149 0.149 0.149];
            app.DeviceConnect.FontName = 'Times New Roman';
            app.DeviceConnect.FontSize = 35;
            app.DeviceConnect.FontWeight = 'bold';
            app.DeviceConnect.FontColor = [0 1 0];
            app.DeviceConnect.Position = [15 868 230 50];

            % Create DeviceDisconnect
            app.DeviceDisconnect = uibutton(app.LeftPanel, 'state');
            app.DeviceDisconnect.ValueChangedFcn = createCallbackFcn(app, @DeviceDisconnectValueChanged, true);
            app.DeviceDisconnect.Text = 'Disconnect';
            app.DeviceDisconnect.BackgroundColor = [0.149 0.149 0.149];
            app.DeviceDisconnect.FontName = 'Times New Roman';
            app.DeviceDisconnect.FontSize = 35;
            app.DeviceDisconnect.FontWeight = 'bold';
            app.DeviceDisconnect.FontColor = [1 0 0];
            app.DeviceDisconnect.Position = [15 6 230 50];

            % Create channelChoice
            app.channelChoice = uidropdown(app.LeftPanel);
            app.channelChoice.Items = {'channel A', 'channel B', 'channel C', 'channel D'};
            app.channelChoice.ValueChangedFcn = createCallbackFcn(app, @channelChoiceValueChanged, true);
            app.channelChoice.FontName = 'Times New Roman';
            app.channelChoice.FontSize = 25;
            app.channelChoice.FontWeight = 'bold';
            app.channelChoice.BackgroundColor = [0.902 0.902 0.902];
            app.channelChoice.Position = [20 759 170 40];
            app.channelChoice.Value = 'channel A';

            % Create widthChoice
            app.widthChoice = uidropdown(app.LeftPanel);
            app.widthChoice.Items = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
            app.widthChoice.ValueChangedFcn = createCallbackFcn(app, @widthChoiceValueChanged, true);
            app.widthChoice.FontName = 'Times New Roman';
            app.widthChoice.FontSize = 20;
            app.widthChoice.FontWeight = 'bold';
            app.widthChoice.BackgroundColor = [0.902 0.902 0.902];
            app.widthChoice.Position = [200 759 45 40];
            app.widthChoice.Value = '7';

            % Create paraConfirm
            app.paraConfirm = uibutton(app.LeftPanel, 'push');
            app.paraConfirm.ButtonPushedFcn = createCallbackFcn(app, @paraConfirmPushed, true);
            app.paraConfirm.BackgroundColor = [0.149 0.149 0.149];
            app.paraConfirm.FontName = 'Times New Roman';
            app.paraConfirm.FontSize = 35;
            app.paraConfirm.FontWeight = 'bold';
            app.paraConfirm.FontColor = [0 1 0];
            app.paraConfirm.Position = [15 671 230 50];
            app.paraConfirm.Text = 'CONFIRM';

            % Create paraDis
            app.paraDis = uilabel(app.LeftPanel);
            app.paraDis.FontName = 'Times New Roman';
            app.paraDis.FontSize = 2;
            app.paraDis.FontWeight = 'bold';
            app.paraDis.FontAngle = 'italic';
            app.paraDis.Position = [20 647 230 22];
            app.paraDis.Text = 'Signal parameter setting area';

            % Create paraConfirm_2
            app.paraConfirm_2 = uibutton(app.LeftPanel, 'push');
            app.paraConfirm_2.ButtonPushedFcn = createCallbackFcn(app, @paraConfirm_2ButtonPushed, true);
            app.paraConfirm_2.BackgroundColor = [0.149 0.149 0.149];
            app.paraConfirm_2.FontName = 'Times New Roman';
            app.paraConfirm_2.FontSize = 35;
            app.paraConfirm_2.FontWeight = 'bold';
            app.paraConfirm_2.FontColor = [0 1 0];
            app.paraConfirm_2.Position = [15 491 230 50];
            app.paraConfirm_2.Text = 'DRAW';

            % Create HzEditField_2
            app.HzEditField_2 = uieditfield(app.LeftPanel, 'text');
            app.HzEditField_2.ValueChangedFcn = createCallbackFcn(app, @HzEditField_2ValueChanged, true);
            app.HzEditField_2.FontName = 'Times New Roman';
            app.HzEditField_2.FontSize = 15;
            app.HzEditField_2.FontWeight = 'bold';
            app.HzEditField_2.Position = [150 546 95 20];
            app.HzEditField_2.Value = '3.5e6';

            % Create FSEditFieldLabel_2
            app.FSEditFieldLabel_2 = uilabel(app.LeftPanel);
            app.FSEditFieldLabel_2.HorizontalAlignment = 'right';
            app.FSEditFieldLabel_2.FontName = 'Times New Roman';
            app.FSEditFieldLabel_2.FontSize = 15;
            app.FSEditFieldLabel_2.FontWeight = 'bold';
            app.FSEditFieldLabel_2.Position = [115 542 25 28];
            app.FSEditFieldLabel_2.Text = '~';

            % Create paraDis_2
            app.paraDis_2 = uilabel(app.LeftPanel);
            app.paraDis_2.FontName = 'Times New Roman';
            app.paraDis_2.FontWeight = 'bold';
            app.paraDis_2.FontAngle = 'italic';
            app.paraDis_2.Position = [20 466 230 22];
            app.paraDis_2.Text = 'Receiving parameter setting area';

            % Create ResolutionSpinnerLabel
            app.ResolutionSpinnerLabel = uilabel(app.LeftPanel);
            app.ResolutionSpinnerLabel.HorizontalAlignment = 'right';
            app.ResolutionSpinnerLabel.FontName = 'Times New Roman';
            app.ResolutionSpinnerLabel.FontSize = 25;
            app.ResolutionSpinnerLabel.FontWeight = 'bold';
            app.ResolutionSpinnerLabel.Position = [36 724 119 31];
            app.ResolutionSpinnerLabel.Text = 'Resolution';

            % Create ResolutionSpinner
            app.ResolutionSpinner = uispinner(app.LeftPanel);
            app.ResolutionSpinner.Limits = [8 16];
            app.ResolutionSpinner.ValueChangedFcn = createCallbackFcn(app, @ResolutionSpinnerValueChanged, true);
            app.ResolutionSpinner.FontName = 'Times New Roman';
            app.ResolutionSpinner.FontSize = 20;
            app.ResolutionSpinner.FontWeight = 'bold';
            app.ResolutionSpinner.BackgroundColor = [0.902 0.902 0.902];
            app.ResolutionSpinner.Position = [190 723 54 32];
            app.ResolutionSpinner.Value = 15;

            % Create paraDis_4
            app.paraDis_4 = uilabel(app.LeftPanel);
            app.paraDis_4.FontName = 'Times New Roman';
            app.paraDis_4.FontWeight = 'bold';
            app.paraDis_4.FontAngle = 'italic';
            app.paraDis_4.Position = [20 802 230 22];
            app.paraDis_4.Text = 'Device parameter setting area';

            % Create FreqRangeHzEditFieldLabel
            app.FreqRangeHzEditFieldLabel = uilabel(app.LeftPanel);
            app.FreqRangeHzEditFieldLabel.HorizontalAlignment = 'center';
            app.FreqRangeHzEditFieldLabel.FontName = 'Times New Roman';
            app.FreqRangeHzEditFieldLabel.FontSize = 15;
            app.FreqRangeHzEditFieldLabel.FontWeight = 'bold';
            app.FreqRangeHzEditFieldLabel.Position = [15 559 229 37];
            app.FreqRangeHzEditFieldLabel.Text = 'Freq-Range (Hz)';

            % Create FreqRangeHzEditField
            app.FreqRangeHzEditField = uieditfield(app.LeftPanel, 'text');
            app.FreqRangeHzEditField.ValueChangedFcn = createCallbackFcn(app, @FreqRangeHzEditFieldValueChanged, true);
            app.FreqRangeHzEditField.FontName = 'Times New Roman';
            app.FreqRangeHzEditField.FontSize = 15;
            app.FreqRangeHzEditField.FontWeight = 'bold';
            app.FreqRangeHzEditField.Position = [15 546 106 21];
            app.FreqRangeHzEditField.Value = '1.8e6';

            % Create Lamp
            app.Lamp = uilamp(app.LeftPanel);
            app.Lamp.Position = [193 817 49 49];

            % Create Lamp_condition
            app.Lamp_condition = uilabel(app.LeftPanel);
            app.Lamp_condition.FontName = 'Times New Roman';
            app.Lamp_condition.FontSize = 15;
            app.Lamp_condition.FontAngle = 'italic';
            app.Lamp_condition.Position = [23 822 154 37];
            app.Lamp_condition.Text = {'Device acquisition'; ' has not started'};

            % Create sig_receive_para
            app.sig_receive_para = uidropdown(app.LeftPanel);
            app.sig_receive_para.Items = {'Number of Captured Signals', 'Sampling Points Number', 'Interval Time', 'Signal number for one capture'};
            app.sig_receive_para.ValueChangedFcn = createCallbackFcn(app, @sig_receive_paraValueChanged, true);
            app.sig_receive_para.FontName = 'Times New Roman';
            app.sig_receive_para.FontSize = 15;
            app.sig_receive_para.FontWeight = 'bold';
            app.sig_receive_para.BackgroundColor = [0.902 0.902 0.902];
            app.sig_receive_para.Position = [15 434 230 30];
            app.sig_receive_para.Value = 'Number of Captured Signals';

            % Create sig_eject_para
            app.sig_eject_para = uidropdown(app.LeftPanel);
            app.sig_eject_para.Items = {'signal main frequency', 'Number of pulses', 'Preset sample rate'};
            app.sig_eject_para.ValueChangedFcn = createCallbackFcn(app, @sig_eject_paraValueChanged, true);
            app.sig_eject_para.FontName = 'Times New Roman';
            app.sig_eject_para.FontSize = 15;
            app.sig_eject_para.FontWeight = 'bold';
            app.sig_eject_para.BackgroundColor = [0.902 0.902 0.902];
            app.sig_eject_para.Position = [15 616 230 31];
            app.sig_eject_para.Value = 'Number of pulses';

            % Create sig_eject_edit
            app.sig_eject_edit = uieditfield(app.LeftPanel, 'text');
            app.sig_eject_edit.ValueChangedFcn = createCallbackFcn(app, @sig_eject_editValueChanged, true);
            app.sig_eject_edit.FontName = 'Times New Roman';
            app.sig_eject_edit.FontSize = 15;
            app.sig_eject_edit.FontWeight = 'bold';
            app.sig_eject_edit.Position = [15 593 229 24];
            app.sig_eject_edit.Value = '2.5e6';

            % Create sig_receive_edit
            app.sig_receive_edit = uieditfield(app.LeftPanel, 'text');
            app.sig_receive_edit.ValueChangedFcn = createCallbackFcn(app, @sig_receive_editValueChanged, true);
            app.sig_receive_edit.FontName = 'Times New Roman';
            app.sig_receive_edit.FontSize = 15;
            app.sig_receive_edit.FontWeight = 'bold';
            app.sig_receive_edit.Position = [15 411 230 24];
            app.sig_receive_edit.Value = '20';

            % Create paraConfirm_4
            app.paraConfirm_4 = uibutton(app.LeftPanel, 'push');
            app.paraConfirm_4.ButtonPushedFcn = createCallbackFcn(app, @paraConfirm_4ButtonPushed, true);
            app.paraConfirm_4.BackgroundColor = [0.149 0.149 0.149];
            app.paraConfirm_4.FontName = 'Times New Roman';
            app.paraConfirm_4.FontSize = 35;
            app.paraConfirm_4.FontWeight = 'bold';
            app.paraConfirm_4.FontColor = [0 1 0];
            app.paraConfirm_4.Position = [15 264 230 50];
            app.paraConfirm_4.Text = 'CAPTURE';

            % Create cd_edit
            app.cd_edit = uieditfield(app.LeftPanel, 'text');
            app.cd_edit.ValueChangedFcn = createCallbackFcn(app, @cd_editValueChanged, true);
            app.cd_edit.FontName = 'Times New Roman';
            app.cd_edit.FontSize = 15;
            app.cd_edit.FontWeight = 'bold';
            app.cd_edit.Position = [15 356 230 25];
            app.cd_edit.Value = 'DESKTOP';

            % Create sig_name_edit
            app.sig_name_edit = uidropdown(app.LeftPanel);
            app.sig_name_edit.Items = {'SavingPath', 'SavingName'};
            app.sig_name_edit.ValueChangedFcn = createCallbackFcn(app, @sig_name_editValueChanged, true);
            app.sig_name_edit.FontName = 'Times New Roman';
            app.sig_name_edit.FontSize = 15;
            app.sig_name_edit.FontWeight = 'bold';
            app.sig_name_edit.BackgroundColor = [0.902 0.902 0.902];
            app.sig_name_edit.Position = [14 380 231 25];
            app.sig_name_edit.Value = 'SavingPath';

            % Create working_Lamp
            app.working_Lamp = uilamp(app.LeftPanel);
            app.working_Lamp.Position = [15 240 20 20];

            % Create working_Lamp_condition
            app.working_Lamp_condition = uilabel(app.LeftPanel);
            app.working_Lamp_condition.FontName = 'Times New Roman';
            app.working_Lamp_condition.FontSize = 15;
            app.working_Lamp_condition.FontAngle = 'italic';
            app.working_Lamp_condition.Position = [48 239 185 21];
            app.working_Lamp_condition.Text = 'Device acquisition has not started';

            % Create TerminateButton
            app.TerminateButton = uibutton(app.LeftPanel, 'push');
            app.TerminateButton.ButtonPushedFcn = createCallbackFcn(app, @TerminateButtonPushed, true);
            app.TerminateButton.BackgroundColor = [0.7216 0 0];
            app.TerminateButton.FontName = 'Times New Roman';
            app.TerminateButton.FontSize = 25;
            app.TerminateButton.FontWeight = 'bold';
            app.TerminateButton.FontAngle = 'italic';
            app.TerminateButton.FontColor = [0 0.749 0];
            app.TerminateButton.Position = [65 198 124 39];
            app.TerminateButton.Text = 'Terminate';

            % Create sig_condition
            app.sig_condition = uilabel(app.LeftPanel);
            app.sig_condition.FontName = 'Times New Roman';
            app.sig_condition.FontSize = 15;
            app.sig_condition.FontAngle = 'italic';
            app.sig_condition.Position = [15 169 230 22];
            app.sig_condition.Text = 'Device acquisition has not started';

            % Create sig_condition_time
            app.sig_condition_time = uilabel(app.LeftPanel);
            app.sig_condition_time.VerticalAlignment = 'top';
            app.sig_condition_time.FontName = 'Times New Roman';
            app.sig_condition_time.FontSize = 15;
            app.sig_condition_time.FontAngle = 'italic';
            app.sig_condition_time.Position = [15 113 230 57];
            app.sig_condition_time.Text = '';

            % Create toolBoxfilePath
            app.toolBoxfilePath = uieditfield(app.LeftPanel, 'text');
            app.toolBoxfilePath.ValueChangedFcn = createCallbackFcn(app, @toolBoxfilePathValueChanged, true);
            app.toolBoxfilePath.FontName = 'Times New Roman';
            app.toolBoxfilePath.FontSize = 15;
            app.toolBoxfilePath.FontWeight = 'bold';
            app.toolBoxfilePath.Position = [16 965 229 24];
            app.toolBoxfilePath.Value = 'Path';

            % Create addPath
            app.addPath = uibutton(app.LeftPanel, 'state');
            app.addPath.ValueChangedFcn = createCallbackFcn(app, @addPathValueChanged, true);
            app.addPath.VerticalAlignment = 'top';
            app.addPath.Text = 'addPath';
            app.addPath.BackgroundColor = [0.9882 0.5529 0.3647];
            app.addPath.FontName = 'Calibri';
            app.addPath.FontSize = 25;
            app.addPath.FontWeight = 'bold';
            app.addPath.FontAngle = 'italic';
            app.addPath.FontColor = [0 0 1];
            app.addPath.Position = [42 919 173 40];

            % Create sig_condition_time_2
            app.sig_condition_time_2 = uilabel(app.LeftPanel);
            app.sig_condition_time_2.VerticalAlignment = 'top';
            app.sig_condition_time_2.FontName = 'Times New Roman';
            app.sig_condition_time_2.FontSize = 15;
            app.sig_condition_time_2.FontAngle = 'italic';
            app.sig_condition_time_2.Position = [14 65 231 49];
            app.sig_condition_time_2.Text = '';

            % Create adjustconfirm
            app.adjustconfirm = uibutton(app.LeftPanel, 'push');
            app.adjustconfirm.ButtonPushedFcn = createCallbackFcn(app, @adjustconfirmButtonPushed, true);
            app.adjustconfirm.BackgroundColor = [0 0 0];
            app.adjustconfirm.FontName = 'Arial';
            app.adjustconfirm.FontSize = 25;
            app.adjustconfirm.FontWeight = 'bold';
            app.adjustconfirm.FontColor = [0 1 0];
            app.adjustconfirm.Position = [117 316 45 37];
            app.adjustconfirm.Text = 'on';

            % Create Lamp_adjust
            app.Lamp_adjust = uilamp(app.LeftPanel);
            app.Lamp_adjust.Position = [220 322 24 24];

            % Create adjustconfirm_2
            app.adjustconfirm_2 = uibutton(app.LeftPanel, 'push');
            app.adjustconfirm_2.ButtonPushedFcn = createCallbackFcn(app, @adjustconfirm_2ButtonPushed, true);
            app.adjustconfirm_2.BackgroundColor = [0 0 0];
            app.adjustconfirm_2.FontName = 'Arial';
            app.adjustconfirm_2.FontSize = 25;
            app.adjustconfirm_2.FontWeight = 'bold';
            app.adjustconfirm_2.FontColor = [0 1 0];
            app.adjustconfirm_2.Position = [167 315 48 37];
            app.adjustconfirm_2.Text = 'off';

            % Create paraDis_5
            app.paraDis_5 = uilabel(app.LeftPanel);
            app.paraDis_5.FontName = 'Times New Roman';
            app.paraDis_5.FontSize = 2;
            app.paraDis_5.FontWeight = 'bold';
            app.paraDis_5.FontAngle = 'italic';
            app.paraDis_5.Position = [16 313 111 37];
            app.paraDis_5.Text = {'Dynamic range '; 'adjust'};

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
            app.recieve_ch1.GridLineStyle = '--';
            app.recieve_ch1.GridColor = [1 1 0];
            app.recieve_ch1.GridAlpha = 0.5;
            app.recieve_ch1.Color = [0 0 0];
            app.recieve_ch1.XGrid = 'on';
            app.recieve_ch1.YGrid = 'on';
            app.recieve_ch1.LabelFontSizeMultiplier = 1;
            app.recieve_ch1.TitleFontSizeMultiplier = 1.5;
            app.recieve_ch1.TitleFontWeight = 'bold';
            app.recieve_ch1.BackgroundColor = [1 1 1];
            app.recieve_ch1.Position = [7 741 1225 247];

            % Create recieve_ch1_2
            app.recieve_ch1_2 = uiaxes(app.RightPanel);
            title(app.recieve_ch1_2, 'The real-time waveform displays channelB')
            xlabel(app.recieve_ch1_2, '')
            ylabel(app.recieve_ch1_2, '')
            app.recieve_ch1_2.FontName = 'Times New Roman';
            app.recieve_ch1_2.FontSize = 15;
            app.recieve_ch1_2.GridLineStyle = '--';
            app.recieve_ch1_2.GridColor = [1 1 0];
            app.recieve_ch1_2.GridAlpha = 0.5;
            app.recieve_ch1_2.Color = [0 0 0];
            app.recieve_ch1_2.XGrid = 'on';
            app.recieve_ch1_2.YGrid = 'on';
            app.recieve_ch1_2.LabelFontSizeMultiplier = 1;
            app.recieve_ch1_2.TitleFontSizeMultiplier = 1.5;
            app.recieve_ch1_2.TitleFontWeight = 'bold';
            app.recieve_ch1_2.BackgroundColor = [1 1 1];
            app.recieve_ch1_2.Position = [7 494 1225 247];

            % Create recieve_ch1_3
            app.recieve_ch1_3 = uiaxes(app.RightPanel);
            title(app.recieve_ch1_3, 'The real-time waveform displays channelC')
            xlabel(app.recieve_ch1_3, '')
            ylabel(app.recieve_ch1_3, '')
            app.recieve_ch1_3.FontName = 'Times New Roman';
            app.recieve_ch1_3.FontSize = 15;
            app.recieve_ch1_3.GridLineStyle = '--';
            app.recieve_ch1_3.GridColor = [1 1 0];
            app.recieve_ch1_3.GridAlpha = 0.5;
            app.recieve_ch1_3.Color = [0 0 0];
            app.recieve_ch1_3.XGrid = 'on';
            app.recieve_ch1_3.YGrid = 'on';
            app.recieve_ch1_3.LabelFontSizeMultiplier = 1;
            app.recieve_ch1_3.TitleFontSizeMultiplier = 1.5;
            app.recieve_ch1_3.TitleFontWeight = 'bold';
            app.recieve_ch1_3.BackgroundColor = [1 1 1];
            app.recieve_ch1_3.Position = [7 247 1225 247];

            % Create recieve_ch1_4
            app.recieve_ch1_4 = uiaxes(app.RightPanel);
            title(app.recieve_ch1_4, 'The real-time waveform displays channelD')
            xlabel(app.recieve_ch1_4, '')
            ylabel(app.recieve_ch1_4, '')
            app.recieve_ch1_4.FontName = 'Times New Roman';
            app.recieve_ch1_4.FontSize = 15;
            app.recieve_ch1_4.GridLineStyle = '--';
            app.recieve_ch1_4.GridColor = [1 1 0.0667];
            app.recieve_ch1_4.GridAlpha = 0.5;
            app.recieve_ch1_4.Color = [0 0 0];
            app.recieve_ch1_4.XGrid = 'on';
            app.recieve_ch1_4.YGrid = 'on';
            app.recieve_ch1_4.LabelFontSizeMultiplier = 1;
            app.recieve_ch1_4.TitleFontSizeMultiplier = 1.5;
            app.recieve_ch1_4.TitleFontWeight = 'bold';
            app.recieve_ch1_4.BackgroundColor = [1 1 1];
            app.recieve_ch1_4.Position = [7 0 1225 247];

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