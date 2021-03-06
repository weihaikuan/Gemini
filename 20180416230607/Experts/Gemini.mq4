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
void Init();
void DeInit();
void AddOrder(int historyFlag, int ticket, int cmd, double lots, double open, double close, double stoploss, double takeprofit, int magic);
double AddIndicator(double &arr[]);
int GetCommand(int &magic, int &magicnumber, double &lots, int maxcount = 0, int frame = 0);
string GetCommands(double profitHis, bool closeall);
void AddConfig(int rsiLimit,int division11,int wprOpen11,int maMargin4,int minMovePoint,
int maxMovePoint, int digits,double basePoint, int maxSL, double baseLots, int bcStep, int startLevel, double bcRate);
void CleanOrder(int historyFlag);
#import

extern double Blance_Rate = 0.5; //balance rate(0.3=30%)
extern bool UseMM = true; //use MM?
extern double MM = 1.0; //MM Rate
extern int MaxSL = 1000; //max SL
extern int MinMovePoint = 40; //min move point
extern int MaxMovePoint = 80; //max move point
extern int Frequency = 5; //move frequency(second)
extern int RSILimit = 90; //RSI limit
//extern ENUM_TIMEFRAMES Period4Trend = PERIOD_W1;//K line
extern int K1 = 5;//K1
extern int K2 = 8;//K2

extern double BaseLots999 = 0.05; // bc base point
extern int StartLevel = 2; // start dc level
extern double BcRate = 2.0; // bc rate (0, 2]
extern int BcStep999 = 100; // bc step (point)
extern int SendFrequency999 = 300; //bc frequency(second)

extern string str11 = "";  //TRADE 11 
extern bool UseTrade11 = true;     //......use?
extern string SendConfig11 = "5,0.01,1,300;5,0.01,1,300"; //setting (K,lots,orders,requency)
extern int Division11 = 25; //......ADX limit
extern int WprOpen11 = 6; //......WPR limit(Open)

extern string str12 = "";  //TRADE 12
extern bool UseTrade12 = false;     //......Apply?
extern string SendConfig12 = "5,0.12,2,300";  //setting (K,lots,orders,requency)

extern string str4 = ""; //TRADE 4
extern bool UseTrade4 = false; //......Apply?
extern string SendConfig4 = "0.01,2,300;0.5,5,300"; //setting (lots,orders,requency)
extern int MAMargin4 = 150;   //......MA-700 Margin

double BasePoint = 0.0001; 
double StartMoney = 0;
int TotalOrderCount = 0;
datetime LastTimeT; 
datetime LastTimeD;

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

bool DoSendOrder(int cmd, double lots, int magic)
{
    if(UseMM)
	{
	    double accountEquity = AccountEquity();
		double times = accountEquity / StartMoney;
		lots *= times * MM;
	}		
	if(lots < 0.01) lots = 0.01;
	if (!CheckLots(lots)) return false;
			
    color clr = clrBlue;    
    if(cmd == 1) clr = clrRed;
	
	double price, stoploss, takeprofit;
    if(cmd == 0)
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
	int ticket = OrderSend(Symbol(), cmd, lots, price, 3, stoploss, takeprofit, IntegerToString(magic), magic, 0, clr);
	if(ticket>=0) 
	{
	    Comment("CMD=", cmd, ", Magic=", magic, ", Lots=", lots);	    		    
	    return(true);	
	}    
	else
	    Print("下单失败,错误原因："+iGetErrorInfo(GetLastError()));			

    return false;
};

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
    int OrderCount;

public:    
    Strategy() {};
    ~Strategy(){};
    
public:  
        
    void SendOrder()
    { 
        if (TimeCurrent() < this.LastSendTime + this.SendSpan) return;

        double lots = this.BaseLots;         
		int cmd = GetCommand(this.Magic, this.MagicNumber, lots, this.OrderCount, this.TimeFrame);
		
		if(cmd == -1) return; 
		
        DoSendOrder(cmd, lots, this.MagicNumber);  
        
        this.LastSendTime = TimeCurrent(); 	
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
	}
	
	string result1[];
	string result2[];
	int k = Split2Array(sendConfig,result1,";");
        
	for(int i=0;i<k;i++)
	{
        double lots;
	    int orderCount, sendSpan, timeFrame;
	    //int dcrate;
	    
		int j = Split2Array(result1[i], result2, ",");
		if(j>=3)
		{			
			if(magic == 11 || magic == 12)
			{
			    timeFrame = StringToInteger(result2[0]); 
			    lots = StringToDouble(result2[1]); 
    			orderCount = StringToInteger(result2[2]); 
    			sendSpan = StringToInteger(result2[3]);     			
			}
			else
			{
			    lots = StringToDouble(result2[0]); 
    			orderCount = StringToInteger(result2[1]); 
    			sendSpan = StringToInteger(result2[2]); 
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
		stg.SendSpan = sendSpan;	
		stg.BaseLots = lots;	
		
		TotalOrderCount += orderCount;
	}   
}


int OnInit()
{
    Init();
    
    if(!IsDemo()) 
    {
        Alert("This version is only for testing or demo!");
        return INIT_FAILED;
    }
    if(!IsDllsAllowed())
    {
        Alert("This EA need DLL allowed! please turn it on.");
        return INIT_FAILED;
    }    
    
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

    if(ArraySize(Stg)==0)
    {
        Print("Error: You must select at least 1 strategy!");
        return(INIT_FAILED);
    } 	
    LastTimeD = TimeCurrent();
	LastTimeT = TimeCurrent();
	StartMoney = AccountEquity();	

    AddConfig(RSILimit, Division11, WprOpen11, MAMargin4, MinMovePoint, MaxMovePoint, Digits, BasePoint, MaxSL, BaseLots999, BcStep999, StartLevel, BcRate);
    
    return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
    DeInit();
    for(int i=0; i < ArraySize(Stg); i++)
    {
        delete Stg[i];        
    }
    ArrayResize(Stg, 0);  
}
double lastlow = 0;
double lastHigh = 0;
void OnTick()
{
    Setlable("状态栏","总单数："+ OrdersTotal(),500,2,9,"Verdana",Red);    
	if (TimeCurrent() < LastTimeT + Frequency) return; //Frequency秒

	AddIndicator2DLL();
	AddOrder2DLL(0);
	
	if(TimeCurrent() > LastTimeD + SendFrequency999)
	{
	    bool closeall = false;
    	double profit = GetProfitFromHistoryOrder(LastTimeD, closeall);
    	string cmdstr = GetCommands(profit, closeall);    	                        
        LastTimeD = TimeCurrent();
        
    	if(cmdstr != "" && cmdstr != NULL)    	
    	{ 
    	    Print("cmdstr=", cmdstr);
        	string result1[];
        	string result2[];
        	int k = Split2Array(cmdstr,result1,";");
        	for(int i=0;i<k;i++)
        	{
        		int j = Split2Array(result1[i], result2, ",");
        		if(j==8)
        		{			
        			int type = StringToInteger(result2[0]); 
        			int cmd = StringToInteger(result2[1]); 
        			int ticket = StringToInteger(result2[2]);
        		    double lots = StringToDouble(result2[3]);
        			double openprice = StringToDouble(result2[4]);
        			double stoploss = StringToDouble(result2[5]); 
        			double takeprofit = StringToDouble(result2[6]);  
        			int magic = StringToInteger(result2[7]); 
        			color clr = Blue;       			
                    if(cmd == 1) clr = Red;
                    
                    //if(stoploss!=lastlow || takeprofit!=lastHigh) 
                    //{
                    //    lastlow = stoploss;
                    //    lastHigh = takeprofit;
                    //    Print("LastHigh:", takeprofit, ",LastLow:", stoploss);
                    //}
                        
    	            if(type == 1)
    	            {
    	                if (DoSendOrder(cmd, lots, magic))
                        {
                            //Print("modifystr=", mdstr, ",cmd=", cmd, ",ticket=", ticket);
                        }
                        else
                        {
                            Print("Sell单(",OrderTicket(),")修改失败,错误原因："+iGetErrorInfo(GetLastError()));
                        }
    	            }
    	            else if(type == 2)
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
    	            else if(type == 3)
    	            {
    	                if(cmd == 0)
                    		OrderClose(ticket, lots, NormalizeDouble(Bid, Digits), 3, clr);
                    	else
                    		OrderClose(ticket, lots, NormalizeDouble(Ask, Digits), 3, clr);
                    		
                    	Print("DUICHONG=", cmd, ", ticket=", ticket, ", Lots=", lots);
                    	
    	            }  	
    	            else if(type == 4)
    	            {
    	                Print("debug:", cmdstr);
    	            }
        			
        		}   	
        		
        		Sleep(10);	
            }
        }
    }
	
	for(int i=0;i<ArraySize(Stg);i++)
    {
        Stg[i].SendOrder();
    }	
	
	LastTimeT = TimeCurrent();
};

bool CloseOrder(int cmd, int ticket, double lots)
{    	    
    bool rtn = false;
		
    if (cmd == 0)
		rtn = OrderClose(ticket, lots, NormalizeDouble(Bid, Digits), 3, clrBlue);
	else
		rtn = OrderClose(ticket, lots, NormalizeDouble(Ask, Digits), 3, clrRed);
	
	if(!rtn) Print("订单(",ticket,")关闭失败,错误原因："+iGetErrorInfo(GetLastError()));	       	
	
	return(rtn);
};

bool CloseOrder(int cmd)
{    	    
    bool rtn = false;
		
    if (cmd == 0)
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

int Split2Array(string to_split,string &result[], string sep)
{
    ArrayResize(result,0);
 
    ushort u_sep = StringGetCharacter(sep,0); 

    int k=StringSplit(to_split,u_sep,result); 

    return k;
};

double GetProfitFromHistoryOrder(datetime time, bool &closeall)
{
	if(OrdersHistoryTotal() == 0) return(0); 
	
	double profit = 0;
	for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
	{
		if (!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;		
		if(OrderCloseTime() < time) break;				

        double cmd = OrderType();
		double lots = OrderLots();
		double open = OrderOpenPrice();
		double stoploss = OrderStopLoss();
		if(cmd == 0 && stoploss > open)
	        profit += (stoploss - open) * lots;		    
		else if(cmd == 1 && open > stoploss)
		    profit += (open - stoploss) * lots;  
		
		if(OrderMagicNumber() == 888) closeall = true;      
	} 	
	
	return(profit);
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
	
	if(total == 0) return;
	
	for (int i = total - 1; i >= 0; i--)
	{
		if (!OrderSelect(i,SELECT_BY_POS,type)) continue;		
		
		if(historyFlag == 1 && OrderCloseTime() < LastTimeD) break;
		
		int ticket = OrderTicket();
		int cmd = OrderType();
		double lots = OrderLots();
		double open = OrderOpenPrice();
		double close = OrderClosePrice();
		if(close < 0) close = 0;
		double stoploss = OrderStopLoss();
		double takeprofit = OrderTakeProfit();
		int magic = OrderMagicNumber();
		//Print("openTime2Int=",openTime2Int,",closeTime2Int=",closeTime2Int,",OrderCloseTime()=", OrderCloseTime(), ",OrderOpenTime=",OrderOpenTime());
		AddOrder(historyFlag, ticket, cmd, lots, open, close, stoploss, takeprofit, magic);
	} 	
};

void AddIndicator2DLL()
{
	double arrInd[38];
	arrInd[0] = iADX(NULL,PERIOD_M5,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[1] = iADX(NULL,PERIOD_M15,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[2] = iADX(NULL,PERIOD_M30,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[3] = iADX(NULL,PERIOD_H1,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[4] = iADX(NULL,PERIOD_H4,14,PRICE_CLOSE,MODE_MAIN,0);
	arrInd[5] = iWPR(NULL,PERIOD_M5,18, 0);;
	arrInd[6] = iWPR(NULL,PERIOD_M15,18, 0);;
	arrInd[7] = iWPR(NULL,PERIOD_M30,18, 0);;
	arrInd[8] = iWPR(NULL,PERIOD_H1,18, 0);;
	arrInd[9] = iWPR(NULL,PERIOD_H4,18, 0);;
	arrInd[10] = iMA(NULL,PERIOD_M5,700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[11] = iMA(NULL,PERIOD_M15,700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[12] = iMA(NULL,PERIOD_M30,700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[13] = iMA(NULL,PERIOD_H1,700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[14] = iMA(NULL,PERIOD_H4,700, 0, MODE_SMMA, PRICE_CLOSE, 1); ;
	arrInd[15] = iClose(NULL,PERIOD_M5,1);
	arrInd[16] = iClose(NULL,PERIOD_M15,1);
	arrInd[17] = iClose(NULL,PERIOD_M30,1);
	arrInd[18] = iClose(NULL,PERIOD_H1,1);
	arrInd[19] = iClose(NULL,PERIOD_H4,1);
	arrInd[20] = iRSI(NULL,PERIOD_M5,14, PRICE_CLOSE, 1);
	arrInd[21] = iRSI(NULL,PERIOD_M15,14, PRICE_CLOSE, 1);
	arrInd[22] = iRSI(NULL,PERIOD_M30,14, PRICE_CLOSE, 1);
	arrInd[23] = iRSI(NULL,PERIOD_H1,14, PRICE_CLOSE, 1);
	arrInd[24] = iRSI(NULL,PERIOD_H4,14, PRICE_CLOSE, 1);
	arrInd[25] = iATR(NULL, PERIOD_H1, 19, 1);
	arrInd[26] = iMA(NULL, PERIOD_H1, 1, 0, MODE_EMA, PRICE_CLOSE, 1);
	arrInd[27] = Bid;
	arrInd[28] = Ask;
	arrInd[29] = iHigh(NULL, PERIOD_H4, 1);
    arrInd[30] = iLow(NULL, PERIOD_H4, 1);    
    arrInd[31] = iRSI(NULL, PERIOD_W1, 14, PRICE_CLOSE, 0);
    arrInd[32] = iMA(NULL, PERIOD_H4, K1, 0, MODE_SMA, PRICE_CLOSE, 1);
	arrInd[33] = iMA(NULL, PERIOD_H4, K2, 0, MODE_SMA, PRICE_CLOSE, 1);		
	arrInd[34] = iMA(NULL, PERIOD_D1, K1, 0, MODE_SMA, PRICE_CLOSE, 0);
	arrInd[35] = iMA(NULL, PERIOD_D1, K2, 0, MODE_SMA, PRICE_CLOSE, 0);
	arrInd[36] = iMA(NULL, PERIOD_W1, K1, 0, MODE_SMA, PRICE_CLOSE, 0);
	arrInd[37] = iMA(NULL, PERIOD_W1, K2, 0, MODE_SMA, PRICE_CLOSE, 0);
    
    for(int i=0; i<=37; i++)
    {
        if(arrInd[i] < 0) arrInd[i] = 0;
    }
	AddIndicator(arrInd);
}
