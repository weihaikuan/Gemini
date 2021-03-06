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
extern bool UseMM = false; //Use Compound?
extern double MM = 0.01; //Compound Rate

extern string str999 = "$$$$$$$$$$$$$$$$$$";  //TRADE 999 >>>>>>>>>>>>>>
extern bool UseTrade999 = false;     //......Apply?
extern int TakeProfit999 = 1000;    //......TakeProfit
extern int StopLoss999 = 100;      //......StopLoss
extern int BackPoint999 = 50; //......Back 

extern string str11 = ">>>>>>>>>>>>>>";  //TRADE 11 >>>>>>>>>>>>>>
extern bool UseTrade11 = false;     //......Apply?
extern string SendConfig11 = "0.01,2,300,5;0.02,2,900,5"; //Config(lots,maxorder,sendspan,modifyspan)
extern int TakeProfit11 = 300;    //......TakeProfit
extern int StopLoss11 = 300;      //......StopLoss
extern int BackPoint11 = 20; //......Back Point
extern int Division11 = 25; //......Division Line
extern int WprOpen11 = 6; //......WPR Margen (Open)

extern string str12 = ">>>>>>>>>>>>>>";  //TRADE 12 >>>>>>>>>>>>>>
extern bool UseTrade12 = false;     //......Apply?
extern string SendConfig12 = "0.01,2,300,5;0.02,2,900,5"; //Config(lots,maxorder,sendspan,modifyspan)
extern int TakeProfit12 = 300;    //......TakeProfit
extern int StopLoss12 = 300;      //......StopLoss
extern int BackPoint12 = 20; //......Back Point
extern int Division12 = 25; //......Division Line
extern int WprOpen12 = 6; //......WPR Margen (Open)

extern string str21 = ">>>>>>>>>>>>>>";  //TRADE 21 >>>>>>>>>>>>>>
extern bool UseTrade21 = false;     //......Apply?
extern string SendConfig21 = "0.01,2,300,5;0.02,2,900,5"; //Config(lots,maxorder,sendspan,modifyspan)
extern int TakeProfit21 = 100;    //......TakeProfit
//extern int StopLoss21 = 0;      //......StopLoss
extern int BackPoint21 = 20; //......Back Point
extern int Division21 = 25; //......Division Line
extern int MAMargin21 = 20;   //......ma_H4_14 Margin

extern string str22 = ">>>>>>>>>>>>>>";  //TRADE 22 >>>>>>>>>>>>>>
extern bool UseTrade22 = false;     //......Apply?
extern string SendConfig22 = "0.01,2,300,5;0.02,2,900,5"; //Config(lots,maxorder,sendspan,modifyspan)
extern int TakeProfit22 = 1000;    //......TakeProfit
//extern int StopLoss22 = 0;      //......StopLoss
extern int BackPoint22 = 100; //......Back Point
extern int Division22 = 30; //......Division Line
extern int MAMargin22 = 50;   //......ma_H4_14 Margin

extern string str3 = ">>>>>>>>>>>>>>"; //TRADE 3 >>>>>>>>>>>>>>
extern bool UseTrade3 = false; //......Apply?
extern string SendConfig3 = "0.01,2,300,5;0.02,2,900,5";// Config(lots,maxorder,sendspan,modifyspan)
extern int TakeProfit3 = 160; //......TakeProfit
extern int StopLoss3 = 350; //......StopLoss
extern int BackPoint3 = 20; //......Back Point
extern int MAMargin3 = 150;   //......MA-700 Margin


extern string str4 = "$$$$$$$$$$$$$$$$$$"; //TRADE 4 >>>>>>>>>>>>>>
extern bool UseTrade4 = false; //......Apply?
extern string SendConfig4 = "0.01,2,300,5;0.02,2,900,5";// Config(lots,maxorder,sendspan,modifyspan)
extern int TakeProfit4 = 160; //......TakeProfit
extern int StopLoss4 = 350; //......StopLoss
extern int BackPoint4 = 20; //......Back Point
extern int MAMargin4 = 150;   //......MA-700 Margin

extern string str5 = ">>>>>>>>>>>>>>"; //TRADE 5 >>>>>>>>>>>>>>
extern bool UseTrade5 = false; //......Apply?
extern string SendConfig5 = "0.01,2,300,5;0.02,2,900,5";// Config(lots,maxorder,sendspan,modifyspan)
extern int TakeProfit5 = 160; //......TakeProfit
extern int StopLoss5 = 350; //......StopLoss
extern int BackPoint5 = 20; //......Back Point
extern int MAMargin5 = 150;   //......MA-700 Margin

extern string str6 = ">>>>>>>>>>>>>>";  //TRADE 6 >>>>>>>>>>>>>>
extern bool UseTrade6 = false;     //......Apply?
extern string SendConfig6 = "0.01,2,300,5;0.02,2,900,5";// Config(lots,maxorder,sendspan,modifyspan)
extern int TakeProfit6 = 300;    //......TakeProfit
extern int StopLoss6 = 300;      //......StopLoss
extern int BackPoint6 = 20; //......Back Point
extern int WprOpen6 = 6; //......WPR Margen (Open)
extern int Division6 = 55; //......Division Line


 
Strategy999 *stg999 = NULL;
CIndicator *g_indicator;
BaseStrategy *Stg[];

int OnInit()
{
    EventSetTimer(gl_doubleLotsSpan);
    //add(1); return;    
    
    int size=0;   
    string sendConfig;
    string result1[];
    string result2[];
    double lots;
    int maxorder, sendSpan, modifySpan;
 
	//reset to 0
	BaseStrategy::TotalOrderLimit = 0;	
    if (UseTrade11) 
    {
        sendConfig = SendConfig11;
        
        int k = GetSendConfigs(sendConfig,result1,";");
        
        for(int i=0;i<k;i++)
        {
            int j = GetSendConfigs(result1[i], result2, ",");
            if(j==4)
            {
                lots = StringToDouble(result2[0]); maxorder = StringToInteger(result2[1]); sendSpan = StringToInteger(result2[2]); modifySpan = StringToInteger(result2[3]);
                Print(lots,",",maxorder,",",sendSpan,",",modifySpan);
                size=ArraySize(Stg)+1;
                ArrayResize(Stg,size);
                Stg[size-1]=new Strategy11(maxorder,sendSpan,modifySpan,lots,StopLoss11,TakeProfit11,BackPoint11,WprOpen11,Division11);
                BaseStrategy::TotalOrderLimit += maxorder;
            }
            else
            {
                Print("Error: Trade11 config is not correct! the EA can not be applied.");
                return(INIT_FAILED);
            }
        }   
        
    }  
    if (UseTrade12) 
    {
        sendConfig = SendConfig12;
        
        int k = GetSendConfigs(sendConfig,result1,";");
        
        for(int i=0;i<k;i++)
        {
            int j = GetSendConfigs(result1[i], result2, ",");
            if(j==4)
            {
                lots = StringToDouble(result2[0]); maxorder = StringToInteger(result2[1]); sendSpan = StringToInteger(result2[2]); modifySpan = StringToInteger(result2[3]);
                size=ArraySize(Stg)+1;
                ArrayResize(Stg,size);
                Stg[size-1]=new Strategy12(maxorder,sendSpan,modifySpan,lots,StopLoss12,TakeProfit12,BackPoint12,WprOpen12,Division12);
                BaseStrategy::TotalOrderLimit += maxorder;
            }
            else
            {
                Print("Error: Trade12 config is not correct! the EA can not be applied.");
                return(INIT_FAILED);
            }
        }   
        
    } 
    
    if (UseTrade21) 
    {
        sendConfig = SendConfig21;
        
        int k = GetSendConfigs(sendConfig,result1,";");
        
        for(int i=0;i<k;i++)
        {
            int j = GetSendConfigs(result1[i], result2, ",");
            if(j==4)
            {
                lots = StringToDouble(result2[0]); maxorder = StringToInteger(result2[1]); sendSpan = StringToInteger(result2[2]); modifySpan = StringToInteger(result2[3]);
                Print(lots,",",maxorder,",",sendSpan,",",modifySpan);
                size=ArraySize(Stg)+1;
                ArrayResize(Stg,size);
                Stg[size-1]=new Strategy21(maxorder,sendSpan,modifySpan,lots,0,TakeProfit21,BackPoint21,MAMargin21,Division21);
                BaseStrategy::TotalOrderLimit += maxorder;
            }
            else
            {
                Print("Error: Trade21 config is not correct! the EA can not be applied.");
                return(INIT_FAILED);
            }
        }   
        
    }  
    
    if (UseTrade22) 
    {
        sendConfig = SendConfig22;
        
        int k = GetSendConfigs(sendConfig,result1,";");
        
        for(int i=0;i<k;i++)
        {
            int j = GetSendConfigs(result1[i], result2, ",");
            if(j==4)
            {
                lots = StringToDouble(result2[0]); maxorder = StringToInteger(result2[1]); sendSpan = StringToInteger(result2[2]); modifySpan = StringToInteger(result2[3]);
                Print(lots,",",maxorder,",",sendSpan,",",modifySpan);
                size=ArraySize(Stg)+1;
                ArrayResize(Stg,size);
                Stg[size-1]=new Strategy22(maxorder,sendSpan,modifySpan,lots,0,TakeProfit22,BackPoint22,MAMargin22,Division22);
                BaseStrategy::TotalOrderLimit += maxorder;
            }
            else
            {
                Print("Error: Trade22 config is not correct! the EA can not be applied.");
                return(INIT_FAILED);
            }
        }   
        
    }  
    if (UseTrade3) 
    {
        sendConfig = SendConfig3;
        
        int k = GetSendConfigs(sendConfig,result1,";");
        
        for(int i=0;i<k;i++)
        {
            int j = GetSendConfigs(result1[i], result2, ",");
            if(j==4)
            {
                lots = StringToDouble(result2[0]); maxorder = StringToInteger(result2[1]); sendSpan = StringToInteger(result2[2]); modifySpan = StringToInteger(result2[3]);
                Print(lots,",",maxorder,",",sendSpan,",",modifySpan);
                size=ArraySize(Stg)+1;
                ArrayResize(Stg,size);
                Stg[size-1]=new Strategy3(maxorder,sendSpan,modifySpan,lots,StopLoss3,TakeProfit3,BackPoint3,MAMargin3);
                BaseStrategy::TotalOrderLimit += maxorder;
            }
            else
            {
                Print("Error: Trade3 config is not correct! the EA can not be applied.");
                return(INIT_FAILED);
            }
        }   
        
    }  
    if (UseTrade4) 
    {
        sendConfig = SendConfig4;
        
        int k = GetSendConfigs(sendConfig,result1,";");
        
        for(int i=0;i<k;i++)
        {
            int j = GetSendConfigs(result1[i], result2, ",");
            if(j==4)
            {
                lots = StringToDouble(result2[0]); maxorder = StringToInteger(result2[1]); sendSpan = StringToInteger(result2[2]); modifySpan = StringToInteger(result2[3]);
                Print(lots,",",maxorder,",",sendSpan,",",modifySpan);
                size=ArraySize(Stg)+1;
                ArrayResize(Stg,size);
                Stg[size-1]=new Strategy4(maxorder,sendSpan,modifySpan,lots,StopLoss4,TakeProfit4,BackPoint4,MAMargin4);
                BaseStrategy::TotalOrderLimit += maxorder;
            }
            else
            {
                Print("Error: Trade4 config is not correct! the EA can not be applied.");
                return(INIT_FAILED);
            }
        }   
        
    }  
    
    if (UseTrade5) 
    {
        sendConfig = SendConfig5;
        
        int k = GetSendConfigs(sendConfig,result1,";");
        
        for(int i=0;i<k;i++)
        {
            int j = GetSendConfigs(result1[i], result2, ",");
            if(j==4)
            {
                lots = StringToDouble(result2[0]); maxorder = StringToInteger(result2[1]); sendSpan = StringToInteger(result2[2]); modifySpan = StringToInteger(result2[3]);
                Print(lots,",",maxorder,",",sendSpan,",",modifySpan);
                size=ArraySize(Stg)+1;
                ArrayResize(Stg,size);
                Stg[size-1]=new Strategy5(maxorder,sendSpan,modifySpan,lots,StopLoss5,TakeProfit5,BackPoint5,MAMargin5);
                BaseStrategy::TotalOrderLimit += maxorder;
            }
            else
            {
                Print("Error: Trade5 config is not correct! the EA can not be applied.");
                return(INIT_FAILED);
            }
        }   
        
    }  
    
    if (UseTrade6) 
    {
        sendConfig = SendConfig6;
        
        int k = GetSendConfigs(sendConfig,result1,";");
        
        for(int i=0;i<k;i++)
        {
            int j = GetSendConfigs(result1[i], result2, ",");
            if(j==4)
            {
                lots = StringToDouble(result2[0]); maxorder = StringToInteger(result2[1]); sendSpan = StringToInteger(result2[2]); modifySpan = StringToInteger(result2[3]);
                Print(lots,",",maxorder,",",sendSpan,",",modifySpan);
                size=ArraySize(Stg)+1;
                ArrayResize(Stg,size);
                Stg[size-1]=new Strategy6(maxorder,sendSpan,modifySpan,lots,StopLoss6,TakeProfit6,BackPoint6,WprOpen6,Division6);
                BaseStrategy::TotalOrderLimit += maxorder;
            }
            else
            {
                Print("Error: Trade6 config is not correct! the EA can not be applied.");
                return(INIT_FAILED);
            }
        }   
        
    }  
     
    if(ArraySize(Stg)==0)
    {
        Print("Error: You must select at least 1 strategy!");
        return(INIT_FAILED);
    } 
	else
		Print("lots=", Stg[0].GetLots());
	
	//Use strategy 999
    if (UseTrade999)
    {
    	stg999 = new Strategy999(0,1,StopLoss999,TakeProfit999, BackPoint999);
    }
    
	//Refresh orders for all strategy
    for(int i=0;i<ArraySize(Stg);i++)
     {
        Stg[i].RefreshOrders();
     }
	
	//set up MM
    BaseStrategy::Blance_Rate = Blance_Rate;
    BaseStrategy::UseMM = UseMM;
    BaseStrategy::MM = MM;
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
    delete stg999;
}

void OnTick()
{
    g_indicator = CollectIndicators();
	
	//1. start to close or modify orders
    BaseStrategy *strategy = NULL;        	
    for(int j=0;j<ArraySize(Stg);j++)
     {
        strategy = Stg[j];
        int iMagic = strategy.MagicNumber;
        bool closeBuy = strategy.TobeClosed(OP_BUY, g_indicator);
        bool closeSell = strategy.TobeClosed(OP_SELL, g_indicator);
        
        int i;
        for (i = 0; i < OrdersTotal(); i++)
    	{
    		if (!SelectOrder(i)) continue;
    		if(OrderMagicNumber() != iMagic) continue;
    		
			bool closed = false;
    		if(closeBuy && OrderType() == OP_BUY) closed = strategy.CloseOrder(0);   
    		if(closeSell && OrderType() == OP_SELL) closed = strategy.CloseOrder(1); 
			
			if(!closed) strategy.ModifyOrder(OrderType(), g_indicator);			
    	}    
    		
     } 
    
	//2. start to send orders
    for(int i=0;i<ArraySize(Stg);i++)
     {
        Stg[i].SendOrder(g_indicator);
     }
	
	//3. check if need to double lots via strategy 999
	if(stg999 != NULL)
	{
		for (int i = 0; i < OrdersTotal(); i++)
    	{
    		if (!SelectOrder(i)) continue;
    		if(OrderMagicNumber() != magic999) continue;
    		stg999.ModifyOrder(OrderType(), g_indicator);
    	}     
		
		if (TimeCurrent() >= BaseStrategy::LastDoubleLotsTime + gl_doubleLotsSpan)
		{		    
		    stg999.SendOrder();	    
		    BaseStrategy::LastDoubleLotsTime = TimeCurrent();
		}
	}
	
    delete g_indicator;
}


void OnTimer()
{
	//Print("OnTimer");    
}
  
string StatsStrategy(BaseStrategy *stg)
{
    int ordercount = 0;
    int buycount = 0;
    int cellcount = 0;
    double profit = 0;
    for(int i=0; i<ArraySize(stg.OrdersHistroy); i++)
    {
        if(stg.OrdersHistroy[i].CMD == OP_BUY) 
            buycount++;
        else
            cellcount++;
        
        profit += stg.OrdersHistroy[i].Profit;
    }
    
    return (StringConcatenate("策略", stg.MagicNumber,": 买单数：", buycount, ", 卖单数：", cellcount, ", 盈利：", DoubleToString(NormalizeDouble(profit, 4),2)));
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

void DisplaySummay()
{
    int x = 500; int y = 0; int size = 8; color clr = clrRed;

    string Text = "";
    //Text = StringConcatenate("当前时间：", TimeHour(TimeLocal()),":", TimeMinute(TimeLocal()),":", TimeSeconds(TimeLocal()));
    //iDisplayInfo("TradeInfo",Text,CORNER_LEFT_UPPER,x,y,size,"微软雅黑",clrBlue);
    
    for(int i=0;i<ArraySize(Stg);i++)
     {
        Text = StatsStrategy(Stg[i]); y += 25; iDisplayInfo(Stg[i].MagicNumber,Text,CORNER_LEFT_UPPER,x,y,size,"微软雅黑",clr);
     }
     
}

int GetSendConfigs(string to_split,string &result[], string sep)
{
    ArrayResize(result,0);
 
    ushort u_sep = StringGetCharacter(sep,0); 

    int k=StringSplit(to_split,u_sep,result); 

    return k;
}
    