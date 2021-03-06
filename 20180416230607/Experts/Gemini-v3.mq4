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

extern double Blance_Rate = 0.6; //账户余额比例(0.3=30%)
extern bool UseMM = false; //使用复利模式?
extern double MM = 1.0; //复利率
extern int MinSL = 1000; //最小止损
extern int MaxSL = 2000; //最大止损
extern int MIN_MovePoint = 15; //最小移动跟损点
extern int MAX_MovePoint = 25;//最大移动跟损点
extern int Frequency = 5; //跟损时间间隔（秒）)
extern int RSILimit = 90; //RSI限制
extern ENUM_TIMEFRAMES Period4Trend = PERIOD_W1;//趋势图K线周期
extern int K1 = 3;//趋势图 K线1
extern int K2 = 10;//趋势图 K线2
extern int K3 = 20;//趋势图 K线3
extern double Percentage4hedging = 0.9; //对冲百分比
extern int DuichongPoint = 50; //开始对冲点数

extern string str999 = "Lots,OrderCount,BCSpan(s), BCPoints,MovePoint";  //策略999 >>>>>>>>>>>>>>
extern bool UseTrade999 = true;     //......启用策略?
extern string SendConfig999 = "0.1,5,300,30,20;0.2,5,300,100,20;0.4,10,300,200,25"; //配置(手数,单数,下单间隔(秒),补单点数,跟损点数)

extern string str11 = "$$$$$$$$$$$$$$$$$$";  //策略11 >>>>>>>>>>>>>>
extern bool UseTrade11 = true;     //......启用策略?
extern string SendConfig11 = "0.01,1,300;0.1,1,900"; //配置(手数,单数,下单间隔(秒))
extern int Division11 = 25; //......ADX限制
extern int WprOpen11 = 6; //......WPR限制(Open)

extern string str12 = "$$$$$$$$$$$$$$$$$$";  //TRADE 12 ----------------------------------------------------
extern bool UseTrade12 = true;     //......Apply?
extern string SendConfig12 = "0.12,2,300"; //Config(lots,maxorder,sendspan)

extern string str4 = "****************************"; //TRADE 4 >>>>>>>>>>>>>>
extern bool UseTrade4 = false; //......Apply?
extern string SendConfig4 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin4 = 150;   //......MA-700 Margin

double BasePoint = 0.0001; 
int Trend = -1;
int StrategyCount = 0;

/*
函数：在屏幕上显示标签
      LableName:标签名称  LableDoc:文本内容  LableX:标签X的置  LableY:标签Y的位置
      DocSize:文本字号   DocStyle:文本字体    DocColor:文本颜色
*/
void Setlable(string LableName,string LableDoc,int LableX,int LableY,int DocSize,string DocStyle,color DocColor)
{
    ObjectCreate(LableName,OBJ_LABEL,0,0,0);
    ObjectSetText(LableName,LableDoc,DocSize, DocStyle,DocColor);
    ObjectSet(LableName,OBJPROP_XDISTANCE,LableX);
    ObjectSet(LableName,OBJPROP_YDISTANCE,LableY);
}

int GetSendConfigs(string to_split,string &result[], string sep)
{
    ArrayResize(result,0);
 
    ushort u_sep = StringGetCharacter(sep,0); 

    int k=StringSplit(to_split,u_sep,result); 

    return k;
}

bool CloseOrder(int cmd)
{    	    
    bool rtn = false;
		
    if (cmd == OP_BUY)
		rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 3, clrBlue);
	else
		rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 3, clrRed);
	
	if(!rtn) Print("订单(",OrderTicket(),")关闭失败,错误原因："+iGetErrorInfo(GetLastError()));	       	
	
	return(rtn);
};

bool CloseOrder(int cmd, int ticket, double lots)
{    	    
    bool rtn = false;
		
    if (cmd == OP_BUY)
		rtn = OrderClose(ticket, lots, NormalizeDouble(Bid, Digits), 3, clrBlue);
	else
		rtn = OrderClose(ticket, lots, NormalizeDouble(Ask, Digits), 3, clrRed);
	
	if(!rtn) Print("订单(",ticket,")关闭失败,错误原因："+iGetErrorInfo(GetLastError()));	       	
	
	return(rtn);
};

string iGetErrorInfo(int myErrorNum)
{
    string myLastErrorStr;
    if(myErrorNum>0)
    {
        switch (myErrorNum)
        {
            case 0   :myLastErrorStr="交易报错码:0 没有错误返回";break;
            case 1   :myLastErrorStr="交易报错码:1 没有错误返回,可能是反复同价修改";break;
            case 2   :myLastErrorStr="交易报错码:2 一般错误";break;
            case 3   :myLastErrorStr="交易报错码:3 交易参数出错";break;
            case 4   :myLastErrorStr="交易报错码:4 交易服务器繁忙";break;
            case 5   :myLastErrorStr="交易报错码:5 客户终端软件版本太旧";break;
            case 6   :myLastErrorStr="交易报错码:6 没有连接交易服务器";break;
            case 7   :myLastErrorStr="交易报错码:7 操作权限不够";break;
            case 8   :myLastErrorStr="交易报错码:8 交易请求过于频繁";break;
            case 9   :myLastErrorStr="交易报错码:9 交易操作故障";break;
            case 64  :myLastErrorStr="交易报错码:64 账户被禁用";break;
            case 65  :myLastErrorStr="交易报错码:65 无效账户";break;
            case 128 :myLastErrorStr="交易报错码:128 交易超时";break;
            case 129 :myLastErrorStr="交易报错码:129 无效报价";break;
            case 130 :myLastErrorStr="交易报错码:130 止损错误";break;
            case 131 :myLastErrorStr="交易报错码:131 交易量错误";break;
            case 132 :myLastErrorStr="交易报错码:132 休市";break;
            case 133 :myLastErrorStr="交易报错码:133 禁止交易";break;
            case 134 :myLastErrorStr="交易报错码:134 资金不足";break;
            case 135 :myLastErrorStr="交易报错码:135 报价发生改变";break;
            case 136 :myLastErrorStr="交易报错码:136 建仓价过期";break;
            case 137 :myLastErrorStr="交易报错码:137 经纪商很忙";break;
            case 138 :myLastErrorStr="交易报错码:138 需要重新报价";break;
            case 139 :myLastErrorStr="交易报错码:139 定单被锁定";break;
            case 140 :myLastErrorStr="交易报错码:140 只允许做买入类型操作";break;
            case 141 :myLastErrorStr="交易报错码:141 请求过多";break;
            case 145 :myLastErrorStr="交易报错码:145 过于接近报价，禁止修改";break;
            case 146 :myLastErrorStr="交易报错码:146 交易繁忙";break;
            case 147 :myLastErrorStr="交易报错码:147 交易期限被经纪商取消";break;
            case 148 :myLastErrorStr="交易报错码:148 持仓单数量超过经纪商的规定";break;
            case 149 :myLastErrorStr="交易报错码:149 禁止对冲";break;
            case 150 :myLastErrorStr="交易报错码:150 FIFO禁则";break;            
        }
    }
    return(myLastErrorStr);
};
bool SelectOrder(int i)
{
	if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
	{
		Print("OrderSelect failed, index = ", i, ", Error Message: ", GetLastError());	
		return false;
	}
	if (OrderType() > OP_SELL || OrderSymbol() != Symbol())
	{
		return false;
	}
	return true;
};

bool SelectOrderByTicket(int ticket)
{
	if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
	{
		Print("OrderSelect failed, index = ", ticket, ", Error Message: ", GetLastError());	
		return false;
	}
	if (OrderType() > OP_SELL || OrderSymbol() != Symbol())
	{
		return false;
	}
	return true;
};

int GetBoFu(ENUM_TIMEFRAMES timeframe, int shift)
{
	double high = iHigh(NULL, timeframe, shift);
	double low = iLow(NULL, timeframe, shift);
	int bofu = (high - low) / BasePoint;
	return bofu;
};

class BaseStrategy
{
public:
    static double Blance_Rate;
    static double MM;
    static bool UseMM;
    static int TotalOrderLimit;
    static double TotalLots;
	static int MinStopLoss;
    static int MaxStopLoss;
    static int RSILimit;
    
public:   
    
    int Magic;
    int MagicNumber;
    double Lots;
    double Weight;
    int MaxOrderCount; 
    int SendSpan;
    
    datetime LastSendTime; 
    int StopLoss;
    int TakeProfit; 
    
	int PatchPoint;
    
    BaseStrategy(int magic, int magicnumber)
    {      
        Magic = magic;
        MagicNumber=magicnumber;
        LastSendTime = 0;
        StopLoss = 0;
        TakeProfit = 0;
    }
    ~BaseStrategy(){}
public:    
    virtual int GetCommand(double &lots) = 0;    
    virtual bool SendOrder();  
      
    double GetLots(int cmd, double lots0);
    bool CheckLots(double lots);
};

double BaseStrategy::Blance_Rate = 0.3;
double BaseStrategy::MM = 0.05;
bool BaseStrategy::UseMM = false;
int BaseStrategy::TotalOrderLimit = 0;
double BaseStrategy::TotalLots = 0;
int BaseStrategy::MinStopLoss = 200;
int BaseStrategy::MaxStopLoss = 350;
int BaseStrategy::RSILimit = 70;

bool BaseStrategy::CheckLots(double lots)
{
	if (lots<=0) return false;
	
    if (AccountEquity() * Blance_Rate > AccountFreeMargin())
    {
        Print("账户资金余额已低于 ", Blance_Rate * 100 , "%, 不再下单了！账户净值=", AccountEquity(), ",  可用预付款=",  AccountFreeMargin());
        return (false);
    }
 
	double lotsize = MarketInfo(Symbol(), MODE_LOTSIZE);
	if (AccountFreeMargin() < Ask * lots * lotsize / AccountLeverage()) 
	{
		Print("账户资金不足. 下单量 = ", lots, " , 自由保证金 = ", AccountFreeMargin());
		return (false);
	}
	else
		return (true);
}
double BaseStrategy::GetLots(int cmd, double lots0)
{	 
	int orderCount = 0;
	for (int i = OrdersTotal() - 1; i >= 0; i--)
	{
		if (!SelectOrder(i)) continue;
		if(OrderMagicNumber() == this.MagicNumber && OrderType() == cmd)
			orderCount++;		
	}
    if (orderCount >= this.MaxOrderCount) return 0; 
	
	if(lots0 > 0) return lots0;
		
	double lots;
	if (UseMM)
	{
    	//lots = AccountEquity() * Blance_Rate / (this.MaxStopLoss * 10) /this.TotalOrderLimit;
    	//lots *= MM;
    	//lots *= this.Lots / (TotalLots / StrategyCount);
    	lots = AccountEquity()/MarketInfo(Symbol(), MODE_MARGINREQUIRED);
    	lots = lots * MM / TotalOrderLimit;
    	lots /= 2; //Buy:Sell == 1:1
    	
    	if(lots < 0.01) lots = 0.01;    	
    }
	else
	    lots = this.Lots;  
    
	lots = NormalizeDouble(lots, 2);
	
	if (!CheckLots(lots)) lots = 0;
	
	return(lots);
};
  
bool BaseStrategy::SendOrder()
{
    if (TimeCurrent() < this.LastSendTime + this.SendSpan) return false; 
    double lots = 0;
	int cmd = GetCommand(lots);
	if (cmd == -1) return false;
	
	lots = this.GetLots(cmd, lots); 
	if(lots <= 0) return false;
	
	//get SL and TP per ZhenDang of last week.
	double bofu = GetBoFu(PERIOD_MN1, 1);
    double price, stoploss, takeprofit;
    
    takeprofit = bofu/4;
    stoploss = bofu;
    if (stoploss < BaseStrategy::MinStopLoss) stoploss = BaseStrategy::MinStopLoss;
	if (stoploss > BaseStrategy::MaxStopLoss) stoploss = BaseStrategy::MaxStopLoss;
	if (takeprofit < 50) takeprofit = 50;
	    
    color clr = clrBlue;    
    if (cmd == 1) clr = clrRed;
	
    if (cmd == 0)
    {
	    price = NormalizeDouble(Ask, Digits);
	    if(this.StopLoss == 0 )
	    	stoploss = price - stoploss * BasePoint;
	    else
	    	stoploss = price - this.StopLoss * BasePoint; 
	    
	    if(this.TakeProfit == 0)
	    	takeprofit = price + takeprofit * BasePoint;
	    else
	    	takeprofit = price + this.TakeProfit * BasePoint;
	}
	else
	{
	    price = NormalizeDouble(Bid, Digits);
	    if(this.StopLoss == 0 )
	    	stoploss = price + stoploss * BasePoint;
	    else
	    	stoploss = price + this.StopLoss * BasePoint; 
	    	
	    if(this.TakeProfit == 0)
	    	takeprofit = price - takeprofit * BasePoint;
	    else
	    	takeprofit = price - this.TakeProfit * BasePoint;
	    
	}

	int ticket = OrderSend(Symbol(), cmd, lots, price, 3, stoploss, takeprofit, IntegerToString(MagicNumber), MagicNumber, 0, clr);
	if(ticket>=0) 
	{
		Comment("\r\n cmd=", cmd, ", lots=", lots, ", magic=", MagicNumber);			
	    this.LastSendTime = TimeCurrent();		    
	    return(true);	
	}    
	else
	    Print("下单失败,错误原因："+iGetErrorInfo(GetLastError()));				
	
    
    return false;
};

class Strategy111 : public BaseStrategy
{
public:  
    int GetCommand(double &lots)
    {
        double rsiLimit = iRSI(NULL, Period4Trend, 14, PRICE_CLOSE, 0);
        if(rsiLimit > RSILimit && Trend == 0 || rsiLimit < 100 - RSILimit && Trend == 1) return(-1);     
        if(Trend < 0) return -1;
          
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
			case 12:
			{
			    double rsi_M5 = iRSI(NULL, PERIOD_M5, 14, PRICE_CLOSE, 1);
			    double close_M5 = iClose(NULL, PERIOD_M5, 1);
			    double ma_M5_700 = iMA(NULL, PERIOD_M5, 700, 0, MODE_SMMA, PRICE_CLOSE, 1);
			    
				if(rsi_M5 < 30 && close_M5 < ma_M5_700 + 60 * BasePoint && Trend == 0)
					rtn = 0;
				else if ( rsi_M5 > 70 && close_M5 > ma_M5_700 - 60 * BasePoint && Trend == 1)
					rtn = 1;
			}
				break; 
    	    case 4:
    	    {
    	        double rsi_M5 = iRSI(NULL, PERIOD_M5, 14, PRICE_CLOSE, 1);
    	        double close_M5 = iClose(NULL, PERIOD_M5, 1);
    	        double ma_H1_1 = iMA(NULL, PERIOD_H1, 1, 0, MODE_EMA, PRICE_CLOSE, 1);
    	        double ma_M5_700 = iMA(NULL, PERIOD_M5, 700, 0, MODE_SMMA, PRICE_CLOSE, 1);
    	        double atr_H1_19 = iATR(NULL, PERIOD_H1, 19, 1); 
    	        
				if (close_M5 >= ma_H1_1 + atr_H1_19*1.4 + 13 * BasePoint && close_M5 < ma_M5_700 + MAMargin4 * BasePoint && rsi_M5 < 70 && Trend == 0)		
					rtn = 0;
				else if (close_M5 <= ma_H1_1 - atr_H1_19*1.4 - 13 * BasePoint && close_M5 > ma_M5_700 - MAMargin4 * BasePoint	&& rsi_M5 > 30 && Trend == 1)
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
 	
 	int cmd0;
 	double loss0 = 0;
	double totalloss = 0;
 	
    for (int j = OrdersTotal() - 1; j >=0; j--)
    {			  
        if (!SelectOrder(j)) continue;  
        //if(OrderMagicNumber() >= 9990) continue;
        
        double price = OrderOpenPrice();
        int cmd = OrderType(); 
           
        if(cmd == 0)
        {            
            double lossPoint = price - Bid;
            if(lossPoint > 0) totalloss += lossPoint * OrderLots();
            if(lossPoint > loss0) 
            {
                loss0 = lossPoint; 
                cmd0 = cmd;               
            }                  
        }
        
        if(cmd == 1)
        {
            double lossPoint = Ask - price; 
            if(lossPoint > 0) totalloss += lossPoint * OrderLots(); 
            if(lossPoint > loss0) 
            {
                loss0 = lossPoint; 
                cmd0 = cmd; 
            }        
        }
    }  
    if(PatchPoint > 0 && loss0 > PatchPoint * BasePoint && loss0 < (PatchPoint + 50) * BasePoint)
	{	    
		if(cmd0 == Trend) rtn = cmd0;			
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
   	if(adjustPoint < MIN_MovePoint) 
   	    adjustPoint = MIN_MovePoint;	
   	else if(adjustPoint > MAX_MovePoint)
   	    adjustPoint = MAX_MovePoint;
   	    	
	adjustPoint = adjustPoint * BasePoint;  
   	
    bool tobemodify = false; 
	
	if (cmd == OP_BUY)
	{
	    stoploss = NormalizeDouble(Bid - adjustPoint, Digits);			
		if (stoploss > openprice && stoploss > oldstoploss) 
		    tobemodify = true;	
	}
	else
	{
	    clr = clrRed;
		stoploss = NormalizeDouble(Ask + adjustPoint, Digits);			
		if (stoploss < openprice && stoploss < oldstoploss) 
		    tobemodify = true;		
	}	
	
	bool rtn = false;
	if(tobemodify)
	{
        
        if (OrderModify(ticket, openprice, stoploss, takeprofit, 0, clr))
        {
            rtn = true;        
            //Comment("\r\n adjustPoint=", adjustPoint/BasePoint);
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
		case 12:
			sendConfig = SendConfig12;
			break;
		case 4:
			sendConfig = SendConfig4;
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
		if(j==4 || j==5)
		{			
			lots = StringToDouble(result2[0]); 
			maxOrder = StringToInteger(result2[1]); 
			sendSpan = StringToInteger(result2[2]); 
			movePoint = StringToInteger(result2[3]);
			if (j==5)
				patchPoint = StringToInteger(result2[4]);
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

int OnInit()
{
    EventSetTimer(300);
    //add(1); return;    

    StrategyCount = 0;
	BaseStrategy::TotalOrderLimit = 0;	
	ArrayResize(Stg,0);
	
    if (UseTrade11) AssembleStrategy(11);	
    if (UseTrade12) AssembleStrategy(12);
    if (UseTrade4) AssembleStrategy(4);
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

    return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
    for(int i=0; i < ArraySize(Stg); i++)
    {
        delete Stg[i];        
    }
    ArrayResize(Stg, 0);
    
}

datetime LastModifyTime; 
void OnTick()
{
    //Setlable("时间栏","市场时间："+Year()+"-"+Month()+"-"+Day(),5,15,9,"Verdana",Red);    
	if (TimeCurrent() < LastModifyTime + Frequency) return; //Frequency秒
	Trend = GetTradeSign();
	
	if(TimeCurrent() > lastDuichongTime + 36000)
	{
	    Duichong();	    
	}
	
	for (int i = 0; i < OrdersTotal(); i++)
	{
		if (!SelectOrder(i)) continue;
		
		int cmd = OrderType();
		if(Trend == 9)
		{
		    CloseOrder(cmd);	
		}
		else if(Trend == 10 && cmd == 0) 
		{
		    CloseOrder(cmd);		   
		}
		else if(Trend == 11 && cmd == 1)
		{
		    CloseOrder(cmd);
		}
		else
		    ModifyOrder(cmd);				
	} 	
	
	if(Trend >= 0)
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
    double loss = 0;
    
    for (int j = OrdersTotal() - 1; j >=0; j--)
    {			  
        if (!SelectOrder(j)) continue;  
        double price = OrderOpenPrice();
        int cmd = OrderType();  

        if(OrderLots() > 0 && (cmd == 0 && price - Bid > DuichongPoint * BasePoint || cmd == 1 && Ask - price  > DuichongPoint * BasePoint))
        {  
            size++;    
            ArrayResize(LostOrders, size);   
            LostOrders[size-1].CMD = cmd;
            LostOrders[size-1].Ticket = OrderTicket();
            LostOrders[size-1].Lots = OrderLots();
            if(cmd == 0)
                LostOrders[size-1].LossPoint = price - Bid;
            else
                LostOrders[size-1].LossPoint = Ask - price;       
            loss += LostOrders[size-1].Lots * LostOrders[size-1].LossPoint;
        }      
    }  
    //Setlable("信息栏","亏损单数:"+size+" 亏损：" +DoubleToStr(loss,4) + "  盈利:"+DoubleToStr(profit,4),300,5,8,"Verdana",Red);
    
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
                //Print("DC:lossed=", lossed, ",profit=", profit,",lots=", lots, ", ticket=", ticket);
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

int GetTradeSign()
{
    int rtn = -1;
  
    double ma1,ma2,ma3;
    if(K1 > 0) ma1 = iMA(NULL, Period4Trend, K1, 0, MODE_SMA, PRICE_CLOSE, 0);
	ma2 = iMA(NULL, Period4Trend, K2, 0, MODE_SMA, PRICE_CLOSE, 0);
	ma3 = iMA(NULL, Period4Trend, K3, 0, MODE_SMA, PRICE_CLOSE, 0);

	if(ma2 > ma3)// && Ask - low < 50 * BasePoint)
	{
        if(K1>0 && ma1 < ma2)
            rtn = -1;
		else
		    rtn = 0;
    }
	else if(ma2 < ma3)// && high - Bid < 50 * BasePoint)
	{
	    if(K1>0 && ma1 > ma2)
            rtn = -1;
		else
		    rtn = 1;
    }
    return(rtn);
};     