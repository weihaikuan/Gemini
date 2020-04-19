double BasePoint = 0.0001; 
ENUM_TIMEFRAMES TrendPeriod = PERIOD_D1;
int Trend = -1;
int StrategyCount = 0;

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

//+------------------------------------------------------------------+
//检查price是否有效止损价
bool IsValidSL(int cmd, double price) {   
      
   double stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   
   if (stoplevel <= 0 || price <= 0)
      return (false);
      
   if (cmd == 0 && price > Bid - stoplevel * Point) 
      return (false);
   else
      if (cmd == 1 && price < Ask + stoplevel * Point) 
         return (false);
   return (true);
};
//检查price是否有效止盈价
bool IsValidTP(int cmd, double price) {

   double stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   
   if (stoplevel <= 0 || price <= 0)
      return (false);
      
   if (cmd == 0 && price < Bid + stoplevel * Point) 
      return (false);
   else
      if (cmd == 1 && price > Ask - stoplevel * Point) 
         return (false);
   return (true);
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
            case 4000:myLastErrorStr="运行报错码:4000 没有错误返回";break;
            case 4001:myLastErrorStr="运行报错码:4001 函数指针错误";break;
            case 4002:myLastErrorStr="运行报错码:4002 数组越界";break;
            case 4003:myLastErrorStr="运行报错码:4003 调用栈导致内存不足";break;
            case 4004:myLastErrorStr="运行报错码:4004 递归栈溢出";break;
            case 4005:myLastErrorStr="运行报错码:4005 堆栈参数导致内存不足";break;
            case 4006:myLastErrorStr="运行报错码:4006 字符串参数导致内存不足";break;
            case 4007:myLastErrorStr="运行报错码:4007 临时字符串导致内存不足";break;
            case 4008:myLastErrorStr="运行报错码:4008 字符串变量缺少初始化赋值";break;
            case 4009:myLastErrorStr="运行报错码:4009 字符串数组缺少初始化赋值";break;
            case 4010:myLastErrorStr="运行报错码:4010 字符串数组空间不够";break;
            case 4011:myLastErrorStr="运行报错码:4011 字符串太长";break;
            case 4012:myLastErrorStr="运行报错码:4012 因除数为零导致的错误";break;
            case 4013:myLastErrorStr="运行报错码:4013 除数为零";break;
            case 4014:myLastErrorStr="运行报错码:4014 错误的命令";break;
            case 4015:myLastErrorStr="运行报错码:4015 错误的跳转";break;
            case 4016:myLastErrorStr="运行报错码:4016 数组没有初始化";break;
            case 4017:myLastErrorStr="运行报错码:4017 禁止调用DLL ";break;
            case 4018:myLastErrorStr="运行报错码:4018 库文件无法调用";break;
            case 4019:myLastErrorStr="运行报错码:4019 函数无法调用";break;
            case 4020:myLastErrorStr="运行报错码:4020 禁止调用智EA函数";break;
            case 4021:myLastErrorStr="运行报错码:4021 函数中临时字符串返回导致内存不够";break;
            case 4022:myLastErrorStr="运行报错码:4022 系统繁忙";break;
            case 4023:myLastErrorStr="运行报错码:4023 DLL函数调用错误";break;
            case 4024:myLastErrorStr="运行报错码:4024 内部错误";break;
            case 4025:myLastErrorStr="运行报错码:4025 内存不够";break;
            case 4026:myLastErrorStr="运行报错码:4026 指针错误";break;
            case 4027:myLastErrorStr="运行报错码:4027 过多的格式定义";break;
            case 4028:myLastErrorStr="运行报错码:4028 参数计数器越界";break;
            case 4029:myLastErrorStr="运行报错码:4029 数组错误";break;
            case 4030:myLastErrorStr="运行报错码:4030 图表没有响应";break;
            case 4050:myLastErrorStr="运行报错码:4050 参数无效";break;
            case 4051:myLastErrorStr="运行报错码:4051 参数值无效";break;
            case 4052:myLastErrorStr="运行报错码:4052 字符串函数内部错误";break;
            case 4053:myLastErrorStr="运行报错码:4053 数组错误";break;
            case 4054:myLastErrorStr="运行报错码:4054 数组使用不正确";break;
            case 4055:myLastErrorStr="运行报错码:4055 自定义指标错误";break;
            case 4056:myLastErrorStr="运行报错码:4056 数组不兼容";break;
            case 4057:myLastErrorStr="运行报错码:4057 全局变量处理错误";break;
            case 4058:myLastErrorStr="运行报错码:4058 没有发现全局变量";break;
            case 4059:myLastErrorStr="运行报错码:4059 测试模式中函数被禁用";break;
            case 4060:myLastErrorStr="运行报错码:4060 函数未确认";break;
            case 4061:myLastErrorStr="运行报错码:4061 发送邮件错误";break;
            case 4062:myLastErrorStr="运行报错码:4062 String参数错误";break;
            case 4063:myLastErrorStr="运行报错码:4063 Integer参数错误";break;
            case 4064:myLastErrorStr="运行报错码:4064 Double参数错误";break;
            case 4065:myLastErrorStr="运行报错码:4065 数组参数错误";break;
            case 4066:myLastErrorStr="运行报错码:4066 刷新历史数据错误";break;
            case 4067:myLastErrorStr="运行报错码:4067 交易内部错误";break;
            case 4068:myLastErrorStr="运行报错码:4068 没有发现资源文件";break;
            case 4069:myLastErrorStr="运行报错码:4069 不支持资源文件";break;
            case 4070:myLastErrorStr="运行报错码:4070 重复的资源文件";break;
            case 4071:myLastErrorStr="运行报错码:4071 自定义指标没有初始化";break;
            case 4099:myLastErrorStr="运行报错码:4099 文件末尾";break;
            case 4100:myLastErrorStr="运行报错码:4100 文件错误";break;
            case 4101:myLastErrorStr="运行报错码:4101 文件名称错误";break;
            case 4102:myLastErrorStr="运行报错码:4102 打开文件过多";break;
            case 4103:myLastErrorStr="运行报错码:4103 不能打开文件";break;
            case 4104:myLastErrorStr="运行报错码:4104 不兼容的文件";break;
            case 4105:myLastErrorStr="运行报错码:4105 没有选择定单";break;
            case 4106:myLastErrorStr="运行报错码:4106 未知的商品名称";break;
            case 4107:myLastErrorStr="运行报错码:4107 价格无效";break;
            case 4108:myLastErrorStr="运行报错码:4108 报价无效";break;
            case 4109:myLastErrorStr="运行报错码:4109 禁止交易，请尝试修改EA属性";break;
            case 4110:myLastErrorStr="运行报错码:4110 禁止买入类型交易，请尝试修改EA属性";break;
            case 4111:myLastErrorStr="运行报错码:4111 禁止卖出类型交易，请尝试修改EA属性";break;
            case 4112:myLastErrorStr="运行报错码:4111 服务器禁止使用自动交易EA";break;
            case 4200:myLastErrorStr="运行报错码:4200 对象已经存在";break;
            case 4201:myLastErrorStr="运行报错码:4201 未知的对象属性";break;
            case 4202:myLastErrorStr="运行报错码:4202 对象不存在";break;
            case 4203:myLastErrorStr="运行报错码:4203 未知的对象类型";break;
            case 4204:myLastErrorStr="运行报错码:4204 对象没有命名";break;
            case 4205:myLastErrorStr="运行报错码:4205 对象坐标错误";break;
            case 4206:myLastErrorStr="运行报错码:4206 没有指定副图窗口";break;
            case 4207:myLastErrorStr="运行报错码:4207 图形对象错误";break;
            case 4210:myLastErrorStr="运行报错码:4210 未知的图表属性";break;
            case 4211:myLastErrorStr="运行报错码:4211 没有发现主图";break;
            case 4212:myLastErrorStr="运行报错码:4212 没有发现副图";break;
            case 4213:myLastErrorStr="运行报错码:4210 图表中没有发现指标";break;
            case 4220:myLastErrorStr="运行报错码:4220 商品选择错误";break;
            case 4250:myLastErrorStr="运行报错码:4250 消息传递错误";break;
            case 4251:myLastErrorStr="运行报错码:4251 消息参数错误";break;
            case 4252:myLastErrorStr="运行报错码:4252 消息被禁用";break;
            case 4253:myLastErrorStr="运行报错码:4253 消息发送过于频繁";break;
            case 5001:myLastErrorStr="运行报错码:5001 文件打开过多";break;
            case 5002:myLastErrorStr="运行报错码:5002 错误的文件名";break;
            case 5003:myLastErrorStr="运行报错码:5003 文件名过长";break;
            case 5004:myLastErrorStr="运行报错码:5004 无法打开文件";break;
            case 5005:myLastErrorStr="运行报错码:5005 文本文件缓冲区分配错误";break;
            case 5006:myLastErrorStr="运行报错码:5006 文无法删除文件";break;
            case 5007:myLastErrorStr="运行报错码:5007 文件句柄无效";break;
            case 5008:myLastErrorStr="运行报错码:5008 文件句柄错误";break;
            case 5009:myLastErrorStr="运行报错码:5009 文件必须设置为FILE_WRITE";break;
            case 5010:myLastErrorStr="运行报错码:5010 文件必须设置为FILE_READ";break;
            case 5011:myLastErrorStr="运行报错码:5011 文件必须设置为FILE_BIN";break;
            case 5012:myLastErrorStr="运行报错码:5012 文件必须设置为FILE_TXT";break;
            case 5013:myLastErrorStr="运行报错码:5013 文件必须设置为FILE_TXT或FILE_CSV";break;
            case 5014:myLastErrorStr="运行报错码:5014 文件必须设置为FILE_CSV";break;
            case 5015:myLastErrorStr="运行报错码:5015 读文件错误";break;
            case 5016:myLastErrorStr="运行报错码:5016 写文件错误";break;
            case 5017:myLastErrorStr="运行报错码:5017 二进制文件必须指定字符串大小";break;
            case 5018:myLastErrorStr="运行报错码:5018 文件不兼容";break;
            case 5019:myLastErrorStr="运行报错码:5019 目录名非文件名";break;
            case 5020:myLastErrorStr="运行报错码:5020 文件不存在";break;
            case 5021:myLastErrorStr="运行报错码:5021 文件不能被重复写入";break;
            case 5022:myLastErrorStr="运行报错码:5022 错误的目录名";break;
            case 5023:myLastErrorStr="运行报错码:5023 目录名不存在";break;
            case 5024:myLastErrorStr="运行报错码:5024 指定文件而不是目录";break;
            case 5025:myLastErrorStr="运行报错码:5025 不能删除目录";break;
            case 5026:myLastErrorStr="运行报错码:5026 不能清空目录";break;
            case 5027:myLastErrorStr="运行报错码:5027 改变数组大小错误";break;
            case 5028:myLastErrorStr="运行报错码:5028 改变字符串大小错误";break;
            case 5029:myLastErrorStr="运行报错码:5029 结构体包含字符串或者动态数组";break;
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

int GetTrend(ENUM_TIMEFRAMES trendPeriod = PERIOD_D1)
{
	int rtn = -1;

	double ma10 = iMA(NULL, trendPeriod, 10, 0, MODE_SMMA, PRICE_CLOSE, 0);
	double ma20 = iMA(NULL, trendPeriod, 20, 0, MODE_SMMA, PRICE_CLOSE, 0);
			
	if(ma10 > ma20)
		rtn = 0;
	else if(ma10 < ma20)
		rtn = 1;
	
	return (rtn);
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
	int ReversePoint; 
    
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
    	lots = AccountEquity() * Blance_Rate / (this.MaxStopLoss * 10) /this.TotalOrderLimit;
    	lots *= MM;
    	lots *= this.Lots / (TotalLots / StrategyCount);
    	//double rsi = iRSI(NULL, TrendPeriod, 14, PRICE_CLOSE, 0);
    	//if(cmd == 0)
    	//{
    	//    if(rsi > 50)
    	//        lots = this.Lots;
    	//    else
    	//        lots = lots * (100-rsi) / 100;
    	//}
    	//else
    	//{
    	//    if(rsi < 50)
    	//        lots = this.Lots;
    	//    else
    	//        lots = lots * rsi / 100; 
    	//}        

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

	if (IsValidSL(cmd, stoploss) && IsValidTP(cmd, takeprofit)) 
	{
		int ticket = OrderSend(Symbol(), cmd, lots, price, 30, stoploss, takeprofit, IntegerToString(MagicNumber), MagicNumber, 0, clr);
		if(ticket>=0) 
		{
			Comment("\r\n bofu=", bofu, ", cmd=", cmd, ", lots=", lots, ", magic=", MagicNumber);			
		    this.LastSendTime = TimeCurrent();		    
		    return(true);	
		}    
		else
		    Print("下单失败,错误原因："+iGetErrorInfo(GetLastError()));				
	
	}	
    
    return false;
};
