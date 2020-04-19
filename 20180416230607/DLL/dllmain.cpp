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



class CIndicator
{
public:
	//for 11,12
	double adx_m5;
	double wpr_m5;
	double ma700_m5;
	double close_m5;
	double rsi_m5;
	double adx_m15;
	double wpr_m15;
	double ma700_m15;
	double close_m15;
	double rsi_m15;
	double adx_m30;
	double wpr_m30;
	double ma700_m30;
	double close_m30;
	double rsi_m30;
	double adx_m60;
	double wpr_m60;
	double ma700_m60;
	double close_m60;
	double rsi_m60;
	double adx_m240;
	double wpr_m240;
	double ma700_m240;
	double close_m240;
	double rsi_m240;
	//for 4
	double atr_h1;
	double ma_h1;
	//for trade
	double bid;
	double ask;
	double high_h4;
	double low_h4;	
	double rsiLimit;
	double mah41;
	double mah42;
	double mad11;
	double mad12;
	double maw11;
	double maw12;
	
	int trend;
	
	CIndicator(){};
	
	void BuildIndicator(double arr[])
	{
		adx_m5 = arr[0];
		adx_m15 = arr[1];
		adx_m30 = arr[2];
		adx_m60 = arr[3];
		adx_m240 = arr[4];
		wpr_m5 = arr[5];
		wpr_m15 = arr[6];
		wpr_m30 = arr[7];
		wpr_m60 = arr[8];
		wpr_m240 = arr[9];
		ma700_m5 = arr[10];
		ma700_m15 = arr[11];
		ma700_m30 = arr[12];
		ma700_m60 = arr[13];
		ma700_m240 = arr[14];
		close_m5 = arr[15];
		close_m15 = arr[16];
		close_m30 = arr[17];
		close_m60 = arr[18];
		close_m240 = arr[19];
		rsi_m5 = arr[20];
		rsi_m15 = arr[21];
		rsi_m30 = arr[22];
		rsi_m60 = arr[23];
		rsi_m240 = arr[24];
		atr_h1 = arr[25];
		ma_h1 = arr[26];
	//for trade
		bid = arr[27];
		ask = arr[28];
		high_h4 = arr[29];
		low_h4 = arr[30];
		rsiLimit = arr[31];
    	mah41 = arr[32];
		mah42 = arr[33];		
		mad11 = arr[34];
		mad12 = arr[35];
		maw11 = arr[36];
		maw12 = arr[37];
		
		trend = -1;
		if(maw11 > maw12)
		{
	        trend = 0;
	    }
		else if(maw11 < maw12)
		{
		    trend = 1;
	    }	
		
	};
};

class OrderInfo
{
public:
	int ticket;
	int cmd;
	double lots;	
	double openprice;
	double closeprice;
	double stoploss;
	double takeprofit;
	int magicnumber;
	double losspoint;		
	int type;//add, update, delete	

	OrderInfo()
	{
		ticket = 0; 
		cmd = -1; 
		lots = 0; 
		openprice = 0; 
		closeprice = 0; 
		stoploss = 0; 
		takeprofit = 0; 
		magicnumber = 0; 
		losspoint = 0; 
		type = 0;				
	}; 
};

class CTrade
{
private:
	int RSILimit;
	int Division11;
	int WprOpen11;
	int MAMargin4;
	int MinMovePoint;
	int MaxMovePoint;
	int Digits;
	double BasePoint;
	int MaxSL;
	double Baselots;
	int BCStep;	
	int StartLevel;
	double BcRate;
		
public:
	CIndicator *Ind;
	vector<OrderInfo> hisorders;
	vector<OrderInfo> orders;
	
	void CleanOrder(int historyFlag)
	{
		vector<OrderInfo> tmp;
		if(historyFlag == 1) 
			tmp.swap(hisorders);
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
		order.magicnumber = magic;
		order.type = 0;
		
		if(historyFlag == 1)
			hisorders.push_back(order);
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
	        if(order.magicnumber == magicnumber && order.cmd == cmd)
    			orderCount++;
    	}
    	if(orderCount >= maxOrderCount)
    		return(true);
    	else
    		return(false);
	        
	};
	
	int GetCommand(int &magic, int &magicnumber, double &lots, int maxcount, int frame)
	{
        if(Ind->rsiLimit > RSILimit && Ind->trend == 0 || Ind->rsiLimit < 100 - RSILimit && Ind->trend == 1) return -1;     
        if(Ind->trend < 0) return -1;
        
		int cmd = -1;
		switch(magic)
		{
			case 11:
				{
					double wpr;
					double adx;
					double close;
					double ma700;
					switch(frame)
					{
						case 5: 
							wpr = Ind->wpr_m5; 
							adx = Ind->adx_m5;
							close = Ind->close_m5;
							ma700 = Ind->ma700_m5;
							break;
						case 15: 
							wpr = Ind->wpr_m15; 
							adx = Ind->adx_m15;
							close = Ind->close_m15;
							ma700 = Ind->ma700_m5;
							break;
						case 30: 
							wpr = Ind->wpr_m30; 
							adx = Ind->adx_m30;
							close = Ind->close_m30;
							ma700 = Ind->ma700_m5;
							break;							
						case 60: 
							wpr = Ind->wpr_m60; 
							adx = Ind->adx_m60;
							close = Ind->close_m60;
							ma700 = Ind->ma700_m5;
							break;
						case 240: 
							wpr = Ind->wpr_m240; 
							adx = Ind->adx_m240;
							close = Ind->close_m240;
							ma700 = Ind->ma700_m5;
							break;
					}
					if(adx < Division11 && wpr < WprOpen11 + (-100) && close < ma700 + 60 * BasePoint && Ind->trend == 0)
						cmd = 0;
					else if (adx < Division11 && wpr > -WprOpen11 && close > ma700 - 60 * BasePoint && Ind->trend  == 1)
						cmd = 1;
				}
				break;
			case 12:
				{
					double rsi;
					double close;
					double ma700;
					switch(frame)
					{
						case 5: 
							rsi = Ind->rsi_m5;
							close = Ind->close_m5;
							ma700 = Ind->ma700_m5;
							break;
						case 15: 
							rsi = Ind->rsi_m15;
							close = Ind->close_m15;
							ma700 = Ind->ma700_m5;
							break;
						case 30: 
							rsi = Ind->rsi_m30;
							close = Ind->close_m30;
							ma700 = Ind->ma700_m5;
							break;							
						case 60: 
							rsi = Ind->rsi_m60;
							close = Ind->close_m60;
							ma700 = Ind->ma700_m5;
							break;
						case 240: 
							rsi = Ind->rsi_m240;
							close = Ind->close_m240;
							ma700 = Ind->ma700_m5;
							break;
					}
					if(rsi < 30 && close < ma700 + 60 * BasePoint && Ind->trend  == 0)
						cmd = 0;
					else if ( rsi > 70 && close > ma700 - 60 * BasePoint && Ind->trend  == 1)
						cmd = 1;
				}
				break;
			case 4:
				{
					if (Ind->close_m5 >= Ind->ma_h1 + Ind->atr_h1 * 1.4 + 13 * BasePoint && Ind->close_m5 < Ind->ma700_m5 + MAMargin4 * BasePoint && Ind->rsi_m5 < 70 && Ind->trend  == 0)		
						cmd = 0;
					else if (Ind->close_m5 <= Ind->ma_h1 - Ind->atr_h1 * 1.4 - 13 * BasePoint && Ind->close_m5 > Ind->ma700_m5 - MAMargin4 * BasePoint	&& Ind->rsi_m5  > 30 && Ind->trend  == 1)
						cmd = 1;
				}
				break;			
		}
		
		if(cmd != -1 && OrderIsFull(magicnumber, cmd, maxcount)) cmd = -1;
		
		return cmd;
	};
	
	bool GetModifycmd(OrderInfo &order, int fixedMovePoint)
	{							  
        double openprice = order.openprice;
        int cmd = order.cmd; 
		double lots = order.lots; 
		long ticket = order.ticket;

	    if(cmd == 0 && Ind->bid < openprice || cmd == 1 && Ind->ask > openprice)
		{
		    return false;
		}	
	
	   	double oldstoploss = order.stoploss;
	   	double stoploss = 0;
	   	double takeprofit = order.takeprofit; 
		double adjustPoint;
		if(fixedMovePoint > 0)  	
	   		adjustPoint = fixedMovePoint;
	   	else
	   	{
	   		adjustPoint = (Ind->high_h4 - Ind->low_h4) / BasePoint; 
		   	if(adjustPoint < MinMovePoint) 
		   	    adjustPoint = MinMovePoint;	
		   	else if(adjustPoint > MaxMovePoint)
		   	    adjustPoint = MaxMovePoint;
		}		
		   	   	
		adjustPoint *= BasePoint;
	    	
	    bool tobemodify = false; 
		if(cmd == 0)
		{
		    stoploss = Ind->bid - adjustPoint;			
			if (stoploss > openprice && stoploss > oldstoploss + BasePoint * 2) 
			    tobemodify = true;	
		}
		else
		{
			stoploss = Ind->ask + adjustPoint;				
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
    	ss << order.magicnumber; 
    	ss << ";";	
	};
	 
	//Modify and Close
	//closeall 暂且没实现，考虑把888单对冲掉所有单 
	const wchar_t* GetCommands(double profitHis, bool closeall)
	{
		wostringstream ss; 
		
		int n = orders.size();
		if(n > 0)
		{			
			vector<OrderInfo> LostArr;    
			bool has0 = false;
			bool has1 = false;
			double loss0 = 0;
			double loss1 = 0;
					
			vector<OrderInfo>::iterator iter;
			for (iter = orders.begin(); iter != orders.end(); iter++)  
		    {  
		    	OrderInfo order = (OrderInfo)*iter;
				if((order.cmd == 0 && order.openprice - Ind->bid >= BCStep / 2 * BasePoint) 
					|| (order.cmd == 1 && Ind->ask - order.openprice >= BCStep / 2 * BasePoint))
				{
					OrderInfo tmpOrder;  
					tmpOrder.type = 0; 
		            tmpOrder.cmd = order.cmd;
		            tmpOrder.ticket = order.ticket;
		            tmpOrder.lots = order.lots;
		            tmpOrder.openprice = order.openprice;
		            tmpOrder.stoploss = order.stoploss;
		            tmpOrder.takeprofit = order.takeprofit;
		            
		            if(order.cmd == 0)
		            {	
		            	if(order.magicnumber != 110) has0 = true;
		            	tmpOrder.losspoint = order.openprice - Ind->bid;
		            	LostArr.push_back(tmpOrder);  
		            	loss0 += tmpOrder.losspoint * tmpOrder.lots;
					}	                
		            else
		            {
						if(order.magicnumber != 110) has1 = true;
		            	tmpOrder.losspoint = Ind->ask - order.openprice; 
		            	LostArr.push_back(tmpOrder);
						loss1 += tmpOrder.losspoint * tmpOrder.lots;		            	         	
					}	            
				}	
						
			}
			
			int flag = -1; 
			int fixedMovePoint = 0;
			if(has0 && has1)//天地悬空 
			{
				flag = 2;
				fixedMovePoint = 10;
			}				
			else if(has1)
				flag = 1;
			else if(has0)
				flag = 0;
			
			double profit = 0;
			for (iter = orders.begin(); iter != orders.end(); iter++)  
		    {  
		    	OrderInfo order = (OrderInfo)*iter;
				if(GetModifycmd(order, fixedMovePoint))
				{
					order.type = 2;
					Appendcmd(order, ss);
					if(order.cmd == 0)
						profit += (order.stoploss - order.openprice) * order.lots;
					else
						profit += (order.openprice - order.stoploss) * order.lots;
				}						
			}		
			if(flag != -1)
			{
				if(LostArr.size() >= 2) L2SOrder(LostArr);			
				Add2StreamOfDC(LostArr, ss, flag, profit, profitHis, loss0, loss1);
			}
			
			vector<OrderInfo> tmp;		
			tmp.swap(LostArr);
		}	
	
		wstring strtemp = ss.str();
		const wchar_t* rtn = strtemp.c_str();
		return(rtn);    	
	}
	//按损失点数从大到小排序数组 
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
	//将数组中需要对冲的Order放入stream里 
	//flag, 2 Buy&Sell, 1 Sell, 0 Buy
	void Add2StreamOfDC(vector<OrderInfo> &LostArr, wostringstream &ss, int flag, double profit, double profitHis, double loss0, double loss1)
	{
		OrderInfo firstorder = LostArr.at(0);
		double maxloss = firstorder.losspoint / BasePoint; 
		
		double dtimes = maxloss / (double)BCStep;
		int itimes = (int)dtimes;
		int limitTimes = (int)(MaxSL / BCStep);
		
		if(dtimes >= 0.5)
		{			
			int cmd = -1;
			double lots = 0;
			int magicnumber = 0;
			int maxcount = 0;

			if(dtimes < 0.75)
			{
				cmd = Ind->trend;
				lots = Baselots;
				magicnumber = 990;
				maxcount = 2;
			}				
			else if(dtimes >= 1 && dtimes <= limitTimes && dtimes >= itimes && dtimes < itimes + 0.5) 
			{	
				int times;
				if(dtimes >= 1 && dtimes < limitTimes / 2)
					times = itimes;
				else
					times = limitTimes - itimes;
									
				lots = Baselots * pow(BcRate, times - 1);
				maxcount = (times + 2) * 2; 
				
				cmd = Ind->trend;
				magicnumber = 990 + itimes;					
			}		
												
			if(lots >= 0.01 && cmd != -1 && !OrderIsFull(magicnumber, cmd, maxcount)) 
			{
				OrderInfo order;
				order.type = 1;
				order.cmd = cmd;
				order.magicnumber = magicnumber;
				order.lots = lots;
				order.closeprice = 0;
				order.losspoint = 0;
				order.openprice = 0;
				order.stoploss = 0;
				order.takeprofit = 0;
				
				Appendcmd(order, ss);
			}						
		}		

		int dccmd = -1;
		if(itimes < StartLevel) 
			profit = 0;
		else		
		{
			if(flag == 0 && Ind->rsi_m5 >= 60)
			{
				profit = profit;
				dccmd = 0;
			}
			else if(flag == 1 && Ind->rsi_m5 <= 40)
			{
				profit = profit;
				dccmd = 1;
			}
			else if(flag == 2)			
			{
				if(Ind->rsi_m5 >= 60)
				{
					profit = profit;
					dccmd = 0;
				}
				else if(Ind->rsi_m5 <= 40)
				{
					profit = profit;
					dccmd = 1;
				}
			}
										
		}
		
		if(profit > 0 && dccmd != -1)
		{		
			double profitUsed = 0;
	        vector<OrderInfo>::iterator iter; 
		    for (iter = LostArr.begin(); iter != LostArr.end(); iter++)  
		    {  
		    	OrderInfo order = (OrderInfo)*iter;
		  		if(order.magicnumber == 110) continue; 
				if(order.cmd != dccmd) continue;      
		  			            
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
		/*		
		OrderInfo testorder = firstorder;
		testorder.type = 4;
		testorder.stoploss = dtimes;
		testorder.takeprofit = limitTimes;		 
		Appendcmd(testorder, ss);
		*/
	}
	
	
	
	void AddConfig(int rsiLimit,int division11,int wprOpen11,int maMargin4,int minMovePoint,int maxMovePoint,
		int digits, double basePoint, int maxSL, double baselots, int bcStep, int startLevel, double bcRate)
	{
		RSILimit = rsiLimit;
		Division11 = division11;
		WprOpen11 = wprOpen11;
		MAMargin4 = maMargin4;
		MinMovePoint = minMovePoint;
		MaxMovePoint = maxMovePoint;
		Digits = digits;		
		BasePoint = basePoint;
		MaxSL = maxSL;
		Baselots = baselots;
		BCStep = bcStep;
		StartLevel = startLevel;
		BcRate = bcRate;
	}
	
	CTrade()
	{
		Ind = new CIndicator();
	};
	~CTrade()
	{
		delete Ind;
		
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
_DLLAPI int __stdcall GetCommand(int &magic, int &magicnumber, double &lots, int maxcount = 0, int frame = 0)
{		
	try
	{
		if(!IsNotExpired("2018-12-20"))
		{	
			return -999;
		}	
		return trade->GetCommand(magic, magicnumber, lots, maxcount, frame);
	}
	catch(...)
	{
		return(-1);
	}
		
};

/* get the trade signal, 0:buy, 1:sell*/
_DLLAPI const wchar_t* __stdcall GetCommands(double profitHis, bool closeall)
{
	try
	{
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
_DLLAPI void __stdcall AddIndicator(double arr[])
{
	try
	{
		trade->Ind->BuildIndicator(arr);	
	}
	catch(...)
	{		
	}	
};
/* add configs */
_DLLAPI void __stdcall AddConfig(int rsiLimit,int division11,int wprOpen11,int maMargin4,int minMovePoint,int maxMovePoint,
		int digits,double basePoint, int maxSL, double baselots, int bcStep, int startLevel, double bcRate)
{
	try
	{
		trade->AddConfig(rsiLimit, division11, wprOpen11, maMargin4, minMovePoint, maxMovePoint, digits, basePoint, maxSL, baselots, bcStep, startLevel, bcRate);	
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
		ss << "Hello World!你好";
		
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
		cout << "有效日期";
	else
		cout << "时间过期";	
	

    
	return(0);
}
