//+------------------------------------------------------------------+
//|                                                       Gemini.mq4 |
//|                                      Copyright 2017, Wei Haikuan |
//|                    https://www.mql5.com/zh/users/weihaikuan/blog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, GEMINI"
#property link      "https://www.mql5.com/zh/users/weihaikuan/blog"
#property version   "1.0"
#property description ""
#property description ""
#property strict

#include <Gemini-BL.mqh>

extern double Blance_Rate = 0.5; //Balance Rate(0.3=30%)
extern bool UseMM = true; //Use Compound?
extern double MM = 0.05; //Compound Rate
extern int MinSL = 300;
extern int MaxSL = 400;
extern int Frequency = 5; //Modify Frequency
extern int RSILimit = 70; //RSI Limit

extern string str999 = "$$$$$$$$$$$$$$$$$$";  //TRADE 999 >>>>>>>>>>>>>>
extern bool UseTrade999 = true;     //......Apply?
extern string SendConfig999 = "0.02,3,600,250;0.01,1,600,500.01,2,600,90;0.01,2,600,130"; //Config(lots,maxorder,sendspan,patchpoint)

extern string str11 = "$$$$$$$$$$$$$$$$$$";  //TRADE 11 >>>>>>>>>>>>>>
extern bool UseTrade11 = false;     //......Apply?
extern string SendConfig11 = "0.02,3,3600;0.01,1,7200"; //Config(lots,maxorder,sendspan)
extern int Division11 = 25; //......Division Line
extern int WprOpen11 = 6; //......WPR Margen (Open)

extern string str12 = "$$$$$$$$$$$$$$$$$$";  //TRADE 12 ----------------------------------------------------
extern bool UseTrade12 = true;     //......Apply?
extern string SendConfig12 = "0.01,1,300;0.02,1,900"; //Config(lots,maxorder,sendspan)
extern int Division12 = 25; //......Division Line
extern int WprOpen12 = 6; //......WPR Margen (Open)

extern string str21 = "****************************";  //TRADE 21 >>>>>>>>>>>>>>
extern bool UseTrade21 = false;     //......Apply?
extern string SendConfig21 = "0.01,2,300;0.02,2,900"; //Config(lots,maxorder,sendspan)
extern int From21 = 10; //......From (MA)
extern int To21 = 20;   //......To (MA)

extern string str22 = "****************************";  //TRADE 22 >>>>>>>>>>>>>>
extern bool UseTrade22 = false;     //......Apply?
extern string SendConfig22 = "0.01,1,300;0.02,1,900"; //Config(lots,maxorder,sendspan)
extern int Division22 = 30; //......Division Line
extern int MAMargin22 = 50;   //......ma_H4_14 Margin

extern string str3 = "****************************"; //TRADE 3 >>>>>>>>>>>>>>
extern bool UseTrade3 = false; //......Apply?
extern string SendConfig3 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin3 = 150;   //......MA-700 Margin


extern string str4 = "****************************"; //TRADE 4 >>>>>>>>>>>>>>
extern bool UseTrade4 = false; //......Apply?
extern string SendConfig4 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin4 = 150;   //......MA-700 Margin

extern string str5 = "****************************"; //TRADE 5 >>>>>>>>>>>>>>
extern bool UseTrade5 = false; //......Apply?
extern string SendConfig5 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin5 = 150;   //......MA-700 Margin

extern string str6 = "****************************";  //TRADE 6 >>>>>>>>>>>>>>
extern bool UseTrade6 = false;     //......Apply?
extern string SendConfig6 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int WprOpen6 = 6; //......WPR Margen (Open)
extern int Division6 = 55; //......Division Line
 
CIndicator *g_indicator;
BaseStrategy *Stg[];

void AssembleStrategy(int magic)
{	
	string sendConfig;
	
	switch(magic)
	{
		case 11:
			sendConfig = SendConfig11;
			break;
		case 12:
			sendConfig = SendConfig12;
			break;
		case 21:
			sendConfig = SendConfig21;
			break;
		case 22:
			sendConfig = SendConfig22;
			break;
		case 3:
			sendConfig = SendConfig3;
			break;
		case 4:
			sendConfig = SendConfig4;
			break;
		case 5:
			sendConfig = SendConfig5;
			break;
		case 6:
			sendConfig = SendConfig6;
			break;
		case 999:
			sendConfig = SendConfig999;
			break;
			
	}
	
	string result1[];
	string result2[];
	int k = GetSendConfigs(sendConfig,result1,";");
        
	for(int i=0;i<k;i++)
	{
		double lots;
	    int maxOrder, sendSpan, patchPoint;
	    
		int j = GetSendConfigs(result1[i], result2, ",");
		if(j==3 || j==4)
		{			
			lots = StringToDouble(result2[0]); maxOrder = StringToInteger(result2[1]); sendSpan = StringToInteger(result2[2]); 
			if (j==4)
				patchPoint = StringToInteger(result2[3]);
			else
				patchPoint = 0;
		}
		else
		{
			Print("Error: Trade", magic, " config is not correct! the EA can not be applied."); return;
		}
		int magicNumber = magic*10+i;
		Strategy111 *stg = new Strategy111(magic, magicNumber);
		int size=ArraySize(Stg)+1;
		ArrayResize(Stg,size);
		Stg[size-1]=stg;	
	    
		switch(magic)
		{
			case 11:
				stg.WPROpen = WprOpen11;
				stg.Division = Division11;
				break;
			case 12:
				stg.WPROpen = WprOpen12;
				stg.Division = Division12;
				break;
			case 21:
				stg.From21 = From21;
				stg.To21 = To21;
				break;
			case 22:
				stg.MAMargin = MAMargin22;
				stg.Division = Division22;
				break;
			case 3:
				stg.MAMargin = MAMargin3;
				break;
			case 4:
				stg.MAMargin = MAMargin4;
				break;
			case 5:
				stg.MAMargin = MAMargin5;
				break;
			case 6:
				stg.WPROpen = WprOpen6;
				stg.Division = Division6;
				break;		
			case 999:
				stg.PatchPoint = patchPoint;		
		}
		
		stg.Lots = lots;
		stg.MaxOrderCount = maxOrder;
		stg.SendSpan = sendSpan;
		stg.MaxStopLoss = MaxSL;
		stg.MinStopLoss = MinSL;
		stg.RSILimit = RSILimit;
		
		BaseStrategy::TotalOrderLimit += maxOrder;
	}   
	
}

int OnInit()
{
    EventSetTimer(300);
    //add(1); return;    

	BaseStrategy::TotalOrderLimit = 0;	
	ArrayResize(Stg,0);
	
    if (UseTrade11) AssembleStrategy(11);
	if (UseTrade12) AssembleStrategy(12);
	if (UseTrade21) AssembleStrategy(21);
	if (UseTrade22) AssembleStrategy(22);
	if (UseTrade3) AssembleStrategy(3);
	if (UseTrade4) AssembleStrategy(4);
    if (UseTrade5) AssembleStrategy(5);
	if (UseTrade6) AssembleStrategy(6);	
	if (UseTrade999) AssembleStrategy(999);
    
    //set up MM
    BaseStrategy::Blance_Rate = Blance_Rate;
    BaseStrategy::UseMM = UseMM;
    BaseStrategy::MM = MM;
     
    if(ArraySize(Stg)==0)
    {
        Print("Error: You must select at least 1 strategy!");
        return(INIT_FAILED);
    } 
	else
	{
		Print("lots=", Stg[0].GetLots(0));				
	}	
	
	LastModifyTime = 0;
    return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
    //DisplaySummay();
    delete g_indicator;
    for(int i=0; i < ArraySize(Stg); i++)
    {
        delete Stg[i];        
    }
    ArrayResize(Stg, 0);
}

int LastModifyTime; 
void OnTick()
{
	if (TimeCurrent() < LastModifyTime + Frequency) return; //Frequency秒
    g_indicator = CollectIndicators();
	
	//1. start to close or modify orders
	for (int i = 0; i < OrdersTotal(); i++)
	{
		if (!SelectOrder(i)) continue;
		
		ModifyOrder(OrderType());				
	} 	
	
	//2. start to send orders
    for(int i=0;i<ArraySize(Stg);i++)
    {
        Stg[i].SendOrder(g_indicator);
    }	
	
    delete g_indicator;
	
	LastModifyTime = TimeCurrent();
}


void OnTimer()
{
	//Print("OnTimer");    
}
  

//+------------------------------------------------------------------+
void add(int magic)
{
    double lots = 0.01;
    int StopLoss = 1000;
    int TakeProfit = 1000;
  
    double price = NormalizeDouble(Ask, Digits);
    double	stoploss = price - StopLoss * gl_basePoint;
	double takeprofit = price + TakeProfit * gl_basePoint;		
		
    OrderSend(Symbol(), 0, lots, price, 30, stoploss, takeprofit, IntegerToString(magic), magic, 0, clrRed);
    
    price = NormalizeDouble(Bid, Digits);
    stoploss = price + StopLoss * gl_basePoint;
	takeprofit = price - TakeProfit * gl_basePoint;		
		
    OrderSend(Symbol(), 1, lots, price, 30, stoploss, takeprofit, IntegerToString(magic), magic, 0, clrRed);     
}

int GetSendConfigs(string to_split,string &result[], string sep)
{
    ArrayResize(result,0);
 
    ushort u_sep = StringGetCharacter(sep,0); 

    int k=StringSplit(to_split,u_sep,result); 

    return k;
}

bool ModifyOrder(int cmd)
{
    if(TimeCurrent() - OrderOpenTime() > 864000) 
    {
        //CloseOrder(cmd);
        //return true;
    }
    
   	int ticket = OrderTicket();   	
   	double openprice = OrderOpenPrice();
   	double oldstoploss = OrderStopLoss();
   	double stoploss = 0;
   	double takeprofit = OrderTakeProfit();
   	color clr = clrBlue;
   	
    bool tobemodify = false; 
    
    double adjustPoint = GetBoFu(PERIOD_H4, 1);	
	if(adjustPoint < 20) adjustPoint = 20;
	if(adjustPoint > 50) adjustPoint = 50;	
	
	adjustPoint = adjustPoint * gl_basePoint;  
	 
    if (cmd == OP_BUY)
	{
		stoploss = NormalizeDouble(Bid - adjustPoint, Digits);			
		if (stoploss > openprice && stoploss > oldstoploss && IsValidSL(cmd, stoploss)) tobemodify = true;				
	}
	else
	{
	    clr = clrRed;
		stoploss = NormalizeDouble(Ask + adjustPoint, Digits);			
		if (stoploss < openprice && stoploss < oldstoploss && IsValidSL(cmd, stoploss)) tobemodify = true;		
	}	
	
	bool rtn = false;
	if(tobemodify)
	{
        if(OrderMagicNumber() >= 9990)
        {
            int ticket999 = ticket;
			double profit999;
			double profit999total;
			int cmd999 = cmd;
			if (cmd999 == 0)
			{
			    if(oldstoploss < OrderOpenPrice())
			        profit999 = stoploss - OrderOpenPrice();
			    else
			        profit999 = stoploss - oldstoploss;
			    
			    profit999total = stoploss - OrderOpenPrice();
			}
			else
			{
			    if(oldstoploss > OrderOpenPrice())
				    profit999 = OrderOpenPrice() - stoploss;
				else
				    profit999 = oldstoploss - stoploss;
				
				profit999total = OrderOpenPrice() - stoploss;
			}
				
			if(profit999 > 0)
			{			    
			    int ticket0 = -1;
			    double lots0 = 0;
			    double price0 = 0;
			    double lossed = 0;
			  
			    for (int j = OrdersTotal() - 1; j >=0; j--)
			    {			  
			        if (!SelectOrder(j)) continue;      
			        if(OrderType() == cmd999 
			            && (cmd999 == 0 && OrderOpenPrice() > price0 || cmd999 == 1 && OrderOpenPrice() < price0))
			        {
			            price0 = OrderOpenPrice();
			            ticket0 = OrderTicket();
			            lots0 = OrderLots();
			            if (cmd999 == 0)
            			    lossed = OrderOpenPrice() - Ask;
            			else
            				lossed = Ask - OrderOpenPrice();
			        }
			    }
			    if(ticket0 != ticket999)
			    {
	       			if (lossed > 0)
        			{   
        			    int step = 5;
        			    int usedProfit;
        			    Print("profit99=", profit999, ",profit999total=",profit999total);
        			    if(profit999 == profit999total)
        			    {
        			        usedProfit = profit999 / gl_basePoint;        			        
        			    }
        			    else
        			    {
        			        usedProfit = (profit999total - profit999) / gl_basePoint;
        			        usedProfit = usedProfit % step + profit999 / gl_basePoint;
        			    }
        			    Print("usedProfit1=", usedProfit);
        			    usedProfit = usedProfit / step;
        			    usedProfit = usedProfit * step;
        			    Print("usedProfit2=", usedProfit, ",lossed=",lossed);
        			    				
    			        double lots4close = usedProfit / 2 /(lossed/gl_basePoint) * lots0;
    			        if(lots4close > 0) lots4close = NormalizeDouble(lots4close, 2);
    			        if(lots4close > lots0) lots4close = lots0;
    			        
    			        double minlots = MarketInfo(Symbol(), MODE_MINLOT);
    			        if(lots4close > minlots)
    			        {
    			            CloseOrder(cmd999, ticket0, lots4close);
    			            Comment("CLOSE ORDER: ", ticket0, " Lots:", lots4close);
    			            Print("CLOSE ORDER: ", ticket0, " Lots:", lots4close);    			            
    			        }
    			    }    
			    }
			}		
        }	
        
        if (OrderModify(ticket, openprice, stoploss, takeprofit, 0, clr))
        {
            rtn = true;        
            Comment("\r\n adjustPoint=", adjustPoint/gl_basePoint);
        }
        else
        {
            Print("Sell单(",OrderTicket(),")修改失败,错误原因："+iGetErrorInfo(GetLastError()));	
            return(false);
        }
    }
    
	return (rtn);
};

bool CloseOrder(int cmd)
{    	    
    bool rtn = false;
		
    if (cmd == OP_BUY)
		rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 30, clrBlue);
	else
		rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 30, clrRed);
	
	if(!rtn) Print("订单(",OrderTicket(),")关闭失败,错误原因："+iGetErrorInfo(GetLastError()));	       	
	
	return(rtn);
};

bool CloseOrder(int cmd, int ticket, double lots)
{    	    
    bool rtn = false;
		
    if (cmd == OP_BUY)
		rtn = OrderClose(ticket, lots, NormalizeDouble(Bid, Digits), 30, clrBlue);
	else
		rtn = OrderClose(ticket, lots, NormalizeDouble(Ask, Digits), 30, clrRed);
	
	if(!rtn) Print("订单(",OrderTicket(),")关闭失败,错误原因："+iGetErrorInfo(GetLastError()));	       	
	
	return(rtn);
};
