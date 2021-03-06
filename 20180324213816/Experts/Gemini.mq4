//+------------------------------------------------------------------+
//|                                                       WPR.mq4 |
//|                                      Copyright 2017, Wei Haikuan |
//|                    https://www.mql5.com/zh/users/weihaikuan/blog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, GEMINI"
#property link      "https://www.mql5.com/zh/users/weihaikuan/blog"
#property version   "1.0"
#property description "This is trial version. the expired date is 2018-12-20."
#property description ""
#property strict

#import "Gemini.dll"
void AddOrder(int historyFlag, int ticket, int cmd, double lots, double open, double close, double stoploss, double takeprofit, int magic);
double AddIndicator(double &arr[]);
//int GetCommand(int magic, int frame, int patchPoint);
int GetCommand(int &magic, int &magicnumber, double &lots, int maxcount = 0, int frame = 0);
void AddConfig(int rsiLimit,int division11,int wprOpen11,int maMargin4,int minMovePoint,int maxMovePoint, int digits,double basePoint, int maxSL, double baseLots, double bcRate, int bcStep,double PercentOf1, double PercentOf2);
void CleanOrder(int historyFlag);
string CloseLossedOrder();
string ModifyOrder();
#import

extern double Blance_Rate = 0.5; //balance rate(0.3=30%)
extern double MaxEquity = 300000; //Max Account Equity
extern bool UseMM = true; //use MM?
extern double MM = 1.0; //MM Rate
extern int MaxSL = 1000; //max SL
extern int MinMovePoint = 40; //min move point
extern int MaxMovePoint = 80; //max move point
extern int Frequency = 5; //move frequency(second)
extern int RSILimit = 90; //RSI limit
extern ENUM_TIMEFRAMES Period4Trend = PERIOD_W1;//K line
extern int K1 = 2;//K1
extern int K2 = 5;//K2
extern int K3 = 8;//K3

extern double BaseLots = 0.05;
double BcRate = 1;
extern int BcStep = 100;

extern string str999 = "";  //ST 999
extern bool UseTrade999 = true;     //......use?
extern int SendFrequency999 = 300; //send frequency(second)
extern int DCFrequnency = 36000; //hedging frequency(second)
extern double PercentOf1 = 0.05; //unidirectional
extern double PercentOf2 = 0.1;//bidirectional

extern string str11 = "";  //ST 11 
extern bool UseTrade11 = true;     //......use?
extern string SendConfig11 = "5,0.01,1,300;5,0.02,1,300"; //setting (K,lots,orders,requency)
extern int Division11 = 50; //......ADX limit
extern int WprOpen11 = 6; //......WPR limit(Open)

extern string str12 = "";  //TRADE 12
extern bool UseTrade12 = false;     //......Apply?
extern string SendConfig12 = "5,0.12,2,300";  //setting (K,lots,orders,requency)

extern string str4 = ""; //TRADE 4
extern bool UseTrade4 = false; //......Apply?
extern string SendConfig4 = "0.01,2,300;0.5,5,300"; //setting (lots,orders,requency)
extern int MAMargin4 = 150;   //......MA-700 Margin

ENUM_TIMEFRAMES Period4BigWPR = PERIOD_H4;//趋势图K线周期
int WprOpenBig = 40; //......WPR限制(大区间)(下单)
int WprCloseBig = 10; //......WPR限制(大区间)(收单)

double BasePoint = 0.0001; 
double StartMoney = 0;
int TotalOrderCount = 0;
datetime LastTimeT; 
datetime LastTimeD;

class Strategy
{
public:
    int Magic;
    int MagicNumber;
    double BaseLots;
    datetime LastSendTime;
    int TimeFrame;
    int SendSpan;
    int PatchPoint;
    double DCRate;
    double OrderCount;

public:    
    Strategy() {};
    ~Strategy(){};
    
private:    
    bool CheckLots(double lots)
    {
    	if (lots<=0) return false;
    	
    	//check account safty.
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
        
    	return(true);
    }

    bool DoSendOrder(int cmd, double lots)
    {
        color clr = clrBlue;    
        if (cmd == 1) clr = clrRed;
    	
    	double price, stoploss, takeprofit;
        if (cmd == 0)
        {
    	    price = NormalizeDouble(Ask, Digits);  
    	    stoploss = price - MaxSL * BasePoint;
    	    takeprofit = price + MaxSL * BasePoint;  
    	}	    
    	else
    	{
    	    price = NormalizeDouble(Bid, Digits); 	
    	    stoploss = price + MaxSL * BasePoint;
    	    takeprofit = price - MaxSL * BasePoint;
    	}  	
    
        lots = NormalizeDouble(lots, 2); 
		int ticket = OrderSend(Symbol(), cmd, lots, price, 3, stoploss, takeprofit, IntegerToString(MagicNumber), this.MagicNumber, 0, clr);
		if(ticket>=0) 
		{
		    Comment("CMD=", cmd, ", Magic=", this.MagicNumber);
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

        double lots = this.BaseLots;         
		int cmd = GetCommand(this.Magic, this.MagicNumber, lots, this.OrderCount, this.TimeFrame);

	    //Print("Magic=" + Magic + ",MagicNumber=" + MagicNumber + ",cmd=" + cmd + ",TimeFrame=" + TimeFrame + ",PatchPoint=" + PatchPoint);	    	
		
		if(cmd == -1) return;  
		//Print("OK: Magic=" + Magic + ",MagicNumber=" + MagicNumber + ",cmd=" + cmd + ",TimeFrame=" + TimeFrame + ",PatchPoint=" + PatchPoint);	
		
		if(UseMM)
		{
		    double accountEquity = AccountEquity();
		    if (accountEquity > MaxEquity) accountEquity = MaxEquity;
    		double times = accountEquity / StartMoney;
    		lots *= times * MM;
		}		
		if(lots < 0.01) lots = 0.01;
		if (!CheckLots(lots)) return;
		
        DoSendOrder(cmd, lots);   	
    };

};

Strategy *Stg[];
	
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
			sendConfig = "1,2,3";
			break;	
	}
	
	string result1[];
	string result2[];
	int k = GetSendConfigs(sendConfig,result1,";");
        
	for(int i=0;i<k;i++)
	{
        double lots;
	    int orderCount, sendSpan, patchPoint, timeFrame;
	    //int dcrate;
	    
		int j = GetSendConfigs(result1[i], result2, ",");
		if(j>=3)
		{			
			if(magic == 11 || magic == 12)
			{
			    timeFrame = StringToInteger(result2[0]); 
			    lots = StringToDouble(result2[1]); 
    			orderCount = StringToInteger(result2[2]); 
    			sendSpan = StringToInteger(result2[3]);     			
    			patchPoint = 0;
			}
			else
			{
			    lots = StringToDouble(result2[0]); 
    			orderCount = StringToInteger(result2[1]); 
    			sendSpan = StringToInteger(result2[2]); 
    			patchPoint = 0;
			}
		
		}
		else
		{
			Print("Error: Trade config is not correct! the EA can not be applied."); return;
		}

		Strategy *stg = new Strategy();
		int size=ArraySize(Stg)+1;
		ArrayResize(Stg,size);
		Stg[size-1]=stg;		    
		
		stg.Magic = magic;
		stg.MagicNumber = magic*10+i;
		stg.TimeFrame = timeFrame;		
		stg.OrderCount = orderCount;
		if(magic == 999)
		{
		    stg.SendSpan = SendFrequency999;
		    stg.BaseLots = BaseLots;
		}
		else
		{
		    stg.SendSpan = sendSpan;	
		    stg.BaseLots = lots;
		}		
		stg.PatchPoint = patchPoint;
		//stg.DCRate = dcrate;
		
		TotalOrderCount += orderCount;
	}   
}


int OnInit()
{
    double lots = 0;
    int magic = 0;
    int magicnumber = 0;
    int cmd = GetCommand(magic, magicnumber, lots);
    if (cmd == -999) 
    {
        Alert("Your EA has been expired. please renew your contract!");
        return(INIT_FAILED);
    }
    
    EventSetTimer(300);
	ArrayResize(Stg,0);
    if (UseTrade11) AssembleStrategy(11);	
    if (UseTrade12) AssembleStrategy(12);
    if (UseTrade4) AssembleStrategy(4);
	if (UseTrade999) AssembleStrategy(999);
    if(ArraySize(Stg)==0)
    {
        Print("Error: You must select at least 1 strategy!");
        return(INIT_FAILED);
    } 	
	LastTimeT = 0;
	StartMoney = AccountEquity();	

    AddConfig(RSILimit, Division11, WprOpen11, MAMargin4, MinMovePoint, MaxMovePoint, Digits, BasePoint, MaxSL, BaseLots, BcRate, BcStep,PercentOf1,PercentOf2);
    
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

void OnTick()
{
    //Setlable("时间栏","市场时间："+Year()+"-"+Month()+"-"+Day(),5,15,9,"Verdana",Red);    
	if (TimeCurrent() < LastTimeT + Frequency) return; //Frequency秒

	AddIndicator2DLL();
	AddOrder2DLL(0);
	
	if(true)
	{
    	string mdstr = ModifyOrder();	
    	if(mdstr != "" && mdstr != NULL)    	
    	{ 
        	string result1[];
        	string result2[];
        	int k = GetSendConfigs(mdstr,result1,";");
        	for(int i=0;i<k;i++)
        	{
        	    int cmd, ticket;
        	    double openprice;
        	    double stoploss;
        	    double takeprofit;
        	    color clr = Red;
        	    
        		int j = GetSendConfigs(result1[i], result2, ",");
        		if(j==5)
        		{			
        			cmd = StringToDouble(result2[0]); 
        			ticket = StringToInteger(result2[1]); 
        			openprice = StringToDouble(result2[2]);
        			stoploss = StringToDouble(result2[3]); 
        			takeprofit = StringToDouble(result2[4]);  
        			if(cmd == 0) clr = Blue;
        			
        			if(ticket > 0)
        			{
            			if (OrderModify(ticket, openprice, stoploss, takeprofit, 0, clr))
                        {
                            //Print("modifystr=", mdstr, ",cmd=", cmd, ",ticket=", ticket);
                        }
                        else
                        {
                            Print("Sell单(",OrderTicket(),")修改失败,错误原因："+iGetErrorInfo(GetLastError()));
                        }
                    }
        		}   		
            }
        }
        LastTimeT = TimeCurrent();
    }	
    
	if(true && TimeCurrent() > LastTimeD + DCFrequnency)
	{	    
	    string dcstr = CloseLossedOrder();	 
	    if(dcstr != "" && dcstr != NULL)
    	{
    	    //Print("dsr=", dcstr);
    	    string result1[];
        	string result2[];
        	int k = GetSendConfigs(dcstr,result1,";");
            
        	for(int i=0;i<k;i++)
        	{
                double lots;
        	    int cmd, ticket;
        	    color clr = Red;
        	    
        		int j = GetSendConfigs(result1[i], result2, ",");
        		if(j==3)
        		{			
        			cmd = StringToDouble(result2[0]); 
        			ticket = StringToInteger(result2[1]); 
        			lots = StringToDouble(result2[2]);
        			if(cmd == 0) clr = Blue;
        			
        			lots = NormalizeDouble(lots, 2);
        			if(lots > 0)
        			{
        			    CloseOrder(cmd, ticket, lots);
                        Comment("DUICHONG: ", ticket, " Lots:", lots);
                        Print("DUICHONG: ", ticket, " Lots:", lots);
                        
                        LastTimeD = TimeCurrent(); 
                    }
        		}   		
            }      
        }
	}	
	
	for(int i=0;i<ArraySize(Stg);i++)
    {
        Stg[i].SendOrder();
    }	
	
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

void AddOrder2DLL(int historyFlag)
{
	CleanOrder(historyFlag);
	
	int total;
	int type;
	if(historyFlag == 1)
	{
	    total = OrdersHistoryTotal();
	    type = MODE_HISTORY;
	}
	else
	{
	    total = OrdersTotal();
	    type = MODE_TRADES;
	}
	
	for (int i = total - 1; i >= 0; i--)
	{
		if (!OrderSelect(i,SELECT_BY_POS,type)) continue;		
		
		if(historyFlag == 1 && OrderCloseTime() < LastTimeD) break;
		
		int ticket = OrderTicket();
		int cmd = OrderType();
		double lots = OrderLots();
		double open = OrderOpenPrice();
		double close = OrderClosePrice();
		double stoploss = OrderStopLoss();
		double takeprofit = OrderTakeProfit();
		int magic = OrderMagicNumber();
		//Print("openTime2Int=",openTime2Int,",closeTime2Int=",closeTime2Int,",OrderCloseTime()=", OrderCloseTime(), ",OrderOpenTime=",OrderOpenTime());
		AddOrder(historyFlag, ticket, cmd, lots, open, close, stoploss, takeprofit, magic);
	} 	
};

void AddIndicator2DLL()
{
	double arrInd[34];
	arrInd[0] = iADX(NULL,5,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[1] = iADX(NULL,15,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[2] = iADX(NULL,30,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[3] = iADX(NULL,60,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[4] = iADX(NULL,240,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[5] = iWPR(NULL, 4, 18, 0);;
	arrInd[6] = iWPR(NULL, 15, 18, 0);;
	arrInd[7] = iWPR(NULL, 30, 18, 0);;
	arrInd[8] = iWPR(NULL, 60, 18, 0);;
	arrInd[9] = iWPR(NULL, 240, 18, 0);;
	arrInd[10] = iMA(NULL, 5, 700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[11] = iMA(NULL, 15, 700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[12] = iMA(NULL, 30, 700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[13] = iMA(NULL, 60, 700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[14] = iMA(NULL, 240, 700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[15] = iClose(NULL, 5, 1);
	arrInd[16] = iClose(NULL, 15, 1);
	arrInd[17] = iClose(NULL, 30, 1);
	arrInd[18] = iClose(NULL, 60, 1);
	arrInd[19] = iClose(NULL, 240, 1);
	arrInd[20] = iRSI(NULL, 5, 14, PRICE_CLOSE, 1);
	arrInd[21] = iRSI(NULL, 15, 14, PRICE_CLOSE, 1);
	arrInd[22] = iRSI(NULL, 30, 14, PRICE_CLOSE, 1);
	arrInd[23] = iRSI(NULL, 60, 14, PRICE_CLOSE, 1);
	arrInd[24] = iRSI(NULL, 240, 14, PRICE_CLOSE, 1);
	arrInd[25] = iATR(NULL, PERIOD_H1, 19, 1);
	arrInd[26] = iMA(NULL, PERIOD_H1, 1, 0, MODE_EMA, PRICE_CLOSE, 1);
	arrInd[27] = iMA(NULL, Period4Trend, K1, 0, MODE_SMA, PRICE_CLOSE, 0);
	arrInd[28] = iMA(NULL, Period4Trend, K2, 0, MODE_SMA, PRICE_CLOSE, 0);
	arrInd[29] = iMA(NULL, Period4Trend, K3, 0, MODE_SMA, PRICE_CLOSE, 0);
	arrInd[30] = Bid;
	arrInd[31] = Ask;
	arrInd[32] = iHigh(NULL, PERIOD_H4, 1);
    arrInd[33] = iLow(NULL, PERIOD_H4, 1);
	
	AddIndicator(arrInd);
}
