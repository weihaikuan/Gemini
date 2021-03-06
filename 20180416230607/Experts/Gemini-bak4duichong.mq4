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
string GetCommands(int magic, double lots, int frame = 0);
void AddConfig(int rsiLimit,int division11,int wprOpen11,int maMargin4,int minMovePoint,int maxMovePoint, int digits,double basePoint, int maxSL, double baseLots, int bcStep);
void CleanOrder(int historyFlag);
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
extern int BcStep = 100;

extern string str11 = "";  //ST 11 
extern bool UseTrade11 = true;     //......use?
extern ENUM_TIMEFRAMES Period11 = PERIOD_M5;
extern double Lots11 = 0.01; 
extern int Division11 = 50; //......ADX limit
extern int WprOpen11 = 6; //......WPR limit(Open)

extern string str12 = "";  //TRADE 12
extern bool UseTrade12 = false;     //......Apply?
extern ENUM_TIMEFRAMES Period12 = PERIOD_M5;
extern double Lots12 = 0.01; 

extern string str4 = ""; //TRADE 4
extern bool UseTrade4 = false; //......Apply?
extern double Lots4 = 0.01; 
extern int MAMargin4 = 150;   //......MA-700 Margin

double BasePoint = 0.0001; 
double StartMoney = 0;
datetime LastTimeT; 

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
	
double g_lots = 0;
int g_magic = 0;
int g_timeframe = 0;

int OnInit()
{
    string cmd = GetCommands(0,0,0);
    if (cmd == NULL) 
    {
        Alert("Your EA has been expired. please renew your contract!");
        return(INIT_FAILED);
    }
    
    EventSetTimer(300);

    if (UseTrade11)
    {
        g_lots = Lots11;
        g_magic = 11;
        g_timeframe = Period11;
    }	
    if (UseTrade12) 
    {
        g_lots = Lots12;
        g_magic = 12;
        g_timeframe = Period12;
    }	
    if (UseTrade4) 
    {
        g_lots = Lots4;
        g_magic = 4;
    }	
    
	LastTimeT = 0;
	StartMoney = AccountEquity();	

    AddConfig(RSILimit, Division11, WprOpen11, MAMargin4, MinMovePoint, MaxMovePoint, Digits, BasePoint, MaxSL, BaseLots, BcStep);
    
    return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason)
{
}

void OnTick()
{
    //Setlable("时间栏","市场时间："+Year()+"-"+Month()+"-"+Day(),5,15,9,"Verdana",Red);    
	if (TimeCurrent() < LastTimeT + Frequency) return; //Frequency秒

	AddIndicator2DLL();
	AddOrder2DLL(0);	
	AddOrder2DLL(1);
      
	string cmdstr = GetCommands(g_magic, g_lots, g_timeframe);

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
    			color clr = Red;       			
                if(cmd == 0) clr = Blue;
                
	            if(type == 1)
	            {
	                if(cmd == -1) return;  
            		            		
            		if(UseMM)
            		{
            		    double accountEquity = AccountEquity();
            		    if (accountEquity > MaxEquity) accountEquity = MaxEquity;
                		double times = accountEquity / StartMoney;
                		lots *= times * MM;
            		}		
            		if(lots < 0.01) lots = 0.01;
            		if (!CheckLots(lots)) continue;
            		
            		openprice = (cmd == 0? Ask : Bid);            		
            		openprice = NormalizeDouble(openprice, Digits);  
            	    stoploss = NormalizeDouble(stoploss, Digits);  
            	    takeprofit = NormalizeDouble(takeprofit, Digits); 
                    lots = NormalizeDouble(lots, 2); 
                    
            		ticket = OrderSend(Symbol(), cmd, lots, openprice, 3, stoploss, takeprofit, "", magic, 0, clr);
            		if(ticket>=0) 
            		{
            		    Comment("CMD=", cmd, ", Magic=", magic);
            		}    
            		else
            		    Print("下单失败,错误原因："+iGetErrorInfo(GetLastError()));		
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
	                if (cmd == 0)
                		OrderClose(ticket, lots, NormalizeDouble(Bid, Digits), 3, clr);
                	else
                		OrderClose(ticket, lots, NormalizeDouble(Ask, Digits), 3, clr);
	            }  	
    			
    		}   		
        }
    }
    
	LastTimeT = TimeCurrent();
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

int Split2Array(string to_split,string &result[], string sep)
{
    ArrayResize(result,0);
 
    ushort u_sep = StringGetCharacter(sep,0); 

    int k=StringSplit(to_split,u_sep,result); 

    return k;
};

void AddOrder2DLL(int historyFlag)
{
	CleanOrder(historyFlag);
	
	if(historyFlag == 1)
	{
	    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
    	{
    		if (!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;			
    		int ticket = OrderTicket();
    		int cmd = OrderType();
    		double lots = OrderLots();
    		double open = OrderOpenPrice();
    		double close = OrderClosePrice();
    		double stoploss = OrderStopLoss();
    		double takeprofit = OrderTakeProfit();
    		int magic = OrderMagicNumber();
    
    		AddOrder(1, ticket, cmd, lots, open, close, stoploss, takeprofit, magic);
    		
    		break;
    	} 	
	}
	else
	{
	    for (int i = 0; i <= OrdersTotal() - 1; i++)
    	{
    		if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;			
    		int ticket = OrderTicket();
    		int cmd = OrderType();
    		double lots = OrderLots();
    		double open = OrderOpenPrice();
    		double close = OrderClosePrice();
    		double stoploss = OrderStopLoss();
    		double takeprofit = OrderTakeProfit();
    		int magic = OrderMagicNumber();
    
    		AddOrder(0, ticket, cmd, lots, open, close, stoploss, takeprofit, magic);
    	} 	
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
