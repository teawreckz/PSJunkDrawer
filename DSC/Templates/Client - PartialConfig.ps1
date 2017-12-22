﻿[DscLocalConfigurationManager()]
Configuration PartialConfig
{
    Node localhost #This should always be 'localhost' for config name based DSC pull configs.
    {
        Settings
        {
            RefreshFrequencyMins            = 30; 
            RefreshMode                     = "PULL"; #Clients periodically pull configs from server
            ConfigurationMode               ="ApplyAndAutocorrect";
            AllowModuleOverwrite            = $true;
            RebootNodeIfNeeded              = $true;
            ConfigurationModeFrequencyMins  = 60;
        }

        ConfigurationRepositoryWeb PullSrv
        {
            ServerURL                       = 'https://dsc01:8080/PSDSCPullServer.svc' #For lab purposes this is fine. Prefer FQDN in prod
            RegistrationKey                 = '6cf7e4e2-fd19-4e51-9212-bfa831725f10' #This reg key is unique to lab environment
            ConfigurationNames              = @("Config01", "Config02") #List of config names, separated by commas
            AllowUnsecureConnection         = $false #Allow unsecure comms in cases with bad or no cert
        }

        PartialConfiguration Config01
        {
            Description                     = 'Part01'
            ConfigurationSource             = @("[ConfigurationRepositoryWeb]PullSrv")
            RefreshMode                     = 'Pull'
        }

        Partialconfiguration Config02
        {
            Description                     = 'Part02'
            ConfigurationSource             = @("[ConfigurationRepositoryWeb]PullSrv")
            DependsOn                       = '[PartialConfiguration]Config01'
            RefreshMode                     = 'Pull'
        }
    }
}

# Create and cd to a dedicated config folder
$ConfigRoot = 'C:\DSCConfig'
if (!(Test-Path -Path $ConfigRoot))
{
    New-Item -Path $ConfigRoot -ItemType Directory -Force
}

Set-Location -Path $ConfigRoot
PartialConfig #Create the mof file localhost.meta.mof in C:\DSCConfig\MyConfig

#To apply config, run the following in elevated prompt
#Set-DSCLocalConfigurationManager localhost -Path C:\DSCConfig\MyConfig -Verbose