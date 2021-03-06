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
#include <Gemini-base.mqh>
#include <Gemini-Kline.mqh>

extern double Blance_Rate = 0.6; //账户余额比例(0.3=30%)
extern bool UseMM = false; //使用复利模式?
extern double MM = 1.0; //复利率
extern int MinSL = 800; //最小止损
extern int MaxSL = 1000; //最大止损
extern int Frequency = 5; //跟损时间间隔（秒）)
extern int RSILimit = 70; //RSI限制
extern ENUM_TIMEFRAMES Period4Trend = PERIOD_D1;//趋势图K线
extern double Percentage4hedging = 0.5; //对冲百分比
extern int DuichongPoint = 100; //开始对冲点数

extern string str999 = "$$$$$$$$$$$$$$$$$$";  //策略999 >>>>>>>>>>>>>>
extern bool UseTrade999 = true;     //......启用策略?
extern string SendConfig999 = "0.1,2,300,100;0.2,4,300,200;0.3,6,300,300;0.4,8,300,400;0.5,10,300,500;0.6,12,300,600"; //配置(手数,单数,下单间隔(秒),补单点数)

extern string str11 = "$$$$$$$$$$$$$$$$$$";  //策略11 >>>>>>>>>>>>>>
extern bool UseTrade11 = false;     //......启用策略?
extern string SendConfig11 = "0.02,5,300;0.02,5,900"; //配置(手数,单数,下单间隔(秒))
extern int Division11 = 25; //......ADX限制
extern int WprOpen11 = 6; //......WPR限制(Open)

class Strategy111 : public BaseStrategy
{
public:  
    int GetCommand(double &lots)
    {
        double rsiLimit = iRSI(NULL, TrendPeriod, 14, PRICE_CLOSE, 0);
        if(rsiLimit > RSILimit && Trend == 0 || rsiLimit < 100 - RSILimit && Trend == 1) return(-1);     
          
		int rtn = -1; 
		switch(Magic)
		{
			case 11:
			{
			    double adx_M5 = iADX(NULL,PERIOD_M5,14,PRICE_CLOSE,MODE_MAIN,0);
			    double wpr_M5 = iWPR(NULL, PERIOD_M5, 18, 0);
			    double ma_M5_700 = iMA(NULL, PERIOD_M5, 700, 0, MODE_SMMA, PRICE_CLOSE, 1); 
			    double close_M5 = iClose(NULL, PERIOD_M5, 1);
				if(adx_M5 < Division11 && wpr_M5 < WprOpen11 + (-100) && close_M5 < ma_M5_700 + 60 * BasePoint && Trend == 0)
					rtn = 0;
				else if (adx_M5 < Division11 && wpr_M5 > -WprOpen11 && close_M5 > ma_M5_700 - 60 * BasePoint && Trend == 1)
					rtn = 1;
			}
				break;    			
			case 999:
			    rtn = GetCMD4Patch(lots);
			    break;
		}    		
		
    	return(rtn);
    };
 public:    
    Strategy111(int magic, int magicnumber): BaseStrategy(magic, magicnumber){ };
    ~Strategy111(){}
    
 private:
 int GetCMD4Patch(double &lots)
 {
 	if(PatchPoint == 0) return -1;
 	
 	int rtn = -1;
 	
 	double loss0 = 0;
	double totalloss = 0;
 	
    for (int j = OrdersTotal() - 1; j >=0; j--)
    {			  
        if (!SelectOrder(j)) continue;  
        //if(OrderMagicNumber() >= 9990) continue;
        
        double price = OrderOpenPrice();
        double cmd = OrderType();          

        if(cmd == 0)
        {            
            double lossPoint = price - Bid;
            if(lossPoint > 0) totalloss += lossPoint * OrderLots();
            if(lossPoint > loss0) 
            {
                loss0 = lossPoint;                
            }                  
        }
        
        if(cmd == 1)
        {
            double lossPoint = Ask - price; 
            if(lossPoint > 0) totalloss += lossPoint * OrderLots(); 
            if(lossPoint > loss0) 
            {
                loss0 = lossPoint; 
            }        
        }
    }  
    if(PatchPoint > 0 && loss0 > PatchPoint * BasePoint && loss0 < (PatchPoint + 50) * BasePoint)
	{	    
		rtn = Trend;			
    }
	return(rtn);
 }
 
};


bool ModifyOrder(int cmd)
{
   	int ticket = OrderTicket();   	
   	double openprice = OrderOpenPrice();
   	datetime opentime = OrderOpenTime();
   	double oldstoploss = OrderStopLoss();
   	double stoploss = 0;
   	double takeprofit = OrderTakeProfit();
   	color clr = clrBlue;
   	
   	double adjustPoint = GetBoFu(PERIOD_H4, 1);	
   	if(adjustPoint < 15) 
   	    adjustPoint = 15;	
   	else if(adjustPoint > 20)
   	    adjustPoint = 20;
   	    	
	adjustPoint = adjustPoint * BasePoint;  
   	
    bool tobemodify = false; 
	
	if (cmd == OP_BUY)
	{
	    stoploss = NormalizeDouble(Bid - adjustPoint, Digits);			
		if (stoploss > openprice && stoploss > oldstoploss && IsValidSL(cmd, stoploss)) 
		    tobemodify = true;	
	}
	else
	{
	    clr = clrRed;
		stoploss = NormalizeDouble(Ask + adjustPoint, Digits);			
		if (stoploss < openprice && stoploss < oldstoploss && IsValidSL(cmd, stoploss)) 
		    tobemodify = true;		
	}	
	
	bool rtn = false;
	if(tobemodify)
	{
        
        if (OrderModify(ticket, openprice, stoploss, takeprofit, 0, clr))
        {
            rtn = true;        
            Comment("\r\n adjustPoint=", adjustPoint/BasePoint);
        }
        else
        {
            Print("Sell单(",OrderTicket(),")修改失败,错误原因："+iGetErrorInfo(GetLastError()));	
            return(false);
        }
    }   
    
	return (rtn);
};

BaseStrategy *Stg[];
datetime lastDuichongTime;

void AssembleStrategy(int magic)
{	
	string sendConfig;
	
	switch(magic)
	{
		case 11:
			sendConfig = SendConfig11;
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
		BaseStrategy::TotalLots += lots;
		StrategyCount++;
	}   
	
}

CMarket *market;

int OnInit()
{
    EventSetTimer(300);
    //add(1); return;    

    StrategyCount = 0;
	BaseStrategy::TotalOrderLimit = 0;	
	ArrayResize(Stg,0);
	
    if (UseTrade11) AssembleStrategy(11);	
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
	    double lots0 = Stg[0].GetLots(0, 0); 
		Print("lots=", lots0);	
		if(lots0<0.01) 
		{
		    Alert("Lots config is not well set! please double check. ");
		    return(INIT_FAILED);
		}			
	}	
	
	LastModifyTime = 0;
	lastDuichongTime = 0;
	TrendPeriod = Period4Trend;
	
	market = new CMarket(PERIOD_D1, 10);
	
    return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
    for(int i=0; i < ArraySize(Stg); i++)
    {
        delete Stg[i];        
    }
    ArrayResize(Stg, 0);
    
    delete market;
}

datetime LastModifyTime; 
void OnTick()
{
	if (TimeCurrent() < LastModifyTime + Frequency) return; //Frequency秒
	Trend = GetTrend(TrendPeriod);
	
	if(TimeCurrent() > lastDuichongTime + 36000)
	{
	    Duichong();	    
	}
	
	for (int i = 0; i < OrdersTotal(); i++)
	{
		if (!SelectOrder(i)) continue;
		
		ModifyOrder(OrderType());				
	} 	
	
	//if(market.GetTradeSign())
	{
        for(int i=0;i<ArraySize(Stg);i++)
        {
            Stg[i].SendOrder();
        }	
    }
	
	LastModifyTime = TimeCurrent();
};


struct CLost
{
    int CMD;
    int Ticket;
    double LossPoint;
    double Lots;
};

bool Duichong(double profit)
{
    bool rtn = false;
    
    CLost LostOrders[];
    int size = 0; 
    //Print("Size=", size, ",profit=", profit);
    
    for (int j = OrdersTotal() - 1; j >=0; j--)
    {			  
        if (!SelectOrder(j)) continue;  
        double price = OrderOpenPrice();
        int cmd = OrderType();  

        if( cmd == 0 && price - Bid > DuichongPoint * BasePoint || cmd == 1 && Ask - price  > DuichongPoint * BasePoint )
        {  
            //size = ArraySize(LostOrders); 
            size++;    
            ArrayResize(LostOrders, size);   
            LostOrders[size-1].CMD = cmd;
            LostOrders[size-1].Ticket = OrderTicket();
            LostOrders[size-1].Lots = OrderLots();
            if(cmd == 0)
                LostOrders[size-1].LossPoint = price - Bid;
            else
                LostOrders[size-1].LossPoint = Ask - price;       

        }      
    }  
    
    //Print("Size=", size);
    
    if(size > 0)
    {
        //ASC order
        for(int i = 0;i < size;i++)
        {      		 
    		for(int j = 0;j < size-i-1;j++)
    		{  
                if(LostOrders[j].LossPoint < LostOrders[j+1].LossPoint)
                {  
                    CLost t = LostOrders[j];  
                    LostOrders[j] = LostOrders[j+1];  
                    LostOrders[j+1] = t;  
                }
            }  
        }          
        
        for(int i = 0;i < size;i++)
        {    
            double lossed = LostOrders[i].LossPoint * LostOrders[i].Lots;
            int cmd = LostOrders[i].CMD;
            int ticket = LostOrders[i].Ticket;
            double lots;
            if(profit >= lossed)
            {
                lots = LostOrders[i].Lots;
                profit = profit - lossed;                  
            }
            else
            {
                lots = profit / lossed;
                if(lots < MarketInfo(Symbol(), MODE_MINLOT)) lots = 0;
                profit = 0;
            }     
            
            if(lots > 0)
            {
                Print("DC:lossed=", lossed, ",profit=", profit,",lots=", lots, ", ticket=", ticket);
                CloseOrder(cmd, ticket, lots);
                Comment("DUICHONG: ", ticket, " Lots:", lots);
                
                rtn = true;
            }
            
            if(profit == 0) break;                               
        }
    }    
    
    return(rtn);
}

void Duichong()
{
    double profit = 0;
    
    for (int i=OrdersHistoryTotal(); i >= 0; i--)
    {
        
        if (!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
        if (OrderCloseTime() < lastDuichongTime) break;
              
        if(OrderMagicNumber() >= 0)//All profit order will be used. if only 999, should use 9990 instead of 0.
        {
            if(OrderType() == 0 && OrderClosePrice() > OrderOpenPrice())
            {
                profit += ((OrderClosePrice() - OrderOpenPrice()) * OrderLots());
            }
            if(OrderType() == 1 && OrderClosePrice() < OrderOpenPrice())
            {
                profit += ((OrderOpenPrice() - OrderClosePrice()) * OrderLots());
            }  
        } 
                
    }   
      
    if(profit > 0)
    {
        profit = profit * Percentage4hedging;
        
        if(Duichong(profit)) lastDuichongTime = TimeCurrent(); 
    }    
        
};