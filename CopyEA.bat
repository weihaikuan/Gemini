@echo off 
echo *********************************************************** 
echo ����EA��Դ�� 
echo *********************************************************** 
:start 
::�������̣��л�Ŀ¼ 
:set pwd=%cd% 
:cd %1 
echo ��ǰĿ¼��%cd%
:input 
::��ȡ���룬����������д��� 
set source=: 
set /p source=ȷ��Ҫ���ݵ�ǰĿ¼��[Y/N/Q] 
set "source=%source:"=%" 
if "%source%"=="y" goto clean 
if "%source%"=="Y" goto clean 
if "%source%"=="n" goto noclean 
if "%source%"=="N" goto noclean 
if "%source%"=="q" goto end 
if "%source%"=="Q" goto end 
goto input 
:clean 
::��������̣�ִ�и��ƹ��� 
@echo on 
rem @for /d /r %%c in (.svn) do @if exist %%c ( rd /s /q %%c chr(38) echo ɾ��Ŀ¼%%c) 
::����Ŀ���ļ���
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
echo "��ǰĿ¼�µ�gemini�����Ѹ������" 
echo %eafolder%>>C:\EA\readme.txt
notepad C:\EA\readme.txt
explorer C:\EA
rem pause
goto end 
:noclean
::��֧���̣�ȡ������ 
echo "���Ʋ�����ȡ��" 
:end 
::�˳����� 

