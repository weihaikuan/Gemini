//+------------------------------------------------------------------+
//|                                                       Gemini.mq4 |
//|                                      Copyright 2017, Wei Haikuan |
//|                    https://www.mql5.com/zh/users/weihaikuan/blog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, GEMINI"
#property link      "https://www.mql5.com/zh/users/weihaikuan/blog"
#property version   "beta 1.0.0"
#property description ""
#property description ""
#property strict

#include <Gemini-BL.mqh>

extern double Blance_Rate = 0.5; //Balance Rate(0.3=30%)
extern bool UseMM = true; //Use Compound?
extern double MM = 0.01; //Compound Rate

extern string str999 = "$$$$$$$$$$$$$$$$$$";  //TRADE 999 >>>>>>>>>>>>>>
extern bool UseTrade999 = true;     //......Apply?
extern int TakeProfit999 = 1000;    //......TakeProfit
extern int StopLoss999 = 100;      //......StopLoss
extern int BackPoint999 = 50; //......Back 

extern string str1 = ">>>>>>>>>>>>>>";  //TRADE 1 >>>>>>>>>>>>>>
extern bool UseTrade1 = false;     //......Apply?
extern double Lots01 = 0.1;        //......Lots
extern int MaxOrderCount01 = 50; //......Max Order Count
extern int TakeProfit01 = 300;    //......TakeProfit
extern int StopLoss01 = 300;      //......StopLoss
extern int BackPoint01 = 20; //......Back Point
extern int WPRMarginOpen01 = 6; //......WPR Margen (Open)
extern int WPRMarginClose01 = 0; //......WPR Margen (Close)
extern int SendSpan01 = 300; //Order Send Span (second
extern int ModifySpan01 = 5; //Order Modify Span (second)

extern string str2 = ">>>>>>>>>>>>>>"; //TRADE 2 >>>>>>>>>>>>>>
extern bool UseTrade2 = false; //......Apply?
extern double Lots02 = 0.2; //......Lots
extern int MaxOrderCount02 = 50; //......Max Order Count
extern int TakeProfit02 = 80; //......TakeProfit
extern int StopLoss02 = 300; //......StopLoss
extern int BackPoint02 = 20; //......Back Point
extern int MAMargin02 = 0;   //......MA-700 Margin
extern int WPRMarginOpen02 = 6; //......WPR Margen (Open)
extern int WPRMarginClose02 = 0; //......WPR Margen (Close)
extern int SendSpan02 = 300; //Order Send Span (second
extern int ModifySpan02 = 5; //Order Modify Span (second)

extern string str3 = ">>>>>>>>>>>>>>"; //TRADE 3 >>>>>>>>>>>>>>
extern bool UseTrade3 = false; //......Apply?
extern double Lots03 = 0.3; //......Lots
extern int MaxOrderCount03 = 50; //......Max Order Count
extern int TakeProfit03 = 160; //......TakeProfit
extern int StopLoss03 = 350; //......StopLoss
extern int BackPoint03 = 20; //......Back Point
extern int MAMargin03 = 150;   //......MA-700 Margin
extern int SendSpan03 = 300; //Order Send Span (second
extern int ModifySpan03 = 5; //Order Modify Span (second)

extern string str4 = "$$$$$$$$$$$$$$$$$$"; //TRADE 4 >>>>>>>>>>>>>>
extern bool UseTrade4 = true; //......Apply?
extern double Lots04 = 0.4; //......Lots
extern int MaxOrderCount04 = 150; //......Max Order Count
extern int TakeProfit04 = 160; //......TakeProfit
extern int StopLoss04 = 350; //......StopLoss
extern int BackPoint04 = 20; //......Back Point
extern int MAMargin04 = 150;   //......MA-700 Margin
extern int SendSpan04 = 300; //Order Send Span (second
extern int ModifySpan04 = 5; //Order Modify Span (second)

extern string str5 = ">>>>>>>>>>>>>>";  //TRADE 5 >>>>>>>>>>>>>>
extern bool UseTrade5 = false;     //......Apply?
extern double Lots05 = 0.5;        //......Lots
extern int MaxOrderCount05 = 50; //......Max Order Count
extern int TakeProfit05 = 200;    //......TakeProfit
extern int StopLoss05 = 300;      //......StopLoss
extern int BackPoint05 = 50; //......Back Point
extern int MAMargin05 = 180;   //......MA-700 Margin
extern int SendSpan05 = 300; //Order Send Span (second
extern int ModifySpan05 = 5; //Order Modify Span (second)

extern string str6 = ">>>>>>>long-term strategy>>>>>>>";  //TRADE 6 >>>>>>>>>>>>>>
extern bool UseTrade6 = false;     //......Apply?
extern double Lots06 = 0.5;        //......Lots
extern int MaxOrderCount06 = 50; //......Max Order Count
extern int TakeProfit06 = 2000;    //......TakeProfit
extern int StopLoss06 = 1000;      //......StopLoss
extern int BackPoint06 = 100; //......Back Point
extern int Division06 = 25; //......Division Lint
extern int SendSpan06 = 300; //Order Send Span (second
extern int ModifySpan06 = 5; //Order Modify Span (second)

extern string str7 = ">>>>>>>long-term strategy>>>>>>>";  //TRADE 7 >>>>>>>>>>>>>>
extern bool UseTrade7 = false;     //......Apply?
extern double Lots07 = 0.5;        //......Lots
extern int MaxOrderCount07 = 50; //......Max Order Count
extern int TakeProfit07 = 2000;    //......TakeProfit
extern int StopLoss07 = 1000;      //......StopLoss
extern int BackPoint07 = 100; //......Back Point
extern int Division07 = 25; //......Division Lint
extern int SendSpan07 = 300; //Order Send Span (second
extern int ModifySpan07 = 5; //Order Modify Span (second)

extern string str8 = ">>>>>>>long-term strategy>>>>>>>";  //TRADE 8 >>>>>>>>>>>>>>
extern bool UseTrade8 = false;     //......Apply?
extern double Lots08 = 0.5;        //......Lots
extern int MaxOrderCount08 = 50; //......Max Order Count
extern int TakeProfit08 = 2000;    //......TakeProfit
extern int StopLoss08 = 1000;      //......StopLoss
extern int BackPoint08 = 100; //......Back Point
extern int Division08 = 30; //......Division Lint
extern int SendSpan08 = 300; //Order Send Span (second
extern int ModifySpan08 = 5; //Order Modify Span (second)

Strategy01 *stg01 = NULL; 
Strategy02 *stg02 = NULL; 
Strategy03 *stg03 = NULL; 
Strategy04 *stg04 = NULL; 
Strategy05 *stg05 = NULL; 
Strategy06 *stg06 = NULL;
Strategy07 *stg07 = NULL;
Strategy08 *stg08 = NULL;
Strategy999 *stg999 = NULL;

CIndicator *g_indicator;
BaseStrategy *Stg[];

int OnInit()
{
    EventSetTimer(gl_doubleLotsSpan);
    //add(1);
    //add(21);
    //add(22);
    //add(31);
    //add(32);
    //return;    
    
    BaseStrategy *stg;
    int size=0;   
    
    if (UseTrade1) 
    {
        stg01 = new Strategy01(Lots01, MaxOrderCount01, StopLoss01, TakeProfit01, BackPoint01,SendSpan01,ModifySpan01); 
        stg01.WPROpen = WPRMarginOpen01;
        stg01.WPRClose = WPRMarginClose01;     
        size=ArraySize(Stg)+1;
        ArrayResize(Stg,size);
        Stg[size-1]=stg01;   
        BaseStrategy::TotalOrderLimit += MaxOrderCount01;
    }
    if (UseTrade2) 
    {
        stg02 = new Strategy02(Lots02, MaxOrderCount02, StopLoss02, TakeProfit02, BackPoint02,SendSpan02,ModifySpan02); 
        stg02.WPROpen = WPRMarginOpen02;
        stg02.WPRClose = WPRMarginClose02; 
        size=ArraySize(Stg)+1;
        ArrayResize(Stg,size);
        Stg[size-1]=stg02;    
        BaseStrategy::TotalOrderLimit += MaxOrderCount02;   
    }
    if (UseTrade3) 
    {
        stg03 = new Strategy03(Lots03, MaxOrderCount03, StopLoss03, TakeProfit03, BackPoint03,SendSpan03,ModifySpan03); 
        stg03.MA_Margin_out = MAMargin03;
        size=ArraySize(Stg)+1;
        ArrayResize(Stg,size);
        Stg[size-1]=stg03;
        BaseStrategy::TotalOrderLimit += MaxOrderCount03;
    }
    if (UseTrade4) 
    {
        stg04 = new Strategy04(Lots04, MaxOrderCount04, StopLoss04, TakeProfit04, BackPoint04,SendSpan04,ModifySpan04); 
        stg04.MA_Margin_out = MAMargin04;
        size=ArraySize(Stg)+1;
        ArrayResize(Stg,size);
        Stg[size-1]=stg04;
        BaseStrategy::TotalOrderLimit += MaxOrderCount04;
    }
    if (UseTrade5) 
    {
        stg05 = new Strategy05(Lots05, MaxOrderCount05, StopLoss05, TakeProfit05, BackPoint05,SendSpan05,ModifySpan05);   
        stg05.MA_Margin_out = MAMargin05;
        
        size=ArraySize(Stg)+1;
        ArrayResize(Stg,size);
        Stg[size-1]=stg05;
        BaseStrategy::TotalOrderLimit += MaxOrderCount05;
    }  
    if (UseTrade6) 
    {
        stg06 = new Strategy06(Lots06, MaxOrderCount06, StopLoss06, TakeProfit06, BackPoint06,SendSpan06,ModifySpan06,Division06);   
        
        size=ArraySize(Stg)+1;
        ArrayResize(Stg,size);
        Stg[size-1]=stg06;
        BaseStrategy::TotalOrderLimit += MaxOrderCount06;
    }  
    if (UseTrade7) 
    {
        stg07 = new Strategy07(Lots07, MaxOrderCount07, StopLoss07, TakeProfit07, BackPoint07,SendSpan07,ModifySpan07,Division07);   
        
        size=ArraySize(Stg)+1;
        ArrayResize(Stg,size);
        Stg[size-1]=stg07;
        BaseStrategy::TotalOrderLimit += MaxOrderCount07;
    }  
    if (UseTrade8) 
    {
        stg08 = new Strategy08(Lots08, MaxOrderCount08, StopLoss08, TakeProfit08, BackPoint08,SendSpan08,ModifySpan08,Division08);   
        
        size=ArraySize(Stg)+1;
        ArrayResize(Stg,size);
        Stg[size-1]=stg08;
        BaseStrategy::TotalOrderLimit += MaxOrderCount08;
    }  
    if (UseTrade999)
    {
    	stg999 = new Strategy999(0,1,StopLoss999,TakeProfit999, BackPoint999);
    }
    
    RefreshOrders();
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
	
    CloseOrModify();   
    
    
    for(int i=0;i<ArraySize(Stg);i++)
     {
        Stg[i].SendOrder(g_indicator);
     }
	
	if(stg999 != NULL)
	{
		for (int i = 0; i < OrdersTotal(); i++)
    	{
    		if (!SelectOrder(i)) continue;
    		if(OrderMagicNumber() != magic999) continue;
    		stg999.ModifyOrder(OrderType(), g_indicator);
    	}     
		
		if (TimeCurrent() >= BaseStrategy::Timer4DoubleLots + gl_doubleLotsSpan)
		{		    
		    stg999.SendOrder();	    
		    BaseStrategy::Timer4DoubleLots = TimeCurrent();
		}
	}
	
    delete g_indicator;
}

void RefreshOrders()
{
    for(int i=0;i<ArraySize(Stg);i++)
     {
        Stg[i].RefreshOrders();
     }
}

void CloseOrModify()
{
    BaseStrategy *strategy = NULL;
        	
    for(int j=0;j<ArraySize(Stg);j++)
     {
        strategy = Stg[j];
        int iMagic = strategy.magic;
        bool closeBuy = strategy.TobeClosed(OP_BUY, g_indicator);
        bool closeSell = strategy.TobeClosed(OP_SELL, g_indicator);
        
        int i;
        for (i = 0; i < OrdersTotal(); i++)
    	{
    		if (!SelectOrder(i)) continue;
    		if(OrderMagicNumber() != iMagic) continue;
    		
    		if(closeBuy && OrderType() == OP_BUY) strategy.CloseOrder(0);   
    		if(closeSell && OrderType() == OP_SELL) strategy.CloseOrder(1); 		
    	}     
    	
    	for (i = 0; i < OrdersTotal(); i++)
    	{
    		if (!SelectOrder(i)) continue;
    		if(OrderMagicNumber() != iMagic) continue;
    		strategy.ModifyOrder(OrderType(), g_indicator);
    	}       	  		
    		
     } 
}


void OnTimer()
{
	Print("OnTimer");
    //Strategy999 *stg999 = new Strategy999();
    //stg999.DoubleLots();
    
    //delete stg999;
}
  
string StatsStrategy(BaseStrategy *stg)
{
    int ordercount = 0;
    int buycount = 0;
    int cellcount = 0;
    double profit = 0;
    for(int i=0; i<ArraySize(stg.OrdersHistroy); i++)
    {
        if(stg.Orders[i].CMD == OP_BUY) 
            buycount++;
        else
            cellcount++;
        
        profit += stg.Orders[i].Profit;
    }
    
    return (StringConcatenate("策略", stg.magic,": 买单数：", buycount, ", 卖单数：", cellcount, ", 盈利：", DoubleToString(NormalizeDouble(profit, 4),2)));
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
        Text = StatsStrategy(Stg[i]); y += 25; iDisplayInfo(Stg[i].magic,Text,CORNER_LEFT_UPPER,x,y,size,"微软雅黑",clr);
     }
     
}
