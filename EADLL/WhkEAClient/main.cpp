    //#include "stdafx.h"   
    #include <iostream>   
    #include <string>   
    #include "request.h"   
      
    using namespace std;   
      
    int _tmain(int argc, _TCHAR* argv[])   
    {   
        Request myRequest;      //初始化类   
        string sHeaderSend;     //定义http头   
        string sHeaderReceive;  //返回头   
        string sMessage="";     //返回页面内容   
        bool IsPost=false;  //是否Post提交   
      
        int i =myRequest.SendRequest(IsPost, "http://www.qq.com", sHeaderSend,   
            sHeaderReceive, sMessage);   
        if (i)   
        {      
            cout<<"Http头:"<<endl;   
            cout<< sHeaderSend <<endl;   
            cout<<"响应头"<<endl;   
            cout<< sHeaderReceive <<endl;   
            cout<<"网页内容"<<endl;  
            cout<< "test"<<sMessage.c_str() <<endl;   
            cout<<sMessage.size()<<endl;  
        }else   
        {   
            cout<<"网络不可到达"<<endl;   
        }   
        system("pause");   
        return 0;   
    }  
