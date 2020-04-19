/* Replace "dll.h" with the name of your header */
#include <windows.h>
#include <iostream>
#include <string.h>
#include <vector>
#include <sstream>
#include <time.h>
#include <CMath>
#define _DLLAPI extern "C" __declspec(dllexport)
using namespace std;

time_t String2Time(const string& ATime, const string& AFormat="%d-%d-%d")  
{  
    struct tm tm_Temp;  
    time_t time_Ret;  
    try 
    {
        int i = sscanf(ATime.c_str(), AFormat.c_str(),// "%d/%d/%d %d:%d:%d" ,       
                    &(tm_Temp.tm_year),   
                    &(tm_Temp.tm_mon),   
                    &(tm_Temp.tm_mday),  
                    &(tm_Temp.tm_hour),  
                    &(tm_Temp.tm_min),  
                    &(tm_Temp.tm_sec),  
                    &(tm_Temp.tm_wday),  
                    &(tm_Temp.tm_yday));  
             
        tm_Temp.tm_year -= 1900;  
        tm_Temp.tm_mon --;  
        tm_Temp.tm_hour=0;  
        tm_Temp.tm_min=0;  
        tm_Temp.tm_sec=0;  
        tm_Temp.tm_isdst = 0;
        time_Ret = mktime(&tm_Temp);  
        return time_Ret;  
    } catch(...) {
        return 0;
    }
}  

time_t NowTime()
{
    time_t t_Now = time(0);
    struct tm* tm_Now = localtime(&t_Now);
    tm_Now->tm_hour =0;
    tm_Now->tm_min = 0;
    tm_Now->tm_sec = 0;
    return  mktime(tm_Now);  
}

bool IsValidTime(const time_t& AEndTime, const time_t& ANowTime )
{
    return (AEndTime >= ANowTime);
}

bool IsNotExpired(string endtime)
{
	//endtime ="2018-2-9";

	time_t now = NowTime();
	time_t end = String2Time(endtime);
	if (IsValidTime(end, now)) {
		return true;
	} else {
		return false;
	}
}

void split(const string& src, const string& separator, vector<string>& dest)
{
    string str = src;
    string substring;
    string::size_type start = 0, index;

    do
    {
        index = str.find_first_of(separator,start);
        if (index != string::npos)
        {    
            substring = str.substr(start,index-start);
            dest.push_back(substring);
            start = str.find_first_not_of(separator,index);
            if (start == string::npos) return;
        }
    }while(index != string::npos);
    
    //the last token
    substring = str.substr(start);
    dest.push_back(substring);
}


double BasePoint;

struct SPrice
{
	double open;
	double close;
	double high;
	double low;
	double volume;
};

  
struct SIndicator
{
	double time;
	double adx_m5;
	double wpr_m5;
	double ma700_m5;
	double close_m5;
	double rsi_m5;	
	double bid;
	double ask;
	double high_h4;
	double low_h4;
	double rsiLimit; 
	double openh1_0;
	double closeh1_0;
	double openh1_1;
	double closeh1_1;
	double atrh1_0;
	double atrh1_1;
	double atrh4_0;
	double atrh4_1;
	double atrd1_0;
	double h41;
	double h42;
	double d1;
	double d2;
	double w1;
	double w2;	
	int low30d_i;
	double low30d_v;
	int high30d_i;
	double high30d_v;
	int low90d_i;
	double low90d_v;
	int high90d_i;
	double high90d_v;
	int low1y_i;
	double low1y_v;
	int high1y_i;
	double high1y_v;		
};

class OrderInfo
{
public:	
	long ticket;
	int cmd;
	double lots;	
	double openprice;
	double closeprice;
	double stoploss;
	double takeprofit;
	int magic;
	double losspoint;		
	int type;//add, update, delete	

	OrderInfo()
	{
		ticket = 0; cmd = -1; lots = 0; openprice = 0; closeprice = 0; stoploss = 0; takeprofit = 0; magic = 0; losspoint = 0; type = 0;				
	}; 
};
struct SConfig
{
	double basePoint;
	double lots1; int wpr1; int adx1; int maxSL; int minMove; int maxMove; double baseLots9; int bcStep9; int bcRate9; 
	int startLevel9; 
    double baseLots2; int atr2; int bcStep8; double bcRate8;
	
};
struct SOrderSummary
{
	double profit;
	double profitHis;
	bool has20;
	bool has21;
	double point20;
	double point21;
	double loss90;
	double loss91;
	double loss80;
	double loss81;
};
struct SMarket
{
	double lowM1;
	double highM1;
	double lowM3;
	double highM3;
	double lowY1;
	double highY1;
};

class CIndicator
{
public:
	SIndicator data;
	int trend;
	double rate;
	
	CIndicator(){};
	void BuildIndicator(SIndicator ind)
	{
		data = ind;			
		trend = -1;
		
		if(data.w1 > data.w2)			
			trend = 0;		
		else
			trend = 1;		
		
		rate = 1;
	};
	
};

class CTrade
{
private:
	SConfig config;
	SOrderSummary summary;
	SMarket market;

	void InitStatus()
	{
		summary.has20 = false;
		summary.has21 = false;
		summary.point20 = 0;
		summary.point21 = 0;
		summary.loss80 = 0;
		summary.loss81 = 0;
		summary.loss90 = 0;
		summary.loss91 = 0;	
		summary.profit = 0;
		summary.profitHis = 0;
	}
public:
	CIndicator *ind;
	vector<OrderInfo> hisOrders;
	vector<OrderInfo> orders;
	
	void CleanOrder(int historyFlag)
	{
		vector<OrderInfo> tmp;
		if(historyFlag == 1) 
			tmp.swap(hisOrders);
		else
			tmp.swap(orders);
	};
		
	void AddOrder(int historyFlag, long ticket, int cmd, double lots, double open, double close, double stoploss, double takeprofit, int magic)
	{
		OrderInfo order;
		order.ticket = ticket;
		order.cmd = cmd;
		order.lots = lots;
		order.openprice = open;
		order.closeprice = close;
		order.stoploss = stoploss;
		order.takeprofit = takeprofit;
		order.magic = magic;
		order.type = 0;
		
		if(historyFlag == 1)
			hisOrders.push_back(order);
		else
			orders.push_back(order);
		
	};	

	bool OrderIsFull(int magicnumber, int cmd, int maxOrderCount)
	{
		if(orders.size() <= 0) return(false);
		
		int orderCount = 0;
		vector<OrderInfo>::iterator iter; 
	    for (iter = orders.begin(); iter != orders.end(); iter++)  
	    {  
	    	OrderInfo order = (OrderInfo)*iter;
	        if(order.magic == magicnumber && order.cmd == cmd)
    			orderCount++;
    	}
    	if(orderCount >= maxOrderCount)
    		return(true);
    	else
    		return(false);
	        
	};
	

	
	bool GetModifyCMD(OrderInfo &order)
	{							  
        double openprice = order.openprice;
        int cmd = order.cmd; 
		double lots = order.lots; 
		long ticket = order.ticket;

	    if(cmd == 0 && ind->data.bid < openprice || cmd == 1 && ind->data.ask > openprice)
		{
		    return false;
		}	
	
	   	double oldstoploss = order.stoploss;
	   	double stoploss = 0;
	   	double takeprofit = order.takeprofit;   	
	   	double adjustPoint = (ind->data.high_h4 - ind->data.low_h4) / BasePoint; 
	   	if(adjustPoint < config.maxMove) 
	   	    adjustPoint = config.maxMove;	
	   	else if(adjustPoint > config.maxMove)
	   	    adjustPoint = config.maxMove;
		   	   	
		adjustPoint *= BasePoint;
	    	
	    bool tobemodify = false; 
		if(cmd == 0)
		{
		    stoploss = ind->data.bid - adjustPoint;			
			if (stoploss > openprice && stoploss > oldstoploss + BasePoint * 2) 
			    tobemodify = true;	
		}
		else
		{
			stoploss = ind->data.ask + adjustPoint;				
			if(stoploss < openprice && stoploss < oldstoploss - BasePoint * 2) 
			    tobemodify = true;		
		}	
		
		if(tobemodify)
		{
			order.stoploss = stoploss;
	    }   
	    
	    return(tobemodify);
	} 
	
	void Appendcmd(OrderInfo order, wostringstream &ss) 
	{
		ss << order.type;
    	ss << ",";
		ss << order.cmd;
    	ss << ",";
    	ss << order.ticket;
    	ss << ",";
    	ss << order.lots;
    	ss << ",";	        	      	
    	ss << order.openprice;
    	ss << ",";        	
    	ss << order.stoploss;
    	ss << ",";        	
    	ss << order.takeprofit;   
    	ss << ",";        	
    	ss << order.magic; 
    	ss << ";";	
	};
	 
	//Modify and Close
	//closeall ?Y?：＜??：o|━???┷????????888|━♀∴??3?|━??：＞：?D|━♀∴ 
	const wchar_t* GetCommands(double profitHis, bool closeall)
	{
		wostringstream ss; 
		if(ind->data.atrh1_0 >= config.adx1 || ind->data.atrh1_1 > config.adx1)		
		{
			int cmd = -1;
			if(ind->data.atrh1_0 >= config.adx1)
			{
				if(ind->data.openh1_0 < ind->data.closeh1_0)
					cmd = 0;
				else
					cmd = 1;
			}
			else if(ind->data.atrh1_1 > config.adx1)
			{
				if(ind->data.openh1_1 < ind->data.closeh1_1)
					cmd = 0;
				else
					cmd = 1;	
			}
			if(cmd != -1 && !OrderIsFull(2, cmd, 1))
			{				
				OrderInfo order;
				order.cmd = cmd;
				order.lots = config.baseLots2;
				order.magic = 2;
				Appendcmd(order, ss);		
			}
		}
		else
		{
			int cmd = -1;
			if(ind->data.wpr_m5 < config.wpr1 + (-100) && ind->trend == 0) 
				cmd = 0;
			else if(ind->data.wpr_m5 > -1* config.wpr1 && ind->trend == 1)
				cmd = 1;
			
			if(cmd != -1 && !OrderIsFull(1, cmd, 1))
			{				
				OrderInfo order;
				order.cmd = cmd;
				order.lots = config.lots1;
				order.magic = 1;
				Appendcmd(order, ss);		
			}
		}
		
				
		InitStatus();
		summary.profitHis = profitHis;
		
		int n = orders.size();
		if(n > 0)
		{
			vector<OrderInfo> LostArr;    
					
			vector<OrderInfo>::iterator iter;
			for (iter = orders.begin(); iter != orders.end(); iter++)  
		    {  
		    	OrderInfo order = (OrderInfo)*iter;
		    	if(order.magic == 2)
		    	{
		    		if(order.cmd == 0) 
		    		{
		    			summary.has20 = true;
		    			summary.point20 = order.openprice;
					}
					else
					{
						summary.has21 = true;
						summary.point21 = order.openprice;
					}
				}
				if(GetModifyCMD(order))
				{
					if(order.magic != 2)
					{
						order.type = 2;
						Appendcmd(order, ss);
					}									
					if(order.cmd == 0)
						summary.profit += (order.stoploss - order.openprice) * order.lots;
					else
						summary.profit += (order.openprice - order.stoploss) * order.lots;
					
				}	
				else if((order.cmd == 0 && order.openprice - ind->data.bid >= config.bcStep9 / 2 * BasePoint) 
					|| (order.cmd == 1 && ind->data.ask - order.openprice >= config.bcStep9 / 2 * BasePoint))
				{
					OrderInfo tmpOrder;  
		            tmpOrder.cmd = order.cmd;
		            tmpOrder.ticket = order.ticket;
		            tmpOrder.lots = order.lots;
		            tmpOrder.openprice = order.openprice;
		            tmpOrder.stoploss = order.stoploss;
		            tmpOrder.takeprofit = order.takeprofit;
		            
		            if(order.cmd == 0)
		            {	
		            	tmpOrder.losspoint = order.openprice - ind->data.bid;
		            	LostArr.push_back(tmpOrder);  
						if(order.magic / 100 == 8) 
							summary.loss80 += tmpOrder.losspoint * tmpOrder.lots;
						else if(order.magic / 100 == 9) 
							summary.loss90 += tmpOrder.losspoint * tmpOrder.lots;
					}	                
		            else
		            {
		            	tmpOrder.losspoint = ind->data.ask - order.openprice; 
		            	LostArr.push_back(tmpOrder);
						
						if(order.magic / 100 == 8) 
							summary.loss81 += tmpOrder.losspoint * tmpOrder.lots;
						else if(order.magic / 100 == 9) 
							summary.loss91 += tmpOrder.losspoint * tmpOrder.lots;
					}	            
				}			
			}
					
			if(LostArr.size() >= 2) L2SOrder(LostArr);				
			Add2StreamOfDC(LostArr, ss);
		}	
	
		wstring strtemp = ss.str();
		const wchar_t* rtn = strtemp.c_str();
		return(rtn);	
	}
	//?????e：o?━|━?：oy??：???：?|━?D???D：＜：oy?│：| 
	void L2SOrder(vector<OrderInfo> &LostArr)
	{
		int size = LostArr.size();
		for (int i = 0; i < size - 1; i++)  
	    {  
	       	for(int j = 0; j < size - 1 - i; j++)
    		{  
                if(LostArr.at(j).losspoint < LostArr.at(j+1).losspoint)
                {  
                    OrderInfo t = LostArr.at(j);  
                    LostArr.at(j) = LostArr.at(j+1);  
                    LostArr.at(j+1) = t;  
                }
            }  
        }    
	}

	void Add2StreamOfDC(vector<OrderInfo> &LostArr, wostringstream &ss)
	{
		if(summary.has20  && ind->data.ask > summary.point20 + 20 *BasePoint || summary.has21 && ind->data.bid < summary.point21 - 20 * BasePoint)
		{
			int closecmd = -1;
			double dtimes;
			int itimes;
			
			if(summary.has20)
			{
				closecmd = 1;							
				double dtimes = (ind->data.ask - summary.point20) / config.bcStep8;
				int itimes = (int)dtimes;				
			}
			else if(summary.has21)
			{
				closecmd = 0;
				double dtimes = (summary.point20 - ind->data.bid) / config.bcStep8;
				int itimes = (int)dtimes;
			}
			
			if(closecmd != -1)
			{
				vector<OrderInfo>::iterator iter; 
			    for (iter = LostArr.begin(); iter != LostArr.end(); iter++)  
			    {  
			    	OrderInfo order = (OrderInfo)*iter;	
					if(order.cmd == closecmd) continue;
		           	order.type = 3;
		            Appendcmd(order, ss);			 
		        }
				
				if(dtimes >= itimes && dtimes < itimes + 0.5) 
				{
					int cmd = !closecmd;					
					int magicnumber = 800 + itimes;
					int maxcount = 1;
					double lots = config.baseLots2 * pow(config.bcRate8, itimes)  * ind->rate;
					if(!OrderIsFull(magicnumber, cmd, maxcount))	
					{
						OrderInfo order;
						order.type = 1;
						order.cmd = cmd;
						order.magic = magicnumber;
						order.lots = lots;
						
						Appendcmd(order, ss);
					}																		
				}					
			}						
		}		
		else
		{
			OrderInfo firstorder = LostArr.at(0);
			double maxloss = firstorder.losspoint / BasePoint; 
			
			double dtimes = maxloss / (double)config.bcStep9;
			int itimes = (int)dtimes;
			int limitTimes = (int)(config.maxSL / config.bcStep9);
			
			if(dtimes >= 0.5)
			{			
				int cmd = -1;
				double lots = 0;
				int magicnumber = 0;
				int maxcount = 0;
	
				if(dtimes < 0.75)
				{
					cmd = ind->trend % 2;
					lots = config.baseLots9;
					magicnumber = 990;
					maxcount = 2;
				}
				else 
				{
					if(dtimes >= itimes && dtimes < itimes + 0.5) 
					{					
						int times = itimes;
						if(itimes > limitTimes / 2) times = limitTimes - itimes;
						lots = config.baseLots9 * pow(config.bcRate9, times - 1);
						maxcount = (times + 2) * 2;																			
					}	
					cmd = ind->trend % 2;	
					magicnumber = 990 + itimes;
				}
										
				if(lots >= 0.01 && cmd != -1 && !OrderIsFull(magicnumber, cmd, maxcount)) 
				{
					OrderInfo order;
					order.type = 1;
					order.cmd = cmd;
					order.magic = magicnumber;
					order.lots = lots * ind->rate;			
					
					Appendcmd(order, ss);
				}						
			}		
	
			double profit = summary.profit;
			if(itimes < config.startLevel9) 
				profit *= 0;
			else
			{
				if(summary.loss90 > 0 && summary.loss91 > 0)
					profit = summary.profitHis * 0.5;
				else
					profit = profit * 0.3;
			}
			
			if(profit > 0)
			{		
				double profitUsed = 0;
		        vector<OrderInfo>::iterator iter; 
			    for (iter = LostArr.begin(); iter != LostArr.end(); iter++)  
			    {  
			    	OrderInfo order = (OrderInfo)*iter;
			  		if(order.magic == 1) continue; 
			  			            
		            double lots;
		            if(profitUsed < profit)
		            {
		            	double thisLoss = order.losspoint * order.lots;
		            
		            	if(profitUsed+thisLoss > profit)
		            	{
		            		lots = (profit - profitUsed) / order.losspoint;
		            		if(lots < 0.01) break;            		 
						}  
						else
						{
							lots = order.lots;					
						}    
						profitUsed += thisLoss;      		
					}
					else
					{
						break;
					}            
		           	order.lots = lots;
		           	order.type = 3;
		            Appendcmd(order, ss);			 
		        }
			}
			OrderInfo testorder = firstorder;
			testorder.type = 4;
			testorder.stoploss = dtimes;
			testorder.takeprofit = limitTimes;		 
			Appendcmd(testorder, ss);
		}
		LostArr.clear();
		
	}
	
	void AddConfig(double basePoint, double lots1, int wpr1, int adx1, int maxSL, int minMove, int maxMove, double baseLots9, int bcStep9, int bcRate9, int startLevel9, 
    double baseLots2, int atr2, int bcStep8, double bcRate8)
	{
		
		BasePoint = basePoint;
		config.lots1 = lots1;
		config.wpr1 = wpr1;
		config.adx1 = adx1;
		config.maxSL = maxSL;
		config.minMove = minMove;
		config.maxMove = maxMove;
		config.baseLots9 = baseLots9;
		config.bcStep9 = bcStep9;
		config.bcRate9 = bcRate9;
		config.startLevel9 = startLevel9;
		config.baseLots2 = baseLots2;
		config.atr2 = atr2;
		config.bcStep8 = bcStep8;
		config.bcRate8 = bcRate8;
	}
	
	CTrade()
	{
		ind = new CIndicator();
	};
	~CTrade()
	{
		delete ind;
		
		CleanOrder(1);
		CleanOrder(0);
	};
};

CTrade *trade;

/* get the trade signal, 0:buy, 1:sell*/
_DLLAPI void __stdcall Init()
{		
	trade = new CTrade();
};

/* get the trade signal, 0:buy, 1:sell*/
_DLLAPI void __stdcall DeInit()
{		
	delete trade;
};

/* get the trade signal, 0:buy, 1:sell*/
_DLLAPI const wchar_t* __stdcall GetCommands(double profitHis, bool closeall)
{
	try
	{	
		if(!IsNotExpired("2018-12-20"))
		{	
			wostringstream ss; 
			ss << "999";
			wstring strtemp = ss.str();
			const wchar_t* rtn = strtemp.c_str();
			return(rtn);
		}		
		return trade->GetCommands(profitHis, closeall);
	}
	catch(...)
	{
		return NULL;
	}
		
};

/* add a order into DLL */

_DLLAPI void __stdcall AddOrder(int historyFlag, long ticket, int cmd, double lots, double open, double close, double stoploss, double takeprofit, int magic)
{	
	try
	{
		trade->AddOrder(historyFlag, ticket, cmd, lots, open, close, stoploss, takeprofit, magic);
	}
	catch(...)
	{		
	}
};
/* add indicators of market */
_DLLAPI void __stdcall AddIndicator(SIndicator &ind)
{
	try
	{
		trade->ind->BuildIndicator(ind);	
	}
	catch(...)
	{		
	}	
};
/* add configs */
_DLLAPI void __stdcall AddConfig(double basePoint, double lots1, int wpr1, int adx1, int maxSL, int minMove, int maxMove, double baseLots9, int bcStep9, int bcRate9, int startLevel9, 
    double baseLots2, int atr2, int bcStep8, double bcRate8)
{
	try
	{
		trade->AddConfig(basePoint, lots1, wpr1, adx1, maxSL, minMove, maxMove, baseLots9, bcStep9, bcRate9, startLevel9, baseLots2, atr2, bcStep8, bcRate8);	
	}
	catch(...)
	{		
	}
};
/* clean orders */
_DLLAPI void __stdcall CleanOrder(int historyFlag)
{
	try
	{
		trade->CleanOrder(historyFlag);
			
	}
	catch(...)
	{		
	}	
};


_DLLAPI const wchar_t* __stdcall GetStringValue(const wchar_t* message)
{
	
		wostringstream ss; 
		ss << "Hello World!??o?";
		
		wstring strtemp = ss.str();
		message = strtemp.c_str();
	
		return (message);
   	//stringstream ss;
	//ss << 3.5;
	//ss << "abc";  
    //std::string temp = ss.str(); 
    //int len=MultiByteToWideChar(CP_ACP, 0, (LPCSTR)temp.c_str(), -1, NULL,0);   
    //wchar_t * wszUtf8 = new wchar_t[len+1];   
    //memset(wszUtf8, 0, len * 2 + 2);   
    //MultiByteToWideChar(CP_ACP, 0, (LPCSTR)temp.c_str(), -1, (LPWSTR)wszUtf8, len);  
   	//return(wszUtf8);
};


int main()
{
	int a = 993;
	cout << (a/10 + 1) * 2 + a % 10;
	
	//cout << exp2(0);
	return(0);
	
	string sEndTime ="2018-12-9";
	if(IsNotExpired(sEndTime))
		cout << "：?DD?━：：??：2";
	else
		cout << "：o?┐??1y?：2";	
	

    
	return(0);
}
