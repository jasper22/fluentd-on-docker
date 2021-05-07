# escape=`

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

# FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-ltsc2019
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-20H2 as builder

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG source

WORKDIR /app

COPY ${source:-obj/Docker/publish} .

COPY .\Setup-FluentD.ps1 .

RUN . .\Setup-FluentD.ps1;			`
	Setup-FluentD -Verbose;			`
	Set-ConfigurationFile -Verbose;

CMD ["C:\\app\\Receiver.exe"]

ENTRYPOINT [ ]
