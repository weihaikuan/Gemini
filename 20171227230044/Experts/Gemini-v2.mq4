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
extern int MaxSL = 450;

extern string str999 = "$$$$$$$$$$$$$$$$$$";  //TRADE 999 >>>>>>>>>>>>>>
extern bool UseTrade999 = true;     //......Apply?
extern string SendConfig999 = "0.02,3,3600,50;0.01,3,3600,80;0.01,3,3600,150;0.01,3,3600,200"; //Config(lots,maxorder,sendspan,patchpoint)

extern string str11 = ">>>>>>>>>>>>>>";  //TRADE 11 >>>>>>>>>>>>>>
extern bool UseTrade11 = true;     //......Apply?
extern string SendConfig11 = "0.02,5,3600;0.01,5,7200"; //Config(lots,maxorder,sendspan)
extern int Division11 = 25; //......Division Line
extern int WprOpen11 = 6; //......WPR Margen (Open)

extern string str12 = ">>>>>>>>>>>>>>";  //TRADE 12 >>>>>>>>>>>>>>
extern bool UseTrade12 = false;     //......Apply?
extern string SendConfig12 = "0.01,2,300;0.02,2,900"; //Config(lots,maxorder,sendspan)
extern int Division12 = 25; //......Division Line
extern int WprOpen12 = 6; //......WPR Margen (Open)

extern string str21 = ">>>>>>>>>>>>>>";  //TRADE 21 >>>>>>>>>>>>>>
extern bool UseTrade21 = false;     //......Apply?
extern string SendConfig21 = "0.01,2,300;0.02,2,900"; //Config(lots,maxorder,sendspan)
extern int Division21 = 25; //......Division Line
extern int MAMargin21 = 20;   //......ma_H4_14 Margin

extern string str22 = ">>>>>>>>>>>>>>";  //TRADE 22 >>>>>>>>>>>>>>
extern bool UseTrade22 = false;     //......Apply?
extern string SendConfig22 = "0.01,2,300;0.02,2,900"; //Config(lots,maxorder,sendspan)
extern int Division22 = 30; //......Division Line
extern int MAMargin22 = 50;   //......ma_H4_14 Margin

extern string str3 = ">>>>>>>>>>>>>>"; //TRADE 3 >>>>>>>>>>>>>>
extern bool UseTrade3 = false; //......Apply?
extern string SendConfig3 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin3 = 150;   //......MA-700 Margin


extern string str4 = "$$$$$$$$$$$$$$$$$$"; //TRADE 4 >>>>>>>>>>>>>>
extern bool UseTrade4 = false; //......Apply?
extern string SendConfig4 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin4 = 150;   //......MA-700 Margin

extern string str5 = ">>>>>>>>>>>>>>"; //TRADE 5 >>>>>>>>>>>>>>
extern bool UseTrade5 = false; //......Apply?
extern string SendConfig5 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin5 = 150;   //......MA-700 Margin

extern string str6 = ">>>>>>>>>>>>>>";  //TRADE 6 >>>>>>>>>>>>>>
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
				stg.MAMargin = MAMargin21;
				stg.Division = Division21;
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
		Print("lots=", Stg[0].GetLots());				
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
	if (TimeCurrent() < LastModifyTime + 5) return;
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

double GetAdjustPoint(int cmd)
{   	
	bool UsePB = false;
	int PBto = 10;
	
	double bf = GetBoFu(PERIOD_H4, 1);
	
	double adjustPoint = 0;
	double backPoint = 20;
	double profit = 0;
	bool hasProtected = false;
		
	backPoint = bf;
	if(backPoint < 20) backPoint = 20;
	if(backPoint > 50) backPoint = 50;
	
	if(!UsePB) return (-1 * backPoint * gl_basePoint);
	
	if (cmd == OP_BUY)
	{
		profit = Bid - OrderOpenPrice();
		if(OrderStopLoss() > OrderOpenPrice()) hasProtected = true;
	}
	else
	{
		profit = OrderOpenPrice() - Ask;
		if(OrderStopLoss() < OrderOpenPrice()) hasProtected = true;
	}
	
	if (!hasProtected)
	{
		if(profit > PBto * gl_basePoint)
			adjustPoint = PBto * gl_basePoint;
		else
			adjustPoint = 0;		
	}	
	else
	{
		adjustPoint = -1 * backPoint;
	}
	if(adjustPoint > 0 && hasProtected) adjustPoint = 0; //only protect the first time.
	
	return (adjustPoint);
};

bool ModifyOrder(int cmd)
{
    double adjustPoint = GetAdjustPoint(cmd);	    	
	
	if (adjustPoint == 0) return false;
	
   	double stoploss = OrderStopLoss();
    bool rtn = false;
    
    if (cmd == OP_BUY)
	{
		if(adjustPoint > 0)
			stoploss = NormalizeDouble(OrderOpenPrice() + MathAbs(adjustPoint), Digits);
		else
			stoploss = NormalizeDouble(Bid - MathAbs(adjustPoint), Digits);
			
		if (Bid - OrderOpenPrice() > MathAbs(adjustPoint)) 
		{
			if (OrderStopLoss() < stoploss && IsValidSL(OrderType(), stoploss)) 
			{
                if (OrderModify(OrderTicket(), OrderOpenPrice(), stoploss, OrderTakeProfit(), 0, clrBlue))
                {
                    rtn = true;
                    
                    Comment("\r\n adjustPoint=", adjustPoint/gl_basePoint);
                }
                else
                    Print("Sell单(",OrderTicket(),")修改失败,错误原因："+iGetErrorInfo(GetLastError()));		   
			}
		}
	}
	else
	{
		if(adjustPoint > 0)
			stoploss = NormalizeDouble(OrderOpenPrice() - MathAbs(adjustPoint), Digits);
		else
			stoploss = NormalizeDouble(Ask + MathAbs(adjustPoint), Digits);
			
		if (OrderOpenPrice() - Ask > MathAbs(adjustPoint)) 
		{
			if (OrderStopLoss() > stoploss && IsValidSL(OrderType(), stoploss)) 
			{
			   if (OrderModify(OrderTicket(), OrderOpenPrice(), stoploss, OrderTakeProfit(), 0, clrRed))
			   {
			        rtn = true;
			        Comment("\r\n adjustPoint=", adjustPoint/gl_basePoint);
			   }
			   else
			        Print("Buy单(",OrderTicket(),")修改失败,错误原因："+iGetErrorInfo(GetLastError()));			   
			}
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