    //#include "stdafx.h"   
    #include <iostream>   
    #include <string>   
    #include "request.h"   
      
    using namespace std;   
      
    int _tmain(int argc, _TCHAR* argv[])   
    {   
        Request myRequest;      //��ʼ����   
        string sHeaderSend;     //����httpͷ   
        string sHeaderReceive;  //����ͷ   
        string sMessage="";     //����ҳ������   
        bool IsPost=false;  //�Ƿ�Post�ύ   
      
        int i =myRequest.SendRequest(IsPost, "http://www.qq.com", sHeaderSend,   
            sHeaderReceive, sMessage);   
        if (i)   
        {      
            cout<<"Httpͷ:"<<endl;   
            cout<< sHeaderSend <<endl;   
            cout<<"��Ӧͷ"<<endl;   
            cout<< sHeaderReceive <<endl;   
            cout<<"��ҳ����"<<endl;  
            cout<< "test"<<sMessage.c_str() <<endl;   
            cout<<sMessage.size()<<endl;  
        }else   
        {   
            cout<<"���粻�ɵ���"<<endl;   
        }   
        system("pause");   
        return 0;   
    }  
