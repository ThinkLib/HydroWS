@echo ��ʼע��
copy TABCTL32.OCX %windir%\SysWOW64\
regsvr32 %windir%\SysWOW64\TABCTL32.OCX /s
@echo TABCTL32.OCXע��ɹ�
@pause