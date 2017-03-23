@echo off

rem Cyberwave 
rem June 25/2012
rem Creates a text file containing all of the instances for the word "administrator"
rem found by running three commands. 
rem Creates the text file as results.txt on your desktop under adminSearch

rem _______________________________________________________________________________________

echo SCHTASKS: > %userprofile%\Desktop\adminSearch\results.txt
echo. >> %userprofile%\Desktop\adminSearch\results.txt

setlocal EnableDelayedExpansion
rem Create the info removing empty lines
(for /F "delims=" %%a in ('schtasks /query /fo list /v') do echo %%a) > %userprofile%\Desktop\adminSearch\schtasks.txt
rem Add an additional "HostName:" line at end as delimiter
echo HostName: >> schtasks.txt
rem Create an array of number of lines containing "HostName:"
set i=0
for /F "delims=:" %%a in ('findstr /N "HostName:" schtasks.txt') do (
   set /A i+=1
   set header[!i!]=%%a
)
rem Seek for the LINES containing "admin"
for /F "delims=:" %%a in ('findstr /N /I "administrator" schtasks.txt') do (
   rem Seek for the NEXT section that contains "admin" line
   for /L %%i in (1,1,%i%) do if %%a gtr !header[%%i]! set thisSection=%%i
   rem Locate that section
   set /A start=header[!thisSection!], nextSection=thisSection+1
   set /A end=header[!nextSection!]-1
   rem ... and show it
   set line=0
   echo. >> results.txt
   echo ********************************************************************************** >> results.txt
   echo. >> results.txt
   for /F "delims=" %%a in (schtasks.txt) do (
      set /A line+=1
      if !line! geq !start! if !line! leq !end! echo %%a >> results.txt
   )
)

rem _______________________________________________________________________________________

rem Get WMIC
echo. >> %userprofile%\Desktop\adminSearch\results.txt
echo WMIC: >> %userprofile%\Desktop\adminSearch\results.txt
echo. >> %userprofile%\Desktop\adminSearch\results.txt
wmic service get name,startname  > %userprofile%\Desktop\adminSearch\wmic.txt 
rem WMIC outputs Unicode.  Typecast to ASCII for findstr
TYPE %userprofile%\Desktop\adminSearch\wmic.txt > %userprofile%\Desktop\adminSearch\wmic2.txt
findstr  /i "administrator" %userprofile%\Desktop\adminSearch\wmic2.txt >> %userprofile%\Desktop\adminSearch\results.txt
echo. >> %userprofile%\Desktop\adminSearch\results.txt

rem _______________________________________________________________________________________

rem Get AppCMD
echo APPCMD: >> %userprofile%\Desktop\adminSearch\results.txt
cd C:\Windows\System32\inetsrv\

(for /F "delims=" %%a in ('appcmd list apppool /text:*') do echo %%a) > %userprofile%\Desktop\adminSearch\appcmd.txt
CD %userprofile%\Desktop\adminSearch\
echo APPPOOL >> %userprofile%\Desktop\adminSearch\appcmd.txt
set i=0
for /F "delims=:" %%a in ('findstr /N "APPPOOL" appcmd.txt') do (
   set /A i+=1
   set header[!i!]=%%a
)
rem Seek for the LINES containing "admin"
for /F "delims=:" %%a in ('findstr /N /I "administrator" appcmd.txt') do (
   rem Seek for the NEXT section that contains "admin" line
   for /L %%i in (1,1,%i%) do if %%a gtr !header[%%i]! set thisSection=%%i
   rem Locate that section
   set /A start=header[!thisSection!], nextSection=thisSection+1
   set /A end=header[!nextSection!]-1
   rem ... and show it
   set line=0
   
   for /F "delims=" %%a in (appcmd.txt) do (
      set /A line+=1
      if !line! geq !start! if !line! leq !end! echo %%a >> results.txt
   )
)
rem _______________________________________________________________________________________
rem Cleanup
del wmic.txt
del wmic2.txt
del appcmd.txt
del schtasks.txt



