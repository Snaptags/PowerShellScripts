#requires -version 2
function ConvertTo-PSFunction{
<#
    .SYNOPSIS
        Function to "convert" legacy command line commands to PowerShell functions
        
    .DESCRIPTION
		The function creates dynamically functions that call legacy commands which support the output
		format csv (/fo csv). The new functions pass all provided switches + "/fo csv" to the legacy command and 
		pipe the output to ConverFrom-CSV in order to receive PowerShell objects.
		The names of the dynamically created functions consist of the prefix "PS" and the name of the command.
		
    .PARAMETER NativeCommands
        Array of commandline tool name(s) (in case those reside within the SYSTEMPATH, the name without .exe is sufficient)
        
    .EXAMPLE  
        #Convert some built-in commandline tools and use them
       	ConverTo-PSFunction driverquery,systeminfo,getmac,whoami
		#the out-host calls are just necessary to workaround an issue where the output is not displayed when multiple "table" results are displayed
		PSgetmac /v | where {$_."Connection Name" -eq "Ethernet"} | Out-Host
		PSwhoami /groups | Out-Host
		PSsysteminfo | Out-Host
		PSdriverquery /s . /si | where {$_."Manufacturer" -eq "Microsoft"} | Out-Host
#>
    [cmdletbinding()]
	param([string[]]$nativeCommands)
    foreach ($nativeCommand in $nativeCommands){
		$name=[IO.Path]::GetFileNameWithoutExtension($nativeCommand)
		#use GetNewClosure to capture and "fix" the value of the argument within the scriptblock
        Set-Item Function:Global:"PS$name" -Value { & "$nativeCommand" $args /fo csv | ConvertFrom-Csv}.GetNewClosure()
    }
}
