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
private:
	struct CBiaoGan
	{
		int cmd;
		double price;
	};	
	
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
	//for trend
	double ma_k1;
	double ma_k2;
	double ma_k3;
	//for trade
	double bid;
	double ask;
	double high_h4;
	double low_h4;
	
	CBiaoGan BiaoGan;
	int Trend;
	
	CIndicator()
	{
		BiaoGan.cmd = 0;
		BiaoGan.price = 0;
	}
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
	//for trend
		ma_k1 = arr[27];
		ma_k2 = arr[28];
		ma_k3 = arr[29];
	//for trade
		bid = arr[30];
		ask = arr[31];
		high_h4 = arr[32];
		low_h4 = arr[33];
		
		SetBiaoGan();
	};

private:
	int GetTrend()
	{
		int rtn = -1;
  
		if(ma_k2 > ma_k3)// && Ask - low < 50 * BasePoint)
		{
	        if(ma_k1 > 0 && ma_k1 < ma_k2)
	            rtn = -1;
			else
			    rtn = 0;
	    }
		else if(ma_k2 < ma_k3)// && high - Bid < 50 * BasePoint)
		{
		    if(ma_k1 > 0 && ma_k1 > ma_k2)
	            rtn = -1;
			else
			    rtn = 1;
	    }
	    return(rtn);
	};
	
	void SetBiaoGan()
	{
		Trend = GetTrend();
		if(BiaoGan.cmd != Trend)
		{
			BiaoGan.cmd = Trend;
			BiaoGan.price = ask;
		}
	}
};

struct OrderInfo
{
	long Ticket;
	int CMD;
	double Lots;	
	double OpenPrice;
	double ClosePrice;
	double StopLoss;
	double TakeProfit;
	int Magic;
	double LossPoint;	
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
	double Percentage4hedging;
	int DuichongPoint;	
	int Digits;
	double BasePoint;
	int MaxSL;
	double BaseLots;
	double BCRate;
	int BCStep;	
	
public:
	CIndicator Ind;
	vector<OrderInfo> HisOrders;
	vector<OrderInfo> Orders;
	
	void CleanOrder(int historyFlag)
	{
		if(historyFlag == 1) 
			HisOrders.clear();
		else
			Orders.clear();
	};
		
	void AddOrder(int historyFlag, long ticket, int cmd, double lots, double open, double close, double stoploss, double takeprofit, int magic)
	{
		OrderInfo order;
		order.Ticket = ticket;
		order.CMD = cmd;
		order.Lots = lots;
		order.OpenPrice = open;
		order.ClosePrice = close;
		order.StopLoss = stoploss;
		order.TakeProfit = takeprofit;
		order.Magic = magic;
		if(historyFlag == 1)
			HisOrders.push_back(order);
		else
			Orders.push_back(order);
	};
	
	bool OrderIsFull(int magicnumber, int cmd, int maxOrderCount)
	{
		int orderCount = 0;
		vector<OrderInfo>::iterator iter; 
	    for (iter = Orders.begin(); iter != Orders.end(); iter++)  
	    {  
	    	OrderInfo order = (OrderInfo)*iter;
	        int cmd0 = order.CMD;
	        if(order.Magic == magicnumber && order.CMD == cmd)
    			orderCount++;
    	}
    	if(orderCount >= maxOrderCount)
    		return(true);
    	else
    		return(false);
	        
	}
	
	int GetCommand(int &magic, int &magicnumber, double &lots, int maxcount, int frame)
	{
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
							wpr = Ind.wpr_m5; 
							adx = Ind.adx_m5;
							close = Ind.close_m5;
							ma700 = Ind.ma700_m5;
							break;
						case 15: 
							wpr = Ind.wpr_m15; 
							adx = Ind.adx_m15;
							close = Ind.close_m15;
							ma700 = Ind.ma700_m15;
							break;
						case 30: 
							wpr = Ind.wpr_m30; 
							adx = Ind.adx_m30;
							close = Ind.close_m30;
							ma700 = Ind.ma700_m30;
							break;							
						case 60: 
							wpr = Ind.wpr_m60; 
							adx = Ind.adx_m60;
							close = Ind.close_m60;
							ma700 = Ind.ma700_m60;
							break;
						case 240: 
							wpr = Ind.wpr_m240; 
							adx = Ind.adx_m240;
							close = Ind.close_m240;
							ma700 = Ind.ma700_m240;
							break;
					}
					if(adx < Division11 && wpr < WprOpen11 + (-100) && close < ma700 + 60 * BasePoint && Ind.Trend == 0)
						cmd = 0;
					else if (adx < Division11 && wpr > -WprOpen11 && close > ma700 - 60 * BasePoint && Ind.Trend  == 1)
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
							rsi = Ind.rsi_m5;
							close = Ind.close_m5;
							ma700 = Ind.ma700_m5;
							break;
						case 15: 
							rsi = Ind.rsi_m15;
							close = Ind.close_m15;
							ma700 = Ind.ma700_m15;
							break;
						case 30: 
							rsi = Ind.rsi_m30;
							close = Ind.close_m30;
							ma700 = Ind.ma700_m30;
							break;							
						case 60: 
							rsi = Ind.rsi_m60;
							close = Ind.close_m60;
							ma700 = Ind.ma700_m60;
							break;
						case 240: 
							rsi = Ind.rsi_m240;
							close = Ind.close_m240;
							ma700 = Ind.ma700_m240;
							break;
					}
					if(rsi < 30 && close < ma700 + 60 * BasePoint && Ind.Trend  == 0)
						cmd = 0;
					else if ( rsi > 70 && close > ma700 - 60 * BasePoint && Ind.Trend  == 1)
						cmd = 1;
				}
				break;
			case 4:
				{
					if (Ind.close_m5 >= Ind.ma_h1 + Ind.atr_h1 * 1.4 + 13 * BasePoint && Ind.close_m5 < Ind.ma700_m5 + MAMargin4 * BasePoint && Ind.rsi_m5 < 70 && Ind.Trend  == 0)		
						cmd = 0;
					else if (Ind.close_m5 <= Ind.ma_h1 - Ind.atr_h1 * 1.4 - 13 * BasePoint && Ind.close_m5 > Ind.ma700_m5 - MAMargin4 * BasePoint	&& Ind.rsi_m5  > 30 && Ind.Trend  == 1)
						cmd = 1;
				}
				break;
			case 999:
				{
				 	double maxloss = 0;	
					 			 	
				 	vector<OrderInfo>::iterator iter; 
				    for (iter = Orders.begin(); iter != Orders.end(); iter++)  
				    {  
				    	OrderInfo order = (OrderInfo)*iter;
				        double price = order.OpenPrice;
				        int cmd1 = order.CMD; 
				           
				        if(cmd1 == 0)
				        {            
				            double lossPoint = order.OpenPrice - Ind.bid;
				            if(lossPoint > maxloss) 
				            {
				                maxloss = lossPoint;         
				            }                  
				        }
				        
				        if(cmd1 == 1)
				        {
				            double lossPoint = Ind.ask - order.OpenPrice; 
				            if(lossPoint > maxloss) 
				            {
				                maxloss = lossPoint; 
				            }        
				        }
				    }  
				    
				    maxloss /= BasePoint;
				    
				    if(maxloss > BCStep)
				    {
				    	int bctimes = 1;
				    	if(maxloss < MaxSL / 2)
				    	   	bctimes = maxloss / BCStep;
				    	else
				    		bctimes = (MaxSL - maxloss) / BCStep;
				    	
				    	lots = BaseLots * exp2(bctimes);
				    	magicnumber = magic * 10 + maxloss / BCStep;
				    	maxcount = bctimes + 2;			    	
				    	
			    		cmd = Ind.Trend ;
					}				    
				}	
				break;
		}
		
		if(cmd != -1 && OrderIsFull(magicnumber, cmd, maxcount)) cmd = -1;
		
		return cmd;
	};
	
	//按损失点数从大到小排序数组 
	void L2SOrder(vector<OrderInfo> &LostArr)
	{
		for (int i = 0; i < LostArr.size(); i++)  
	    {  
	    	OrderInfo order = (OrderInfo)LostArr.at(i);
	    	
        	for(int j = 0; j < LostArr.size() - i - 1; j++)
    		{  
                if(LostArr.at(j).LossPoint < LostArr.at(j+1).LossPoint)
                {  
                    OrderInfo t = LostArr.at(j);  
                    LostArr.at(j) = LostArr.at(j+1);  
                    LostArr.at(j+1) = t;  
                }
            }  
        }    
	}
	//将数组中需要对冲的Order放入stream里 
	void Add2StreamOfDC(vector<OrderInfo> &LostArr, wostringstream &ss, double dcloss)
	{
		double totalloss = 0;
        vector<OrderInfo>::iterator iter; 
	    for (iter = LostArr.begin(); iter != LostArr.end(); iter++)  
	    {  
	    	OrderInfo order = (OrderInfo)*iter;
	  		         
            double lossed = order.LossPoint * order.Lots;
            int cmd = order.CMD;
            long ticket = order.Ticket;
            double lots;
            
            if(totalloss < dcloss)
            {
            	if(totalloss+lossed > dcloss)
            	{
            		lots = (dcloss - totalloss) / order.LossPoint;
            		if(lots < 0.01) break;            		 
				}  
				else
				{
					lots = order.Lots;					
				}    
				totalloss += lossed;      		
			}
			else
			{
				break;
			}            
           
            ss << order.CMD;
        	ss << ",";
        	ss << order.Ticket;
        	ss << ",";
        	ss << order.Lots;
        	ss << ";";	          
        }
		
		LostArr.clear();
	}
	
	const wchar_t* Duichong()
	{		
		if(Orders.size() <= 0) return NULL;
		
    	wostringstream ss;    	
    	double profit = 0;	  
		bool hasH0 = false;
		bool hasH1 = false;
		bool has0 = false;
		bool has1 = false;
		double maxH0 = 0;
		double minH1 = 9999;
		double max0 = 0;
		double min1 = 9999;	
		double totalloss0 = 0;
		double totalloss1 = 0;	    	   
		  
		//收集历史记录的信息 
    	if(HisOrders.size() > 0)
    	{	
			vector<OrderInfo>::iterator iter;	
		    for (iter = HisOrders.end()-1; iter >= HisOrders.begin(); iter--)  
		    {  
		    	OrderInfo order = (OrderInfo)*iter;
	              
		        if(order.Magic >= 0)//All profit order will be used. if only 999, should use 9990 instead of 0.
		        {
		            if(order.CMD == 0 && order.ClosePrice > order.OpenPrice)
		            {
		                profit += ((order.ClosePrice - order.OpenPrice) * order.Lots);
		                if(order.ClosePrice > maxH0) maxH0 = order.ClosePrice;
		                hasH0 = true;
		            }
		            if(order.CMD == 1 && order.ClosePrice  < order.OpenPrice)
		            {
		                profit += ((order.OpenPrice - order.ClosePrice ) * order.Lots);
		                if(order.ClosePrice < minH1) minH1 = order.ClosePrice;
		                hasH1 = true;
		            }  
		        }    
		    }   
		}
		
		vector<OrderInfo> LostArr0;    
		vector<OrderInfo> LostArr1; 
	    vector<OrderInfo>::iterator iter; 
	    for (iter = Orders.end() - 1; iter >= Orders.begin(); iter--)  
	    {  
	    	OrderInfo order = (OrderInfo)*iter;
		  
	        double price = order.OpenPrice;
	        int cmd = order.CMD; 
			double lots = order.Lots; 
			long ticket = order.Ticket;
			
			if(lots > 0.01 && (cmd == 0 && price - Ind.bid > DuichongPoint * BasePoint || cmd == 1 && Ind.ask - price  > DuichongPoint * BasePoint))
	        {  		   				
				OrderInfo order;  
	            order.CMD = cmd;
	            order.Ticket = ticket;
	            order.Lots = lots;
	            if(cmd == 0)
	            {
	            	order.LossPoint = price - Ind.bid;
	            	LostArr0.push_back(order);
	            	if(order.OpenPrice > max0) max0 = order.OpenPrice;
	            	has0 = true;
	            	totalloss0 += order.LossPoint;
				}	                
	            else
	            {
	            	order.LossPoint = Ind.ask - price; 
	            	LostArr1.push_back(order);
	            	if(order.OpenPrice < min1) min1 = order.OpenPrice;
	            	has1 = true;
	            	totalloss1 += order.LossPoint;
				}	            
	        }   
        
		}
		if(has0) L2SOrder(LostArr0);
		if(has1) L2SOrder(LostArr1);
		
		if(has0 && has1)//天地悬空 
		{
			if(Ind.Trend == 0 && Ind.bid - min1 > BCStep * BasePoint) 
			{
				int times = (Ind.bid - min1) / BasePoint / BCStep;				
				Add2StreamOfDC(LostArr1, ss, totalloss1 / 8 * times);
			}
			if(Ind.Trend == 1 && max0 - Ind.ask > BCStep * BasePoint) 
			{
				int times = (max0 - Ind.ask) / BasePoint / BCStep;				
				Add2StreamOfDC(LostArr0, ss, totalloss1 / 8 * times);
			} 
		}
		else if(has0)//只有buy单亏 
		{
			if(max0 - Ind.ask > BCStep * BasePoint) 
			{
				int times = (max0 - Ind.ask) / BasePoint / BCStep;				
				Add2StreamOfDC(LostArr0, ss, totalloss1 / 16 * times);
			} 
		} 
		else if(has1)//只有sell单亏 
		{
			if(Ind.Trend == 1 && max0 - Ind.ask > BCStep * BasePoint) 
			{
				int times = (max0 - Ind.ask) / BasePoint / BCStep;				
				Add2StreamOfDC(LostArr0, ss, totalloss1 / 16 * times);
			} 
		}		
		
		wstring strtemp = ss.str();
		const wchar_t* rtn = strtemp.c_str();
    	return(rtn);
	      
	};
	const wchar_t* ModifyOrder()
	{
		wostringstream ss; 
		
		if(Orders.size() > 0) 
		{	
			vector<OrderInfo> ArrToModify;		
			
			vector<OrderInfo>::iterator iter; 
		    for (iter = Orders.begin(); iter != Orders.end(); iter++)  
		    {  
		    	OrderInfo order = (OrderInfo)*iter;
							  
		        double openprice = order.OpenPrice;
		        int cmd = order.CMD; 
				double lots = order.Lots; 
				long ticket = order.Ticket;

			    if (cmd == 0 && Ind.bid < openprice || cmd == 1 && Ind.ask > openprice)
				{
				    continue;
				}	
			
			   	double oldstoploss = order.StopLoss;
			   	double stoploss = 0;
			   	double takeprofit = order.TakeProfit;   	
			   	double adjustPoint = (Ind.high_h4 - Ind.low_h4) / BasePoint; //GetBoFu(PERIOD_H4, 1);	
			   	if(adjustPoint < MinMovePoint) 
			   	    adjustPoint = MinMovePoint;	
			   	else if(adjustPoint > MaxMovePoint)
			   	    adjustPoint = MaxMovePoint;
				   	   	
				adjustPoint = adjustPoint * BasePoint;
			    	
			    bool tobemodify = false; 
				if (cmd == 0)
				{
				    stoploss = Ind.bid - adjustPoint;			
					if (stoploss > openprice && stoploss > oldstoploss) 
					    tobemodify = true;	
				}
				else
				{
					stoploss = Ind.ask + adjustPoint;				
					if (stoploss < openprice && stoploss < oldstoploss) 
					    tobemodify = true;		
				}	
	
				if(tobemodify)
				{
					OrderInfo order;
					order.Ticket = ticket;
					order.CMD = cmd;
					order.OpenPrice = openprice;
					order.StopLoss = stoploss;
					order.TakeProfit = takeprofit;
					
					ArrToModify.push_back(order);
			    }   
			}	
					
			if(ArrToModify.size() > 0)					     
			{	
				vector<OrderInfo>::iterator iter; 
			    for (iter = ArrToModify.begin(); iter != ArrToModify.end(); iter++)  
			    {  
			    	OrderInfo order = (OrderInfo)*iter;			  
		        	ss << order.CMD;
		        	ss << ",";  
		        	ss << order.Ticket;
		        	ss << ",";        	      	
		        	ss << order.OpenPrice;
		        	ss << ",";        	
		        	ss << order.StopLoss;
		        	ss << ",";        	
		        	ss << order.TakeProfit;
		        	
					if(iter != ArrToModify.end()- 1) ss << ";";		     		        	
				}  
			}	  
		}  
		wstring strtemp = ss.str();
		const wchar_t* rtn = strtemp.c_str();
    	return(rtn);
		
	};
	
	void AddConfig(int rsiLimit,int division11,int wprOpen11,int maMargin4,int minMovePoint,int maxMovePoint,
		double percentage4hedging,int duichongPoint,int digits, double basePoint, int maxSL, double baseLots, double bcRate, int bcStep)
	{
		RSILimit = rsiLimit;
		Division11 = division11;
		WprOpen11 = wprOpen11;
		MAMargin4 = maMargin4;
		MinMovePoint = minMovePoint;
		MaxMovePoint = maxMovePoint;
		Percentage4hedging = percentage4hedging;
		DuichongPoint = duichongPoint;
		Digits = digits;		
		BasePoint = basePoint;
		MaxSL = maxSL;
		BaseLots = baseLots;
		BCRate = bcRate;
		BCStep = bcStep;
	}
	
	CTrade(){};
	~CTrade()
	{
		Orders.clear();
		HisOrders.clear();
	};
};

CTrade trade;

/* get the trade signal, 0:buy, 1:sell*/
_DLLAPI int __stdcall GetCommand(int &magic, int &magicnumber, double &lots, int maxcount = 0, int frame = 0)
{
	if(IsNotExpired("2018-12-20"))
	{
		if(magic == 0) return -1;
		
		try
		{
			return trade.GetCommand(magic, magicnumber, lots, maxcount, frame);
		}
		catch(...)
		{
			return(-1);
		}
	}
		
	else
		return -999;	
};
/* add a order into DLL */
_DLLAPI void __stdcall AddOrder(int historyFlag, long ticket, int cmd, double lots, double open, double close, double stoploss, double takeprofit, int magic)
{	
	try
	{
		trade.AddOrder(historyFlag, ticket, cmd, lots, open, close, stoploss, takeprofit, magic);
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
		trade.Ind.BuildIndicator(arr);	
	}
	catch(...)
	{		
	}	
};
/* add configs */
_DLLAPI void __stdcall AddConfig(int rsiLimit,int division11,int wprOpen11,int maMargin4,int minMovePoint,int maxMovePoint,
		double percentage4hedging,int duichongPoint,int digits,double basePoint, int maxSL, double baseLots, double bcRate, int bcStep)
{
	try
	{
		trade.AddConfig(rsiLimit, division11, wprOpen11, maMargin4, minMovePoint, maxMovePoint, percentage4hedging, duichongPoint, digits, basePoint, maxSL, baseLots, bcRate, bcStep);	
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
		if(historyFlag == 1)
			trade.HisOrders.clear();
		else
			trade.Orders.clear();
	}
	catch(...)
	{		
	}	
};
/* dui chong */
_DLLAPI const wchar_t* __stdcall CloseLossedOrder()
{
	try
	{
		return(trade.Duichong());
	}
	catch(...)
	{		
		return(NULL);
	}	
	
};
/* modify order */
_DLLAPI const wchar_t* __stdcall ModifyOrder()
{
	try
	{
		return(trade.ModifyOrder());
	}
	catch(...)
	{		
		return(NULL);
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
	cout << exp2(0);
	return(0);
	
	string sEndTime ="2018-12-9";
	if(IsNotExpired(sEndTime))
		cout << "有效日期";
	else
		cout << "时间过期";	
	

    
	return(0);
}
