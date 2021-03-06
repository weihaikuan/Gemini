//+------------------------------------------------------------------+
//|                                                       WPR.mq4 |
//|                                      Copyright 2017, Wei Haikuan |
//|                    https://www.mql5.com/zh/users/weihaikuan/blog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, GEMINI"
#property link      "https://www.mql5.com/zh/users/weihaikuan/blog"
#property version   "1.0"
#property description ""
#property description ""
#property strict

extern double Blance_Rate = 0.5; //账户余额比例(0.3=30%)
extern bool UseMM = false; //使用复利模式?
extern double MM = 1.0; //复利率

extern ENUM_TIMEFRAMES Period4Trend = PERIOD_W1;//趋势图K线周期
extern int K1 = 0;//趋势图 K线1
extern int K2 = 10;//趋势图 K线2
extern int K3 = 20;//趋势图 K线3
extern double Percentage4hedging = 1; //对冲百分比
extern int DuichongPoint = 50; //开始对冲点数

extern int Frequency = 5; //跟损时间间隔（秒）)
extern int MinMovePoint = 40; //最小跟损点
extern int MaxMovePoint = 80; //最大跟损点
extern int OrderCount = 5;
extern int SendSpan = 900;
extern double BaseLots = 0.5;
extern int Step = 150;
    

double BasePoint = 0.0001; 
int Trend;
double StartMoney = 0;
int TotalOrderCount = 0;
datetime LastModifyTime; 

struct CTrade
{
    int CMD;
    double Lots;
    int Level;
    int StopLoss;
};

class CBeacon
{
private:
    int trend;
    double price;
    datetime openTime;
    
    double baseLots;
    int step;

public:
    CBeacon(double dLots, int iStep)
    {
        trend = GetTradeSign();
        price = Ask;
        openTime = TimeCurrent(); 
        this.baseLots = dLots;
        this.step = iStep;       
    };
    
    CTrade GetSignal()
    {
        int cmd; double lots; int loss;
        double sl;
        loss = (Ask - this.price) / BasePoint / step;
        
        if(MathAbs(loss) < 1) 
            cmd = -1;
        else
        {
            bool moveLight = false;
            if(trend == 0)
            {
                if(Ask > this.price)
                    cmd = 1;
                else
                {
                    cmd = 0;   
                    moveLight = true;
                }                 
            }
            else
            {
                if(Ask > this.price)
                {
                    cmd = 1;
                    moveLight = true;
                }
                else
                    cmd = 0;                    
            }
            switch(MathAbs(loss))
            {
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                    lots = this.baseLots * 1.2; 
                    sl = 1300;
                    break;
                default:
                    lots = this.baseLots  / MathAbs(loss);
                    sl = 200;
                    break;
            }
            
            if(moveLight)
            {
                this.trend = Trend;
                this.price = Ask;
                this.openTime = TimeCurrent();
                Setlable("信号灯","Trend："+trend+"   "+Year()+"-"+Month()+"-"+Day(),250,1,9,"Verdana",Red); 
            }
        }
                
        CTrade signal;
        signal.CMD = cmd;
        signal.Lots = lots;
        signal.Level = MathAbs(loss);
        signal.StopLoss = sl;

        return signal;
    };   
};

class Strategy
{
public:
    int Magic;
    datetime LastSendTime;
    int SendSpan;
    double OrderCount;

public:    
    Strategy() {};
    ~Strategy(){};
    
private:    
    bool CheckLots(int cmd, double lots, int level)
    {
        int rtn = true;
    	if (lots<=0) return false;
    	
        if (AccountEquity() * Blance_Rate > AccountFreeMargin())
        {
            Print("账户资金余额已低于 ", Blance_Rate * 100 , "%, 不再下单了！账户净值=", AccountEquity(), ",  可用预付款=",  AccountFreeMargin());
            rtn = false;
        }
        else
        {    
        	double lotsize = MarketInfo(Symbol(), MODE_LOTSIZE);
        	if (AccountFreeMargin() < Ask * lots * lotsize / AccountLeverage()) 
        	{
        		Print("账户资金不足. 下单量 = ", lots, " , 自由保证金 = ", AccountFreeMargin());
        		rtn = false;
        	}
        	else
        	{
        	    int orderCount = 0;
            	for (int i = OrdersTotal() - 1; i >= 0; i--)
            	{
            		if (!SelectOrder(i)) continue;
            		if(OrderMagicNumber() == level)
            			orderCount++;		
            	}
                if (orderCount >= this.OrderCount) rtn = false;
        	}
        }
        
        return(rtn);
        
    };
      
    double GetBoFu(ENUM_TIMEFRAMES timeframe, int shift)
    {
    	double high = iHigh(NULL, timeframe, shift);
    	double low = iLow(NULL, timeframe, shift);
    	return(high - low);
    };

    bool DoSendOrder(int cmd, double lots, int istoploss, int level)
    {
        color clr = clrBlue;    
        if (cmd == 1) clr = clrRed;
    	
    	double price, stoploss, takeprofit;
        if (cmd == 0)
        {
    	    price = NormalizeDouble(Ask, Digits);  
    	    stoploss = price - istoploss * BasePoint;
    	    takeprofit = price + 2000 * BasePoint;  
    	}	    
    	else
    	{
    	    price = NormalizeDouble(Bid, Digits); 	
    	    stoploss = price + istoploss * BasePoint;
    	    takeprofit = price - 2000 * BasePoint;
    	}  	
    
        lots = NormalizeDouble(lots, 2); 
		int ticket = OrderSend(Symbol(), cmd, lots, price, 3, stoploss, takeprofit,"", level, 0, clr);
		if(ticket>=0) 
		{
		    Setlable("交易", "cmd = "+cmd+" lots = "+ lots+", level = "+level, 400,1,9,"Verdana",Red);

		    this.LastSendTime = TimeCurrent();		    
		    return(true);	
		}    
		else
		    Print("下单失败,错误原因："+iGetErrorInfo(GetLastError()));			

        return false;
    };    
    

public:  
        
    void SendOrder()
    { 
        if (TimeCurrent() < this.LastSendTime + this.SendSpan) return; 
        
		CTrade trade = Beacon.GetSignal();
		int cmd = trade.CMD;
		double lots = trade.Lots;	
	    
		if(UseMM)
		{
    		double times = AccountEquity() / StartMoney;
    		lots *= times * MM;
		}
		
		if(cmd == -1) return;	

		if (!CheckLots(cmd, lots, trade.Level)) return;		

        DoSendOrder(cmd, lots, trade.StopLoss, trade.Level);   	
    };

 
};

Strategy *STG;
CBeacon *Beacon;

int OnInit()
{
    STG = new Strategy();
    STG.LastSendTime = TimeCurrent();
    STG.OrderCount = OrderCount;
    STG.SendSpan = SendSpan;
    
    Beacon = new CBeacon(BaseLots, Step);
    
	LastModifyTime = 0;
	StartMoney = AccountEquity();

    return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
    delete STG;  
    delete Beacon;    
}

void OnTick()
{
   
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
		ModifyOrder(cmd);				
	} 	
	
	STG.SendOrder();
    	
	LastModifyTime = TimeCurrent();
};

int GetTradeSign()
{
    int rtn = -1;
  
    double ma2,ma3;

	ma2 = iMA(NULL, Period4Trend, K2, 0, MODE_SMA, PRICE_CLOSE, 0);
	ma3 = iMA(NULL, Period4Trend, K3, 0, MODE_SMA, PRICE_CLOSE, 0);

	if(ma2 > ma3)// && Ask - low < 50 * BasePoint)
	{
        rtn = 0;
    }
	else if(ma2 < ma3)// && high - Bid < 50 * BasePoint)
	{
	    rtn = 1;
    }
    return(rtn);
};  

int GetBoFu(ENUM_TIMEFRAMES timeframe, int shift)
{
	double high = iHigh(NULL, timeframe, shift);
	double low = iLow(NULL, timeframe, shift);
	int bofu = (high - low) / BasePoint;
	return bofu;
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

int GetSendConfigs(string to_split,string &result[], string sep)
{
    ArrayResize(result,0);
 
    ushort u_sep = StringGetCharacter(sep,0); 

    int k=StringSplit(to_split,u_sep,result); 

    return k;
};

bool ModifyOrder(int cmd)
{
    double openprice = OrderOpenPrice();
    if (cmd == 0 && Bid < openprice || cmd == 1 && Ask > openprice)
	{
	    return true;
	}	
	
   	int ticket = OrderTicket();  	
   	double oldstoploss = OrderStopLoss();
   	double stoploss = 0;
   	double takeprofit = OrderTakeProfit();   	
   	color clr = clrBlue;   	
   	double adjustPoint = 5;
   
	adjustPoint = GetBoFu(PERIOD_H4, 1);	
   	if(adjustPoint < MinMovePoint) 
   	    adjustPoint = MinMovePoint;	
   	else if(adjustPoint > MaxMovePoint)
   	    adjustPoint = MaxMovePoint;
	   	   	
   	//Comment("Move = ", adjustPoint);
	adjustPoint = adjustPoint * BasePoint;
    	
    bool tobemodify = false; 
	if (cmd == 0)
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
            //Print("cmd=", cmd, ",ticket=", ticket);
        }
        else
        {
            Print("Sell单(",OrderTicket(),")修改失败,错误原因："+iGetErrorInfo(GetLastError()));	
            return(false);
        }
    }   
    
	return (rtn);
};

struct CLost
{
    int CMD;
    int Ticket;
    double LossPoint;
    double Lots;
};
datetime lastDuichongTime;
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

        if(OrderLots() > 0.01 && (cmd == 0 && price - Bid > DuichongPoint * BasePoint || cmd == 1 && Ask - price  > DuichongPoint * BasePoint))
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
                lots = NormalizeDouble(lots, 2);
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