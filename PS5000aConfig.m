%% PS5000aConfig
% Configures paths according to platforms and loads information from
% prototype files for PicoScope 5000 Series (A API) Oscilloscopes. The folder 
% that this file is located in must be added to the MATLAB path.
%
% Platform Specific Information:-
%
% Microsoft Windows: Download the Software Development Kit installer from
% the <a href="matlab: web('https://www.picotech.com/downloads')">Pico Technology Download software and manuals for oscilloscopes and data loggers</a> page.
% 
% Linux: Follow the instructions to install the libps5000a and libpswrappers
% packages from the <a href="matlab:
% web('https://www.picotech.com/downloads/linux')">Pico Technology Linux Software & Drivers for Oscilloscopes and Data Loggers</a> page.
%
% Apple macOS: Follow the instructions to install the PicoScope 6
% application from the <a href="matlab: web('https://www.picotech.com/downloads')">Pico Technology Download software and manuals for oscilloscopes and data loggers</a> page.
% Optionally, create a 'maci64' folder in the same directory as this file
% and copy the following files into it:
%
% * libps5000a.dylib and any other libps5000a library files
% * libps5000aWrap.dylib and any other libps5000aWrap library files
% * libpicoipp.dylib and any other libpicoipp library files
% * libiomp5.dylib
%
% Contact our Technical Support team via the <a href="matlab: web('https://www.picotech.com/tech-support/')">Technical Enquiries form</a> for further assistance.
%
% Run this script in the MATLAB environment prior to connecting to the 
% device.
%
% This file can be edited to suit application requirements.
%
% Copyright: © 2013-2019 Pico Technology Ltd. See LICENSE file for terms.	

% 设置路径并加载用于PicoScope 5000系列（A API）示波器的原型文件中的信息。
% 该脚本根据不同的操作系统提供了相应的指令。
% 
% 对于Microsoft Windows，建议从Pico Technology网站下载软件开发工具包（SDK）安装程序。提供了一个链接，
% 可以在下载页面获取SDK。
% 
% 对于Linux，建议安装libps5000a和libpswrappers软件包。它还提供了一个链接，
% 可以在Pico Technology网站上下载Linux软件和驱动程序。
% 
% 对于Apple macOS，建议从Pico Technology网站安装PicoScope 6应用程序。
% 此外，它还提供了可选的说明，可以在与脚本相同的目录中创建一个名为“maci64”的文件夹，并将某些库文件复制到其中。
% 
% 在连接到PicoScope设备之前，应在MATLAB环境中运行该脚本。可以根据具体应用需求对该脚本进行编辑。
%% Set path to shared libraries, prototype and thunk Files
% Set paths to shared library files, prototype and thunk files according to
% the operating system and architecture.

% Identify working directory
ps5000aConfigInfo.workingDir = pwd;

% Find file name
ps5000aConfigInfo.configFileName = mfilename('fullpath');

% Only require the path to the config file
[ps5000aConfigInfo.pathStr] = fileparts(ps5000aConfigInfo.configFileName);

% Identify architecture e.g. 'win64'
ps5000aConfigInfo.archStr = computer('arch');
ps5000aConfigInfo.archPath = fullfile(ps5000aConfigInfo.pathStr, ps5000aConfigInfo.archStr);

% Add path to Prototype and Thunk files if not already present
% 设置了共享库文件、原型文件和thunk文件的路径，根据操作系统和架构进行设置。
% 
% 首先，获取当前的工作目录和配置文件的完整路径。
% 
% 然后，通过调用fileparts函数获取配置文件的路径。
% 
% 接下来，使用computer函数获取当前的架构信息，例如'win64'。
% 
% 最后，将原型文件和thunk文件的路径添加到MATLAB的搜索路径中，以便在需要时可以找到
if (isempty(strfind(path, ps5000aConfigInfo.archPath)))
    
    try

        addpath(ps5000aConfigInfo.archPath);

    catch err

        error('PS5000aConfig:OperatingSystemNotSupported', 'Operating system not supported - please contact support@picotech.com');

    end
    
end

% Set the path to shared libraries according to operating system.

% Define possible paths for drivers - edit to specify location of drivers

ps5000aConfigInfo.macDriverPath = '/Applications/PicoScope6.app/Contents/Resources/lib';
ps5000aConfigInfo.linuxDriverPath = '/opt/picoscope/lib/';

ps5000aConfigInfo.winSDKInstallPath = 'C:\Program Files\Pico Technology\SDK';
ps5000aConfigInfo.winDriverPath = fullfile(ps5000aConfigInfo.winSDKInstallPath, 'lib');

%32-bit version of MATLAB on Windows 64-bit
ps5000aConfigInfo.woW64SDKInstallPath = 'C:\Program Files (x86)\Pico Technology\SDK'; 
ps5000aConfigInfo.woW64DriverPath = fullfile(ps5000aConfigInfo.woW64SDKInstallPath, 'lib');

if (ismac())
    
    % Libraries (including wrapper libraries) are stored in the PicoScope
    % 6 App folder. Add locations of library files to environment variable.
    
    setenv('DYLD_LIBRARY_PATH', ps5000aConfigInfo.macDriverPath);
    
    if(contains(getenv('DYLD_LIBRARY_PATH'), ps5000aConfigInfo.macDriverPath))
       
        addpath(ps5000aConfigInfo.macDriverPath);
        
    else
        
        warning('PS5000aConfig:LibraryPathNotFound','Locations of libraries not found in DYLD_LIBRARY_PATH');
        
    end
    
elseif (isunix())
	    
    % Add path to drivers if not already on the MATLAB path
    if (isempty(strfind(path, ps5000aConfigInfo.linuxDriverPath)))
        
        addpath(ps5000aConfigInfo.linuxDriverPath);
            
    end
		
elseif (ispc())
    
    % Microsoft Windows operating system
    
    % Set path to dll files if the Pico Technology PicoSDK installer has been
    % used or place dll files in the folder corresponding to the
    % architecture. Detect if 32-bit version of MATLAB on 64-bit Microsoft
    % Windows.
    
% 在 Microsoft Windows 操作系统中设置 DLL（动态链接库）文件的路径，
% 专门用于 Pico Technology PicoSDK 安装程序。DLL文件包含多个程序可以同时使用的代码和数据，
% 这有助于减少重复和提高效率。
% 设置 DLL 文件路径的目的是确保程序在运行时可以访问所需的 DLL 文件。这可以通过安装 PicoSDK 安装程序（自动设置路径）
% 或根据系统体系结构手动将 DLL 文件放置在适当的文件夹中来完成。
% 该代码还包括一个检查，用于检测 MATLAB 是否在 32 位 Microsoft Windows 系统上作为 64 位版本运行。
% 此检查是必要的，因为根据操作系统的体系结构，可能需要不同版本的 DLL 文件。
% 总之，该代码通过设置 DLL 文件的路径来确保程序可以使用必要的 DLL 文件，并包括对 MATLAB 版本架构的检查，
% 以确定要使用的适当 DLL 文件。
    ps5000aConfigInfo.winSDKInstallPath = '';
    
    if (strcmp(ps5000aConfigInfo.archStr, 'win32') && exist('C:\Program Files (x86)\', 'dir') == 7)
        
        % Add path to drivers if not already on the MATLAB path
        if (isempty(strfind(path, ps5000aConfigInfo.woW64DriverPath)))
            
            try 

                addpath(ps5000aConfigInfo.woW64DriverPath);

            catch err

                warning('PS5000aConfig:DirectoryNotFound', ['Folder C:\Program Files (x86)\Pico Technology\SDK\lib\ not found. '...
                    'Please ensure that the location of the library files are on the MATLAB path.']);

            end
            
        end
        
    else
        
        % 32-bit MATLAB on 32-bit Windows or 64-bit MATLAB on 64-bit
        % Windows operating systems
        
        % Add path to drivers if not already on the MATLAB path
        if (isempty(strfind(path, ps5000aConfigInfo.winDriverPath)))
            
            try 

                addpath(ps5000aConfigInfo.winDriverPath);

            catch err

                warning('PS5000aConfig:DirectoryNotFound', ['Folder C:\Program Files\Pico Technology\SDK\lib\ not found. '...
                    'Please ensure that the location of the library files are on the MATLAB path.']);

            end
            
        end
        
    end
    
else
    
    error('PS5000aConfig:OperatingSystemNotSupported', 'Operating system not supported - please contact support@picotech.com');
    
end

%% Set path for PicoScope Support Toolbox files if not installed
% Set MATLAB Path to include location of PicoScope Support Toolbox
% Functions and Classes if the Toolbox has not been installed. Installation
% of the toolbox is only supported in MATLAB 2014b and later versions.
% Check if PicoScope Support Toolbox is installed - using code based on
% <http://stackoverflow.com/questions/6926021/how-to-check-if-matlab-toolbox-installed-in-matlab How to check if matlab toolbox installed in matlab>


% 用于设置MATLAB路径，以包括PicoScope支持工具箱的函数和类的位置，
% 前提是该工具箱尚未安装。该工具箱的安装仅支持MATLAB 2014b及更高版本。
% 首先，检查PicoScope支持工具箱是否已安装，通过调用ver函数获取已安装的工具箱信息，
% 并检查其中是否包含PicoScope支持工具箱。
% 如果PicoScope支持工具箱未安装，则显示警告信息，并搜索工具箱所在的文件夹。
% 接下来，代码检查MATLAB路径中是否包含PicoScope支持工具箱的文件夹。如果未找到该文件夹，
% 则显示警告信息，提示用户安装或下载该工具箱，并将其所在位置添加到MATLAB路径中。
% 最后，将工作目录切换回脚本所在的文件夹。
% 请注意，警告信息和消息可能会根据具体情况而有所不同。
ps5000aConfigInfo.psTbxName = 'PicoScope Support Toolbox';
ps5000aConfigInfo.v = ver; % Find installed toolbox information

if (~any(strcmp(ps5000aConfigInfo.psTbxName, {ps5000aConfigInfo.v.Name})))
   
    warning('PS5000aConfig:PSTbxNotFound', 'PicoScope Support Toolbox not found, searching for folder.');
    
    % If the PicoScope Support Toolbox has not been installed, check to see
    % if the folder is on the MATLAB path, having been downloaded via zip
    % file.
    
    ps5000aConfigInfo.psTbxFound = strfind(path, ps5000aConfigInfo.psTbxName);
    
    if (isempty(ps5000aConfigInfo.psTbxFound))
        
        ps5000aConfigInfo.psTbxNotFoundWarningMsg = sprintf(['Please either:\n'...
            '(1) install the PicoScope Support Toolbox via the Add-Ons Explorer or\n'...
            '(2) download the zip file from MATLAB Central File Exchange and add the location of the extracted contents to the MATLAB path.']);
        
        warning('PS5000aConfig:PSTbxDirNotFound', ['PicoScope Support Toolbox not found. ', ps5000aConfigInfo.psTbxNotFoundWarningMsg]);
        
        ps5000aConfigInfo.f = warndlg(ps5000aConfigInfo.psTbxNotFoundWarningMsg, 'PicoScope Support Toolbox Not Found', 'modal');
        uiwait(ps5000aConfigInfo.f);
        
        web('https://uk.mathworks.com/matlabcentral/fileexchange/53681-picoscope-support-toolbox');
            
    end
    
end

% Change back to the folder where the script was called from.
cd(ps5000aConfigInfo.workingDir);

%% Load enumerations and structure information
% Enumerations and structures are used by certain Intrument Driver functions.

% Find prototype file names based on architecture
% 用于加载枚举和结构信息，这些信息将被某些仪器驱动函数使用。
% 首先，根据系统架构确定原型文件的名称。
% 然后，通过调用str2func函数将原型文件的名称转换为函数句柄，
% 并将其赋值给ps5000aConfigInfo.ps5000aMFile和ps5000aConfigInfo.ps5000aWrapMFile变量。
% 接下来，使用ps5000aConfigInfo.ps5000aMFile函数获取仪器驱动函数的方法信息(ps5000aMethodinfo)、
% 结构信息(ps5000aStructs)、枚举信息(ps5000aEnuminfo)和thunk库名称(ps5000aThunkLibName)。
% 请注意，具体函数调用和返回值可能因实际情况而有所不同。


ps5000aConfigInfo.ps5000aMFile = str2func(strcat('ps5000aMFile_', ps5000aConfigInfo.archStr));
ps5000aConfigInfo.ps5000aWrapMFile = str2func(strcat('ps5000aWrapMFile_', ps5000aConfigInfo.archStr));

[ps5000aMethodinfo, ps5000aStructs, ps5000aEnuminfo, ps5000aThunkLibName] = ps5000aConfigInfo.ps5000aMFile(); 
