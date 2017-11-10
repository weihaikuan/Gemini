//+------------------------------------------------------------------+
//|                                                       Gemini.mq4 |
//|                                      Copyright 2017, Wei Haikuan |
//|                    https://www.mql5.com/zh/users/weihaikuan/blog |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, 双子星"
#property link      "https://www.mql5.com/zh/users/weihaikuan/blog"
#property version   "1.00"
#property description "目前版本仅供模拟测试用，暂不能用于实际交易！"
#property strict

extern double Blance_Rate = 0.5; //可用预付款比例(0.3=30%)

extern string str1 = "     震荡"; //下面是震荡策略的配置参数
extern bool UseMagic1 = true; //使用突破策略？
extern double Lots1 = 0.1; //  每一笔的手数
extern int Take_Profit1 = 20; //  止盈点数
extern int Stop_Loss1 = 100; //  止损点数

extern string str2 = "     突破"; //下面是突破策略的配置参数
extern bool UseMagic2 = true; //使用突破策略？
extern double Lots2 = 1; //每一笔的手数
extern int Take_Profit2 = 160; //止盈点数
extern int Stop_Loss2 = 25; //止损点数

extern string str3 = "     抄底"; //下面是抄底策略的配置参数
extern bool UseMagic3 = true; //使用突破策略？
extern double Lots3 = 0.1; //每一笔的手数
extern int Take_Profit3 = 160; //止盈点数
extern int Stop_Loss3 = 100; //止损点数
extern int MA_Margin_out = 100; //700期均线外边缘

bool CloseAll = false; //一键close所有的订单

int g_Slippage = 30;
int g_lastTime=0;
double gl_basePoint = 0.0001; 

double wpr_M15_18,close_M15,ma_M15_60;
double ma_M5_700, close_M5,atr_H1_19,ma_H1_1,atr_M5_19,bandup_M5_18,bandmiddle_M5_18,bandlow_M5_18;
double bandup_H1_26,bandlow_H1_26,high_H1,low_H1,atr_M5_60;
double g_lastBid, g_lastAsk;

enum Magic
{
    magic1 = 111,
    magic2 = 222,
    magic3 = 333
};

void CollectIndicators()
{
	//for magic1
	wpr_M15_18 = iWPR(NULL, PERIOD_M15, 18, 1); //WPR震荡指标，-100 ~ 0
	close_M15 = iClose(NULL, PERIOD_M15, 1);
	ma_M15_60 = iMA(NULL, PERIOD_M15, 60, 0, MODE_SMMA, PRICE_CLOSE, 1); //趋势指标
	
	//for magic2
	close_M5 = iClose(NULL, PERIOD_M5, 1);
	atr_H1_19 = iATR(NULL, PERIOD_H1, 19, 1); //ATR震荡指标 0.0008 ~ 0.0031
	ma_H1_1 = iMA(NULL, PERIOD_H1, 1, 0, MODE_EMA, PRICE_CLOSE, 1);	
	atr_M5_19 = iATR(NULL, PERIOD_M5, 19, 1); //ATR震荡指标 0.0008 ~ 0.0031
	bandup_M5_18 = iBands(NULL, PERIOD_M5, 18, 2, 0, PRICE_CLOSE, MODE_UPPER, 1); //布林带，趋势指标
	bandmiddle_M5_18 = iBands(NULL, PERIOD_M5, 18, 2, 0, PRICE_CLOSE, MODE_MAIN, 1);
	bandlow_M5_18 = iBands(NULL, PERIOD_M5, 18, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);	

    //for magic3
    ma_M5_700 = iMA(NULL, PERIOD_M5, 700, 0, MODE_SMMA, PRICE_CLOSE, 1); //趋势指标
	bandup_H1_26 = iBands(NULL, PERIOD_H1, 26, 2, 0, PRICE_CLOSE, MODE_UPPER, 1); //布林带，趋势指标
	bandlow_H1_26 = iBands(NULL, PERIOD_H1, 26, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
	high_H1 = iHigh(NULL, PERIOD_H1, 1);
	low_H1 = iLow(NULL, PERIOD_H1, 1);
	atr_M5_60 = iATR(NULL, PERIOD_M5, 60, 1);  //ATR震荡指标 0.0008 ~ 0.0031

}

void OnTick()
{
    int lastTime = g_lastTime + 300;
	
	CollectIndicators();	
	
	for (int i = OrdersTotal() - 1; i>=0; i--)
	{
		if (!isValidOrder(i)) continue;
		
		int iMagic = OrderMagicNumber();
		bool icloseorder = CloseOrder(iMagic);
		if (icloseorder && TimeCurrent() >= lastTime) 
		{
			ModifyOrder(iMagic);
			g_lastTime = TimeCurrent();
		}        		
	}
		
	if(checkAccountBlance()) CreateOrder();
	
	g_lastAsk = Ask;
	g_lastBid = Bid;
}

void CreateOrder()
{  
    
    int ticket = 0;
	double price = 0;
	double stoploss = 0;
	double takeprofit = 0;
	int magic = magic1;
	int cmd = 0;
	color clr = clrAqua;
	double lots = 0;
	
	int order1 = CheckMagic1();
	int order2 = CheckMagic2();
	int order3 = CheckMagic3();
	
	int order = -1;
	if(UseMagic3 && order3 != -1)
	{
	    order = order3;
	    stoploss = Stop_Loss3;
	    takeprofit = Take_Profit3;
	    magic = magic3;
	    lots = Lots3;
	    
	    if (order3 == 0) 
	        clr = clrAqua;
	    else
	        clr = clrDeepPink;
	}
	else if (UseMagic2 && order2 != -1)
	{
	    order = order2;
	    stoploss = Stop_Loss2;
	    takeprofit = Take_Profit2;
	    magic = magic2;
	    lots = Lots2;
	    
	    if (order2 == 0) 
	        clr = clrDodgerBlue;
	    else
	        clr = clrYellow;
	}
	else if (UseMagic1 && order1 != -1)
	{
	    order = order1;
	    stoploss = Stop_Loss1;
	    takeprofit = Take_Profit1;
	    magic = magic1;
	    lots = Lots1;
	    
	    if (order1 == 0) 
	        clr = clrAqua;
	    else
	        clr = clrRed;
	}
	
	if(order != -1)
	{
	    if (order == 0)
	    {
    	    price = NormalizeDouble(Ask, Digits);
    		stoploss = price - stoploss * gl_basePoint;
    		takeprofit = price + takeprofit * gl_basePoint;
    		cmd = 0;
		}
		else
		{
		    price = NormalizeDouble(Bid, Digits);
		    stoploss = price + stoploss * gl_basePoint;
		    takeprofit = price - takeprofit * gl_basePoint;
		    cmd = 1;
		}
	
		if (CheckStop(cmd, stoploss) && CheckTarget(cmd, takeprofit)) 
		{
			ticket = OrderSend(Symbol(), cmd, lots, price, g_Slippage, stoploss, takeprofit, IntegerToString(magic), magic, 0, clr);
			Print("ticket:", ticket);
			Sleep(5000);
			//todo：加入异常处理
		}
	}
	
}


/*
下单条件(买多）： 15分钟收盘价 > 15分钟K线图的MA(60)+ 20 * 0.0001， 并且，15分钟K线图的WPR(18) < 10 + (-100), 并且，当前买价 < 15分钟K线图上一收盘价 + 5  * 0.0001
	止盈：当前卖价+Take_Profit 点
	止损: 当前卖价-Stop_Loss 点
	平单条件：15分钟K线图的WPR(18) > - 13 ，并且，当前买价 > 15分钟K线图上一收盘价 - 5  * 0.0001
	
	下单条件（卖空）：15分钟收盘价 < 15分钟K线图的MA(60)- 20  * 0.0001， 并且，15分钟K线图的WPR(18) > -10 ， 并且，当前买价 > 15分钟K线图上一收盘价 - 5  *	0.0001
	止盈：当前买价-Take_Profit 点
	止损: 当前买价+Stop_Loss 点 
	平单条件：15分钟K线图的WPR(18) < 13 + (-100) && 当前买价 < 15分钟K线图上一收盘价 + 5  * 0.0001
*/
//-1:不下单， 0：买单，1卖单
int CheckMagic1()
{
    int rtn = -1;
    if((close_M15 > ma_M15_60 + 20 * gl_basePoint && wpr_M15_18 < 10 + (-100) && Bid < close_M15 - (-5)*gl_basePoint)
    	|| (wpr_M15_18 < 6 + (-100) && Bid < close_M15 - (-5)*gl_basePoint))
		rtn = 0;
	else if ((close_M15 < ma_M15_60 - 20 * gl_basePoint && wpr_M15_18 > (-10) && Bid > close_M15 + (-5)*gl_basePoint)
		|| (wpr_M15_18 > -6 && Bid > close_M15 + (-5)*gl_basePoint))
	    rtn = 1;
	//Print(rtn,",",wpr_M15_18,",",Bid,",",close_M15);
	return(rtn);
}

/*
策略二（突破策略）：
	
	下单条件(买多）： 
		15分钟收盘价 >= 1小时K线图的MA(1)+ 1小时K线图ATR(19) * 1.4 + 13 * 0.0001
	止盈：当前卖价+160点
	止损: 当前卖价-25点
	每5分钟做一次移动止损检查，止盈价不变：
			移动点数(默认值) = 1小时K线图ATR(19) * 4.7。如果，当前买价 - 订单价 > 270点，则移动点数 = 20点
			如果，当前买价 - 订单价 > 移动点数，那么，则修改止损价=当前买价-移动点数
	平单条件：5分钟收盘价 <= 1小时K线图的MA(1)- 1小时K线图ATR(19) * 1.4 - 13 * 0.0001
	
	
	下单条件(卖空）： 15分钟收盘价 <= 1小时K线图的MA(1)- 1小时K线图ATR(19) * 1.4 - 13 * 0.0001
	止盈：当前买价-160点
	止损: 当前买价+25点
	每5分钟做一次移动止损检查，止盈价不变。
			移动点数(默认值) = 1小时K线图ATR(19) * 4.7，但是如果，订单价 - 当前卖价 > 270点，移动点数 = 20点
			如果订单价 - 当前卖价 > 移动点数，那么，修改止损价=当前卖价+移动点数
	平单条件： 5分钟收盘价 >= 1小时K线图的MA(1)+ 1小时K线图ATR(19) * 1.4 + 13 * 0.0001
*/
int CheckMagic2()
{
    int rtn = -1;
    if ((close_M5 >= ma_H1_1 + atr_H1_19*1.4 + 13 * gl_basePoint)
		||
		(Ask >= bandup_M5_18 - bandlow_M5_18 + bandmiddle_M5_18 && atr_M5_19 <= 0.0002 && Ask > g_lastAsk) ) //Buy
		rtn = 0;
	else if ((close_M5 <= ma_H1_1 - atr_H1_19*1.4 - 13 * gl_basePoint)
		||
		(Bid <= bandmiddle_M5_18 - (bandup_M5_18 - bandlow_M5_18) && atr_M5_19 <= 0.0002 && Bid < g_lastBid)) //Sell
	    rtn = 1;
	
	return(rtn);
}

/*
策略三（抄底策略）:

	下单条件(买多）:五分钟k线图上一收盘价<五分钟k线图的MA(700)-100点，并且，1小时K线图布林带Bands(26)高点 - 1小时K线图布林带Bands(26)低点 >= 30点， 并且，
				1小时K线图最低价 < 1小时K线图布林带Bands(26)低点 + 3点
	止盈：当前卖价+100点
	止损: 当前卖价-160点
	每5分钟做一次移动止损检查，止盈价不变：
		移动点数 = 5分钟K线图ATR(60) * 13
		如果，当前买价 - 订单价 > 移动点数， 那么， 修改止损价 = 当前买价 - 移动点数
	平单条件：1小时K线图布林带Bands(26)高点 - 1小时K线图布林带Bands(26)低点 >= 30点， 并且，
				1小时K线图最高价 > 1小时K线图布林带Bands(26)高点 - 3点
	
	
	下单条件(卖空）:五分钟k线图上一收盘价>五分钟k线图的MA(700)+100点，并且，1小时K线图布林带Bands(26)高点 - 1小时K线图布林带Bands(26)低点 >= 30点， 并且，
				1小时K线图最高价 > 1小时K线图布林带Bands(26)低点 - 3点
	止盈：当前买价-100点
	止损: 当前买价+160点
	每5分钟做一次移动止损检查，止盈价不变：
		移动点数 = 5分钟K线图ATR(60) * 13
		如果，订单价 - 当前买价 > 移动点数，那么，则修改止损价 = 当前卖价 + 移动点数
	平单条件： 1小时K线图布林带Bands(26)高点 - 1小时K线图布林带Bands(26)低点 >= 30点， 并且，
				1小时K线图最低价 < 1小时K线图布林带Bands(26)低点 + 3点
*/
int CheckMagic3()
{
    int rtn = -1;
    if (close_M5 < ma_M5_700 - MA_Margin_out * gl_basePoint && bandup_H1_26 - bandlow_H1_26 >= 30 * gl_basePoint && low_H1 < bandlow_H1_26 + 3 * gl_basePoint)
		rtn = 0;
	else if (close_M5 > ma_M5_700 + MA_Margin_out * gl_basePoint && bandup_H1_26 - bandlow_H1_26 >= 30 * gl_basePoint && high_H1 > bandup_H1_26 - 3 * gl_basePoint)
	    rtn = 1;
	return(rtn);
}

void ModifyOrder(int iMagic)
{
	double stoploss = OrderStopLoss();
	double adjustPoint = 0;
	
	switch (iMagic)
	{
		case magic1: return;
		case magic2:
			adjustPoint = atr_H1_19 * 4.7;
			if (adjustPoint > 180 * gl_basePoint) adjustPoint = 180 * gl_basePoint;
			if (adjustPoint < 10 * gl_basePoint) adjustPoint = 10 * gl_basePoint;
			if ((OrderType() == OP_BUY && Bid - OrderOpenPrice() > 270 * gl_basePoint)
				|| 
				(OrderType() == OP_SELL && OrderOpenPrice() - Ask > 270 * gl_basePoint))
				adjustPoint = 20 * gl_basePoint;			
			
			break;
		case magic3:
			adjustPoint = atr_M5_60 * 13;
			if (adjustPoint > 60 * gl_basePoint) adjustPoint = 60 * gl_basePoint;
			if (adjustPoint < 20 * gl_basePoint) adjustPoint = 20 * gl_basePoint;
			break;
			
	}
	
	if (OrderType() == OP_BUY)
	{
		stoploss = NormalizeDouble(Bid - adjustPoint, Digits);
		if (Bid - OrderOpenPrice() > adjustPoint) 
		{
			if (OrderStopLoss() < stoploss && CheckStop(OrderType(), stoploss)) 
			{
                if (!OrderModify(OrderTicket(), OrderOpenPrice(), stoploss, OrderTakeProfit(), 0, Blue))
                    Print(GetLastError());	   
			}
		}
	}
	else
	{
		stoploss = NormalizeDouble(Ask + adjustPoint, Digits);
		if (OrderOpenPrice() - Ask > adjustPoint) 
		{
			if (OrderStopLoss() > stoploss && CheckStop(OrderType(), stoploss)) 
			{
			   if (!OrderModify(OrderTicket(), OrderOpenPrice(), stoploss, OrderTakeProfit(), 0, Red))
			        Print(GetLastError());			   
			}
		}
	}
	
}

bool CloseOrder(int iMagic)
{
	bool toBeClosed = false;
	color colorLine = Violet;
	switch (iMagic)
	{
		case magic1:			
			if (OrderType() == OP_BUY && wpr_M15_18 > (-13) && Bid > close_M15 - 5 * gl_basePoint) 
				toBeClosed = true;
			else if (wpr_M15_18 < 13 + (-100) && Bid < close_M15 + 5 * gl_basePoint)
				toBeClosed = true;
			break;
		case magic2:
			if (OrderType() == OP_BUY && close_M5 <= ma_H1_1 - atr_H1_19*1.4 - 13*gl_basePoint)
				toBeClosed = true;
			else if (close_M5 >= ma_H1_1 + atr_H1_19*1.4 + 13*gl_basePoint)
				toBeClosed = true;
			break;
		case magic3:
			if (OrderType() == OP_BUY && bandup_H1_26 - bandlow_H1_26 >= 30 * gl_basePoint && high_H1 > bandup_H1_26 - 3 * gl_basePoint)
				toBeClosed = true;	
			else if (bandup_H1_26 - bandlow_H1_26 >= 30 * gl_basePoint && low_H1 < bandlow_H1_26 + 3 * gl_basePoint)
				toBeClosed = true;
			break;
	}	
	
	bool rtn = 0;
	if (toBeClosed)
	{
		RefreshRates();
		if (OrderType() == OP_BUY)
			rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), g_Slippage, colorLine);
		else
			rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), g_Slippage, colorLine);
	}	
	
	return(rtn);
			
}

bool isValidOrder(int i)
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
}


bool checkAccountBlance()
{
    if (AccountEquity() * Blance_Rate > AccountFreeMargin())
    {
        Print("账户资金余额已低于 ", Blance_Rate * 100 , "%, 不再下单了！账户净值=", AccountEquity(), ",  可用预付款=",  AccountFreeMargin());
        return (false);
    }
   
    double lots = Lots1;
    if (Lots2>lots) lots = Lots2;
    if (Lots3>lots) lots = Lots3;
	double lotsize = MarketInfo(Symbol(), MODE_LOTSIZE);
	if (AccountFreeMargin() < Ask * lots * lotsize / AccountLeverage()) 
	{
		Print("账户资金不足. 下单量 = ", lots, " , 自由保证金 = ", AccountFreeMargin());
		return (false);
	}
	else
		return (true);
}

//检查price是否有效止损价
bool CheckStop(int trade, double price) {   
      
   double stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   
   if (stoplevel <= 0 || price <= 0)
      return (false);
      
   if (trade == 0 && price > Bid - stoplevel * Point) 
      return (false);
   else
      if (trade == 1 && price < Ask + stoplevel * Point) 
         return (false);
   return (true);
}

//检查price是否有效止盈价
bool CheckTarget(int trade, double price) {

   double stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   
   if (stoplevel <= 0 || price <= 0)
      return (false);
      
   if (trade == 0 && price < Bid + stoplevel * Point) 
      return (false);
   else
      if (trade == 1 && price > Ask - stoplevel * Point) 
         return (false);
   return (true);
}

void specialCheck()
{
    if (CloseAll)
	{
	   if (MessageBox("此操作会关闭所有订单!!! \n 单击'是(Y)'关闭所有订单，点击'否(N)'取消。\n 确定继续？", "                   警告!!!",MB_YESNO) != IDYES) return;
	   
	   for (int i = OrdersTotal() - 1; i>=0; i--)
	   {
   		    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
   		    {
       			Print("OrderSelect failed, index = ", i, ", Error Message: ",GetLastError());	
       			continue;
   		    }
   		
   		    if (OrderType() == OP_BUY)
   		    {
       		    if (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), g_Slippage, Violet))
					   Print("OrderTicket:", OrderTicket(), " OrderLots:", OrderLots(), " Bid:", Bid);
				else
					   Print(GetLastError());
			}
			else if (OrderType() == OP_SELL)
			{
			    if (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), g_Slippage, Violet))
					   Print("OrderTicket:", OrderTicket(), " OrderLots:", OrderLots(), " Bid:", Bid);
				else
					   Print(GetLastError());
			}
       	}
       	
       	MessageBox("EA将退出，请重新设定EA！","     提示：", MB_OK);         	
       	
       	//SendMail("subject:平掉所有订单！", "body");
       	        
       	ExpertRemove();
       	ChartRedraw(0);
	}
}