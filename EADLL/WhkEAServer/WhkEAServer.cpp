#include <iostream>
#include <stdlib.h>
#include "winsock2.h"
#pragma comment(lib,"ws2_32.lib")
using namespace std;
DWORD WINAPI threadpro(LPVOID pParam)
{
	SOCKET hsock = (SOCKET)pParam;
	char buffer[1024];
	char sendBuffer[1024];
	if(hsock != INVALID_SOCKET)
		cout << "Start Receive" << endl;
	
	while(1)
	{
		int num = recv(hsock, buffer, 1024, 0);
		if(num >= 0)
			cout << "Receive from client " << buffer << endl;
			if(!strcmp(buffer, "A"))
			{
				memset(sendBuffer, 0, 1024);
				strcpy(sendBuffer, "B");
				int ires = send(hsock, sendBuffer, sizeof(sendBuffer), 0);
				cout << "Send to client" << sendBuffer << endl;
			}
			else if(!strcmp(buffer, "C"))
			{
				memset(sendBuffer, 0, 1024);
				strcpy(sendBuffer, "D");
				int ires = send(hsock, sendBuffer, sizeof(sendBuffer), 0);
				cout << "Send to client" << sendBuffer << endl;
				
			}
			else if(!strcmp(buffer, "exit"))
			{
				cout << "Client Close" << endl;
				cout << "Server Process Close" << endl;
				return(0);
			}
			else
			{
				memset(sendBuffer, 0, 1024);
				strcpy(sendBuffer, "ERR");
				int ires = send(hsock, sendBuffer, sizeof(sendBuffer), 0);
				cout << "Send to client" << sendBuffer << endl;
			}
			return(0);
			
	}
}

int main(int argc, char** argv)
{
	WSADATA wsd;
	WSAStartup(MAKEWORD(2,2), &wsd);
	SOCKET m_SockServer;
	sockaddr_in serveraddr;
	sockaddr_in serveraddrfrom;
	SOCKET m_Server[20];
	
	serveraddr.sin_family = AF_INET;
	serveraddr.sin_port = htons(4600);
	serveraddr.sin_addr.S_un.S_addr = inet_addr("127.0.0.1");
	
	m_SockServer = socket(AF_INET, SOCK_STREAM, 0);

	int i = bind(m_SockServer, (sockaddr*)&serveraddr, sizeof(serveraddr));
	cout << "bind:" << i << endl;
	
	int iMaxConnect = 20;
	int iConnect = 0;
	int iLisRet;
	char buf[] = "THIS IS SERVER\0";
	char WarnBuf[] = "it is over Max connect\0";
	int len = sizeof(sockaddr);
	while(1)
	{
		iLisRet = listen(m_SockServer, 0);
		m_Server[iConnect] = accept(m_SockServer, (sockaddr*)&serveraddrfrom, &len);
		
		if(m_Server[iConnect] != INVALID_SOCKET)
		{
			int ires = send(m_Server[iConnect], buf, sizeof(buf), 0);
			cout << "accept" << ires << endl;
			iConnect++;
			if(iConnect > iMaxConnect)
			{
				int ires = send(m_Server[iConnect], WarnBuf, sizeof(WarnBuf), 0);
				
			}
			else
			{
				HANDLE m_Handle;
				DWORD nThreadId = 0;
				m_Handle = (HANDLE)::CreateThread(NULL, 0, threadpro, (LPVOID)m_Server[--iConnect], 0, &nThreadId);
			}
		} 
		
		WSACleanup();
	}
	
	return(0);
}
