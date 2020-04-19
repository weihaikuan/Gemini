@echo off 
echo *********************************************************** 
echo 备份EA的源码 
echo *********************************************************** 
:start 
::启动过程，切换目录 
:set pwd=%cd% 
:cd %1 
echo 当前目录是%cd%
:input 
::获取输入，根据输入进行处理 
set source=: 
set /p source=确定要备份当前目录吗？[Y/N/Q] 
set "source=%source:"=%" 
if "%source%"=="y" goto clean 
if "%source%"=="Y" goto clean 
if "%source%"=="n" goto noclean 
if "%source%"=="N" goto noclean 
if "%source%"=="q" goto end 
if "%source%"=="Q" goto end 
goto input 
:clean 
::主处理过程，执行复制工作 
@echo on 
rem @for /d /r %%c in (.svn) do @if exist %%c ( rd /s /q %%c chr(38) echo 删除目录%%c) 
::创建目标文件夹
set eafolder=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
if exist C:\EA\"%eafolder%" rd C:\EA\"%eafolder%"
mkdir C:\EA\"%eafolder%"
mkdir C:\EA\"%eafolder%"\Experts
mkdir C:\EA\"%eafolder%"\Include
mkdir C:\EA\"%eafolder%"\Indicators
mkdir C:\EA\"%eafolder%"\Scripts
mkdir C:\EA\"%eafolder%"\tester
mkdir C:\EA\"%eafolder%"\DLL

copy .\MQL4\Experts\Gemini*.mq4 C:\EA\"%eafolder%"\Experts
copy .\MQL4\Include\Gemini*.mqh C:\EA\"%eafolder%"\Include
copy .\MQL4\Indicators\whk*.mq4 C:\EA\"%eafolder%"\Indicators
copy C:\EA\EADLL\Gemini\*.cpp C:\EA\"%eafolder%"\DLL
copy C:\EA\EADLL\Gemini\*.h C:\EA\"%eafolder%"\DLL

@echo off 
echo "当前目录下的gemini代码已复制完成" 
echo %eafolder%>>C:\EA\readme.txt
notepad C:\EA\readme.txt
explorer C:\EA
rem pause
goto end 
:noclean
::分支过程，取消复制 
echo "复制操作已取消" 
:end 
::退出程序 

