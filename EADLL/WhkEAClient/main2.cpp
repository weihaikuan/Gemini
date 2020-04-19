#include <windows.h>
#include <stdio.h>

WSADATA ws;
int conn;
char abc[1024];
struct sockaddr_in addr;
SOCKET theSocket;
int ii;


void Out2File(char *p){
    FILE *fp = fopen("c:\\temp\\getThatPage.txt","a+");
    fprintf(fp,"%s\n",p);
    fclose(fp);
}

int main ()
{
 		conn = WSAStartup(0x101,&ws);
 		
 		struct hostent *hent = gethostbyname("baidu.com");
        sprintf(abc," WSASTARTUP = %d",conn);
        Out2File(abc);
        theSocket = socket(AF_INET,SOCK_STREAM,0);
        sprintf(abc," SOCKET = %d",theSocket);
        Out2File(abc);
        addr.sin_family = AF_INET;
        addr.sin_port = htons(80);
        addr.sin_addr.s_addr = ((struct in_addr *)(hent->h_addr))->s_addr;
        conn = connect(theSocket, (struct sockaddr *)&addr, sizeof(addr));
        strcpy(abc, "GET / \r\n");
        strcat(abc, "HTTP 1.0 \r\n\r\n");
        send(theSocket,abc,sizeof(abc),0);
        ii = 1;
        while (ii != 0)
        {
            ii = recv(theSocket,abc,1024,0);
            Out2File(abc);
        }
        
		WSACleanup();
}
