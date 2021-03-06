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

extern double Blance_Rate = 0.6; //Balance Rate(0.3=30%)
extern bool UseMM = false; //Use Compound?
extern double MM = 1.0; //Compound Rate
extern int MinSL = 800;
extern int MaxSL = 1000;
extern int Frequency = 5; //Modify Frequency (second)
extern int RSILimit = 70; //RSI Limit
extern ENUM_TIMEFRAMES Period4Trend = PERIOD_D1;//Period for trend

extern string str999 = "$$$$$$$$$$$$$$$$$$";  //TRADE 999 >>>>>>>>>>>>>>
extern bool UseTrade999 = true;     //......Apply?
extern string SendConfig999 = "0.1,2,300,100;0.2,4,300,200;0.3,6,300,300;0.4,8,300,400;0.5,10,300,500;0.6,12,300,600"; //Config(lots,maxorder,sendspan(second),patchpoint)
extern double Percentage4hedging = 0.5; // % for hedging

extern string str11 = "$$$$$$$$$$$$$$$$$$";  //TRADE 11 >>>>>>>>>>>>>>
extern bool UseTrade11 = false;     //......Apply?
extern string SendConfig11 = "0.02,5,300;0.02,5,900"; //Config(lots,maxorder,sendspan)
extern int Division11 = 25; //......Division Line
extern int WprOpen11 = 6; //......WPR Margen (Open)

extern string str12 = "$$$$$$$$$$$$$$$$$$";  //TRADE 12 ----------------------------------------------------
extern bool UseTrade12 = true;     //......Apply?
extern string SendConfig12 = "0.12,2,300"; //Config(lots,maxorder,sendspan)
extern int Division12 = 25; //......Division Line
extern int WprOpen12 = 6; //......WPR Margen (Open)

extern string str21 = "****************************";  //TRADE 21 >>>>>>>>>>>>>>
extern bool UseTrade21 = false;     //......Apply?
extern string SendConfig21 = "0.01,2,300;0.02,2,900"; //Config(lots,maxorder,sendspan)
//extern int From21 = 10; //......From (MA)
//extern int To21 = 20;   //......To (MA)
//extern int StopLoss21 = 100;

extern string str22 = "****************************";  //TRADE 22 >>>>>>>>>>>>>>
extern bool UseTrade22 = false;     //......Apply?
extern string SendConfig22 = "0.1,10,300"; //Config(lots,maxorder,sendspan)
extern int Division22 = 30; //......Division Line
extern int MAMargin22 = 50;   //......ma_H4_14 Margin

extern string str3 = "****************************"; //TRADE 3 >>>>>>>>>>>>>>
extern bool UseTrade3 = false; //......Apply?
extern string SendConfig3 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin3 = 150;   //......MA-700 Margin

extern string str4 = "****************************"; //TRADE 4 >>>>>>>>>>>>>>
extern bool UseTrade4 = false; //......Apply?
extern string SendConfig4 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin4 = 150;   //......MA-700 Margin

extern string str5 = "****************************"; //TRADE 5 >>>>>>>>>>>>>>
extern bool UseTrade5 = false; //......Apply?
extern string SendConfig5 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int MAMargin5 = 150;   //......MA-700 Margin

extern string str6 = "****************************";  //TRADE 6 >>>>>>>>>>>>>>
extern bool UseTrade6 = false;     //......Apply?
extern string SendConfig6 = "0.01,2,300;0.02,2,900";// Config(lots,maxorder,sendspan)
extern int WprOpen6 = 6; //......WPR Margen (Open)
extern int Division6 = 55; //......Division Line

extern string str7 = "****************************";  //TRADE 7 >>>>>>>>>>>>>>
extern bool UseTrade7 = false; //......Apply?
extern string SendConfig7 = "0.1,10,300"; //Config(lots,maxorder,sendspan)
extern ENUM_TIMEFRAMES Period7;

double BasePoint = 0.0001; 
ENUM_TIMEFRAMES TrendPeriod = PERIOD_D1;
int Trend = -1;
int StrategyCount = 0;

void OnTimer()
{
	//Print("OnTimer");    
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
		rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), 30, clrBlue);
	else
		rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), 30, clrRed);
	
	if(!rtn) Print("订单(",OrderTicket(),")关闭失败,错误原因："+iGetErrorInfo(GetLastError()));	       	
	
	return(rtn);
};

bool CloseOrder(int cmd, int ticket, double lots)
{    	    
    bool rtn = false;
		
    if (cmd == OP_BUY)
		rtn = OrderClose(ticket, lots, NormalizeDouble(Bid, Digits), 30, clrBlue);
	else
		rtn = OrderClose(ticket, lots, NormalizeDouble(Ask, Digits), 30, clrRed);
	
	if(!rtn) Print("订单(",ticket,")关闭失败,错误原因："+iGetErrorInfo(GetLastError()));	       	
	
	return(rtn);
};

bool Duichong(double profit)
{
    double price0 = 0;
    double price1 = 9999999.0;
    int ticket0 = 0;
    int ticket1 = 0;
    double lossed0 = 0;
    double lossed1 = 0;
    double lots0 = 0;
    double lots1 = 0;    
    bool hasBuyOrder = false;
    bool hasSellOrder = false;
    
    for (int j = OrdersTotal() - 1; j >=0; j--)
    {			  
        if (!SelectOrder(j)) continue;  
        double price = OrderOpenPrice();
        double cmd = OrderType();  

        if( cmd == 0 && Bid < price && price > price0 && OrderLots() > 0.01)
        {            
            price0 = price;
            ticket0 = OrderTicket();
            lossed0 = price - Bid;
            lots0 = OrderLots(); 
        }
        
        if( cmd == 1 && price < Ask && price < price1 && OrderLots() > 0.01)
        {
            price1 = price;
            ticket1 = OrderTicket();
            lossed1 = Ask - price;
            lots1 = OrderLots();            
        }
        
        if(cmd == 0) hasBuyOrder = true;
        if(cmd == 1) hasSellOrder = true;
    }  
    
    if(ticket0 != 0 && hasSellOrder == true)
    {
        double lossed = lossed0 * lots0;
        double lots = profit / lossed0;
        
        if(lots > lots0) lots = lots0;
                
        double minlots = MarketInfo(Symbol(), MODE_MINLOT);
        if(lots >= minlots)
        {
            Print("DC:lossed0=", lossed0, ",profit=", profit,",lots=", lots, ", ticket=", ticket0);
            CloseOrder(0, ticket0, lots);
            Comment("DUICHONG: ", ticket0, " Lots:", lots);
            return true;    			            
        }
    } 
    else if(ticket1 != 0 && hasBuyOrder == true)
    {
        double lossed = lossed1 * lots1;
        double lots = profit / lossed1;
        if(lots > lots1) lots = lots1;
               
        double minlots = MarketInfo(Symbol(), MODE_MINLOT);
        if(lots >= minlots)
        {
            Print("DC:lossed1=", lossed1, ",profit=", profit,",lots=", lots, ", ticket=", ticket1);
            CloseOrder(1, ticket1, lots);
            Comment("DUICHONG: ", ticket1, " Lots:", lots);
            
            return true; 			            
        }
    } 
    
    return false;
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
            if(OrderType() == 0 && OrderStopLoss() > OrderOpenPrice())
            {
                profit += ((OrderStopLoss() - OrderOpenPrice()) * OrderLots());
            }
            if(OrderType() == 1 && OrderStopLoss() < OrderOpenPrice())
            {
                profit += ((OrderOpenPrice() - OrderStopLoss()) * OrderLots());
            }  
        }          
    }   
      
    
    if(profit > 0)
    {
        profit *= Percentage4hedging;
        
        if(Duichong(profit)) lastDuichongTime = TimeCurrent(); 
    }    
        
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
}
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
}
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
}
void iDisplayAlertInfo(string Text)/*这里是显示右上角的那一行提示的方法，需要修改提示的话，在这里修改*/
{
iDisplayInfo("TradeInfo",Text,CORNER_RIGHT_UPPER,200,20,10,"微软雅黑",clrRed);
}

void iDisplayInfo(string LableName,string LableDoc,int Corner1,int LableX,int LableY,int DocSize,string DocStyle,color DocColor)
{
  if(ObjectFind(LableName)<0)
    {
      ObjectCreate(LableName, OBJ_LABEL,0,0,0);
      ObjectSetText(LableName, LableDoc, DocSize, DocStyle,DocColor);
      ObjectSet(LableName, OBJPROP_CORNER, Corner1);
      ObjectSet(LableName, OBJPROP_XDISTANCE, LableX);
      ObjectSet(LableName, OBJPROP_YDISTANCE, LableY);
      ObjectSet(LableName,OBJPROP_SELECTABLE,false);
      ObjectSet(LableName,OBJPROP_SELECTED,false);
      ObjectSet(LableName,OBJPROP_HIDDEN,true);
      ObjectSet(LableName,OBJPROP_BACK,true);
    }
  else
    {
      ObjectSetText(LableName, LableDoc, DocSize, DocStyle,DocColor);
      ObjectSet(LableName, OBJPROP_CORNER, Corner1);
      ObjectSet(LableName, OBJPROP_XDISTANCE, LableX);
      ObjectSet(LableName, OBJPROP_YDISTANCE, LableY);
      ObjectSet(LableName,OBJPROP_SELECTABLE,false);
      ObjectSet(LableName,OBJPROP_SELECTED,false);
      ObjectSet(LableName,OBJPROP_HIDDEN,true);
      ObjectSet(LableName,OBJPROP_ZORDER,-1);
    }
  return;
}

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
}

bool SelectOrderByTicket(int i)
{
	if (!OrderSelect(i, SELECT_BY_TICKET, MODE_TRADES))
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

class CIndicator
{
public:
    string magic;
    double close_M5,close_M15;
	double wpr_M5,wpr_M15,wpr_M30,wpr_H1,wpr_H4;
	double adx_M5,adx_M5_pDI,adx_M5_mDI, adx_M15,adx_M15_pDI,adx_M15_mDI;
	double adx_H1, adx_H4_prv2,adx_H4_prv1,adx_H4,adx_H4_pDI,adx_H4_mDI;
	double adx_D1_prv2,adx_D1_prv1,adx_D1, adx_D1_pDI, adx_D1_mDI;
	double adx_W1_prv2,adx_W1_prv1,adx_W1, adx_W1_pDI, adx_W1_mDI;
    double ma_M5_100, ma_M5_700,ma_H1_1,ma_H4_14,ma_W1_14;
    double atr_H1_19,atr_M5_19;
	double bandup_M5,bandmiddle_M5,bandlow_M5,bandup_H1,bandlow_H1;
    double high_H1,low_H1;   
    double rsi_M5,rsi_H4;
     
    CIndicator(){}; 

};

CIndicator* CollectIndicators()
{
    CIndicator *indicator = new CIndicator();
    indicator.close_M5 = iClose(NULL, PERIOD_M5, 1);
    indicator.close_M15 = iClose(NULL, PERIOD_M15, 1);
    
    indicator.wpr_M5 = iWPR(NULL, PERIOD_M5, 18, 0); 
    indicator.wpr_M15 = iWPR(NULL, PERIOD_M15, 18, 0); 
    indicator.wpr_M30 = iWPR(NULL, PERIOD_M30, 18, 0); 
    indicator.wpr_H1 = iWPR(NULL, PERIOD_H1, 18, 0); 
    indicator.wpr_H4 = iWPR(NULL, PERIOD_H4, 18, 0); 
	
	indicator.adx_M5 = iADX(NULL,PERIOD_M5,14,PRICE_CLOSE,MODE_MAIN,0);
	indicator.adx_M5_pDI = iADX(NULL, PERIOD_M5, 14,PRICE_CLOSE, MODE_PLUSDI, 0);
	indicator.adx_M5_mDI = iADX(NULL, PERIOD_M5, 14,PRICE_CLOSE, MODE_MINUSDI, 0);
	indicator.adx_M15 = iADX(NULL,PERIOD_M15,14,PRICE_CLOSE,MODE_MAIN,0);
	indicator.adx_M15_pDI = iADX(NULL, PERIOD_M15, 14,PRICE_CLOSE, MODE_PLUSDI, 0);
	indicator.adx_M15_mDI = iADX(NULL, PERIOD_M15, 14,PRICE_CLOSE, MODE_MINUSDI, 0);
	
	indicator.adx_H1 = iADX(NULL,PERIOD_H1,14,PRICE_CLOSE,MODE_MAIN,0);
	
	indicator.adx_H4_prv2 = iADX(NULL,PERIOD_H4,14,PRICE_CLOSE,MODE_MAIN,2);
	indicator.adx_H4_prv1 = iADX(NULL,PERIOD_H4,14,PRICE_CLOSE,MODE_MAIN,1);
	indicator.adx_H4 = iADX(NULL,PERIOD_H4,14,PRICE_CLOSE,MODE_MAIN,0);
	indicator.adx_H4_pDI = iADX(NULL, PERIOD_H4, 14,PRICE_CLOSE, MODE_PLUSDI, 0);
	indicator.adx_H4_mDI = iADX(NULL, PERIOD_H4, 14,PRICE_CLOSE, MODE_MINUSDI, 0);
	
	indicator.adx_D1_prv2 = iADX(NULL,PERIOD_D1,14,PRICE_CLOSE,MODE_MAIN,2);
	indicator.adx_D1_prv1 = iADX(NULL,PERIOD_D1,14,PRICE_CLOSE,MODE_MAIN,1);
	indicator.adx_D1 = iADX(NULL,PERIOD_D1,14,PRICE_CLOSE,MODE_MAIN,0);
	indicator.adx_D1_pDI = iADX(NULL, PERIOD_D1, 14,PRICE_CLOSE, MODE_PLUSDI, 0);
	indicator.adx_D1_mDI = iADX(NULL, PERIOD_D1, 14,PRICE_CLOSE, MODE_MINUSDI, 0);
	
	indicator.adx_W1_prv2 = iADX(NULL,PERIOD_W1,14,PRICE_CLOSE,MODE_MAIN,2);
	indicator.adx_W1_prv1 = iADX(NULL,PERIOD_W1,14,PRICE_CLOSE,MODE_MAIN,1);
	indicator.adx_W1 = iADX(NULL,PERIOD_W1,14,PRICE_CLOSE,MODE_MAIN,0);
	indicator.adx_W1_pDI = iADX(NULL, PERIOD_W1, 14,PRICE_CLOSE, MODE_PLUSDI, 0);
	indicator.adx_W1_mDI = iADX(NULL, PERIOD_W1, 14,PRICE_CLOSE, MODE_MINUSDI, 0);
	
	indicator.ma_M5_100 = iMA(NULL, PERIOD_M5, 100, 0, MODE_SMA, PRICE_CLOSE, 1);
	indicator.ma_M5_700 = iMA(NULL, PERIOD_M5, 700, 0, MODE_SMMA, PRICE_CLOSE, 1); 
	indicator.ma_H1_1 = iMA(NULL, PERIOD_H1, 1, 0, MODE_EMA, PRICE_CLOSE, 1);
	indicator.ma_H4_14 = iMA(NULL, PERIOD_H4, 14, 0, MODE_EMA, PRICE_CLOSE, 1);
	indicator.ma_W1_14 = iMA(NULL, PERIOD_W1, 14, 0, MODE_EMA, PRICE_CLOSE, 1);
	
	indicator.atr_M5_19 = iATR(NULL, PERIOD_M5, 19, 1);  	
	indicator.atr_H1_19 = iATR(NULL, PERIOD_H1, 19, 1); 
		
	
	indicator.bandup_M5 = iBands(NULL, PERIOD_M5, 18, 2, 0, PRICE_CLOSE, MODE_UPPER, 1); 
	indicator.bandmiddle_M5 = iBands(NULL, PERIOD_M5, 18, 2, 0, PRICE_CLOSE, MODE_MAIN, 1);
	indicator.bandlow_M5 = iBands(NULL, PERIOD_M5, 18, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);	   
	indicator.bandup_H1 = iBands(NULL, PERIOD_H1, 26, 2, 0, PRICE_CLOSE, MODE_UPPER, 1); 
	indicator.bandlow_H1 = iBands(NULL, PERIOD_H1, 26, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
	
	indicator.high_H1 = iHigh(NULL, PERIOD_H1, 1);
	indicator.low_H1 = iLow(NULL, PERIOD_H1, 1);
	
	indicator.rsi_M5 = iRSI(NULL, PERIOD_M5, 14, PRICE_CLOSE, 1);	
	indicator.rsi_H4 = iRSI(NULL, PERIOD_H4, 14, PRICE_CLOSE, 1);	
		
	return (indicator);
};

int GetBoFu(ENUM_TIMEFRAMES timeframe, int shift)
{
	double high = iHigh(NULL, timeframe, shift);
	double low = iLow(NULL, timeframe, shift);
	int bofu = (high - low) / BasePoint;
	return bofu;
}

int GetTrend(ENUM_TIMEFRAMES trendPeriod = PERIOD_D1)
{
	int rtn = -1;

	double ma10 = iMA(NULL, trendPeriod, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
	double ma20 = iMA(NULL, trendPeriod, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
			
	if(ma10 > ma20)
		rtn = 0;
	else if(ma10 < ma20)
		rtn = 1;
	
	return (rtn);
}

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
    virtual int GetCommand(CIndicator* ind, double &lots) = 0;    
    virtual bool SendOrder(CIndicator* ind);  
      
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
    	//lots = AccountEquity()/MarketInfo(Symbol(), MODE_MARGINREQUIRED);    	
    	//lots = lots * MM * this.Lots / TotalLots;
    	//（账户净值*0.3）/(最大止损额*10)/总单数
    	lots = AccountEquity() * Blance_Rate / (this.MaxStopLoss * 10) /(this.TotalOrderLimit * 2);
    	lots *= MM;
    	//lots *= this.Lots / (TotalLots / StrategyCount);
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
  
bool BaseStrategy::SendOrder(CIndicator* ind)
{
    if (TimeCurrent() < this.LastSendTime + this.SendSpan) return false; 
    double lots = 0;
	int cmd = GetCommand(ind, lots);
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

class Strategy111 : public BaseStrategy
{
public:  
    int GetCommand(CIndicator* ind, double &lots)
    {
        double rsiLimit = iRSI(NULL, TrendPeriod, 14, PRICE_CLOSE, 0);
        if(rsiLimit > RSILimit && Trend == 0 || rsiLimit < 100 - RSILimit && Trend == 1) return(-1);      
        
        bool hasDuichong = false;
        for (int j = OrdersTotal() - 1; j >=0; j--)
        {			  
            if (!SelectOrder(j)) continue; 
            if (OrderMagicNumber()>=9990) 
            {
                hasDuichong = true;
                break;
            }
        }       
          
		int rtn = -1; 
		
		if(Magic == 999)
		{
		    rtn = GetCMD4Patch(lots);	
		}
		else if(!hasDuichong)
		{				    
    		switch(Magic)
    		{
    			case 11:
    				if(ind.adx_M5 < Division11 && ind.wpr_M5 < WprOpen11 + (-100) && ind.close_M5 < ind.ma_M5_700 + 60 * BasePoint && Trend == 0)
    					rtn = 0;
    				else if (ind.adx_M5 < Division11 && ind.wpr_M5 > -WprOpen11 && ind.close_M5 > ind.ma_M5_700 - 60 * BasePoint && Trend == 1)
    					rtn = 1;
    				break;
    				
    				//this.TakeProfit = 50;
    			case 12:
    				if(ind.rsi_M5 < 30 && ind.close_M5 < ind.ma_M5_700 + 60 * BasePoint && Trend == 0)
    					rtn = 0;
    				else if ( ind.rsi_M5 > 70 && ind.close_M5 > ind.ma_M5_700 - 60 * BasePoint && Trend == 1)
    					rtn = 1;
    				break;
    			case 21:
    			{
    			    double ma700 = iMA(NULL, PERIOD_M30, 700, 0, MODE_SMA, PRICE_CLOSE, 0);
    			    double ma200 = iMA(NULL, PERIOD_M30, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
    			    double ma100 = iMA(NULL, PERIOD_M30, 100, 0, MODE_SMA, PRICE_CLOSE, 0);
    			    double ma13 = iMA(NULL, PERIOD_M30, 13, 0, MODE_SMA, PRICE_CLOSE, 0);
    			    double ma8 = iMA(NULL, PERIOD_M30, 8, 0, MODE_SMA, PRICE_CLOSE, 0);
    			    double ma5 = iMA(NULL, PERIOD_M30, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
    			    
    				if(ma5>ma8 && ma8>ma13 && ma13>ma100 && ma100>ma200 && ma200>ma700)
    				{
    					rtn = 0;
    					this.StopLoss = (Ask - ma700) / BasePoint - 10;
    				}
    				else if (ma5<ma8 && ma8<ma13 && ma13<ma100 && ma100<ma200 && ma200<ma700)
    				{
    					rtn = 1;
    					this.StopLoss = (ma700 - Bid) / BasePoint + 10;
    				}    				
    				
    				this.TakeProfit = StopLoss * 1.6;
    		    }
    				break;
    			case 22:
    			{
    			    ENUM_TIMEFRAMES period = PERIOD_M30;
    			    double c1 = iClose(NULL, period, 1);
    			    double c2 = iClose(NULL, period, 5);
    			    double c3 = iClose(NULL, period, 6);
    			    double c4 = iClose(NULL, period, 30);
    				
    			    double rsi = iRSI(NULL, period, 14, PRICE_CLOSE, 0);
    			    
    			    if(c4 - c3 > 50 * BasePoint && c1 - c2 > 20 * BasePoint && c1 - c2 < 50 * BasePoint)
    			    {			          	
                	    rtn = 0; 	Print("magic22");		
                	}
            	    else if (c3 - c4 > 50 * BasePoint && c2 - c1 > 20 * BasePoint && c2 - c1 < 50 * BasePoint) //Sell
            	    {
                	    rtn = 1; Print("magic22");	
                	}			    
    				this.TakeProfit = 1000;						
    			}
    				break;
    			case 3:
    				if (Ask >= ind.bandup_M5 + 0.0005 && ind.close_M5 < ind.ma_M5_700 + MAMargin3 * BasePoint	&& ind.rsi_M5 < 70 && Trend == 0)
    					rtn = 0; 		
    				else if (Bid <= ind.bandlow_M5 - 0.0005 && ind.close_M5 > ind.ma_M5_700 - MAMargin3 * BasePoint && ind.rsi_M5 > 30 && Trend == 1)
    					rtn = 1;
    				break;
    			case 4:
    				if (ind.close_M5 >= ind.ma_H1_1 + ind.atr_H1_19*1.4 + 13 * BasePoint && ind.close_M5 < ind.ma_M5_700 + MAMargin4 * BasePoint && ind.rsi_M5 < 70 && Trend == 0)		
    					rtn = 0;
    				else if (ind.close_M5 <= ind.ma_H1_1 - ind.atr_H1_19*1.4 - 13 * BasePoint && ind.close_M5 > ind.ma_M5_700 - MAMargin4 * BasePoint	&& ind.rsi_M5 > 30 && Trend == 1)
    					rtn = 1;
    				break;
    			case 5:
    				if (ind.bandup_H1 - ind.bandlow_H1 >= 30 * BasePoint && ind.low_H1 < ind.bandlow_H1 + 3 * BasePoint && ind.close_M5 < ind.ma_M5_700 - MAMargin5 * BasePoint && Trend == 0)
    					rtn = 0; 		
    				else if(ind.bandup_H1 - ind.bandlow_H1 >= 30 * BasePoint && ind.high_H1 > ind.bandup_H1 - 3 * BasePoint && ind.close_M5 > ind.ma_M5_700 + MAMargin5 * BasePoint && Trend == 1)
    					rtn = 1;    		
    				break;
    			case 6:
    				if(ind.wpr_H4 < WprOpen6 + (-100) && Bid > ind.close_M15 - (-5)*BasePoint && ind.adx_H4 > Division6 && Trend == 0)    	
    					rtn = 0; 	
    				else if (ind.wpr_H4 > -WprOpen6 && Bid < ind.close_M15 + (-5)*BasePoint && ind.adx_H4 > Division6 && Trend == 1)
    					rtn = 1;
    				break;	
    			case 7:
    			{
    			    double ma10 = iMA(NULL, Period7, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
    	            double ma20 = iMA(NULL, Period7, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
    	            double ma10_1 = iMA(NULL, Period7, 10, 0, MODE_SMA, PRICE_CLOSE, 1);
    	            double ma20_1 = iMA(NULL, Period7, 20, 0, MODE_SMA, PRICE_CLOSE, 1);
    			    if(ma10_1 < ma20_1 && ma10 > ma20)
    			        rtn = 0;
    			    else if(ma10_1 > ma20_1 && ma10 < ma20)
    			        rtn = 1;	
    			    this.StopLoss = 5000;
    			    this.TakeProfit = 5000;		    
    			}
    			    break;	
    			
    		}
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
		if(Trend == 0) 
		    rtn = 1;
		else if(Trend == 1)
		    rtn = 0;
		//lots = totalloss / (PatchPoint * BasePoint)/ this.MaxOrderCount;
		//if(lots<0.01 ) lots = 0.01;
		//Print("budan=", lots);
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
	if(adjustPoint < 20) adjustPoint = 20;
	if(adjustPoint > 50) adjustPoint = 50;		
	adjustPoint = adjustPoint * BasePoint;  
   	
    bool tobemodify = false; 
    bool tobeclose = false;    
	
	if(OrderMagicNumber() / 10 == 7)
    {
        double ma10 = iMA(NULL, Period7, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
        double ma20 = iMA(NULL, Period7, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
        double ma10_1 = iMA(NULL, Period7, 10, 0, MODE_SMA, PRICE_CLOSE, 1);
        double ma20_1 = iMA(NULL, Period7, 20, 0, MODE_SMA, PRICE_CLOSE, 1);
	    if(cmd == 1 && ma10_1 < ma20_1 && ma10 > ma20)
	        tobeclose = true;
	    else if(cmd == 0 && ma10_1 > ma20_1 && ma10 < ma20)
	        tobeclose = true;
	} 
	else
	{
        if (cmd == OP_BUY)
    	{
    	    stoploss = NormalizeDouble(Bid - adjustPoint, Digits);			
    		if (stoploss > openprice && stoploss > oldstoploss && IsValidSL(cmd, stoploss)) 
    		    tobemodify = true;	
    		//else if(oldstoploss < openprice && opentime + 3600 * 24 * 20 < TimeCurrent() && Trend == 1)
    		//    tobeclose = true;	
    
    	}
    	else
    	{
    	    clr = clrRed;
    		stoploss = NormalizeDouble(Ask + adjustPoint, Digits);			
    		if (stoploss < openprice && stoploss < oldstoploss && IsValidSL(cmd, stoploss)) 
    		    tobemodify = true;		
    		//else if(oldstoploss > openprice && opentime + 3600 * 24 * 20 < TimeCurrent() && Trend == 0)
    		//    tobeclose = true;
    	}	
	}
	
	bool rtn = false;
	if(tobemodify && OrderMagicNumber() / 10 != 7)
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
    else if(tobeclose)
    {
        CloseOrder(cmd);
    }
    
	return (rtn);
};

CIndicator *g_indicator;
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
		case 7:
			sendConfig = SendConfig7;
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

int OnInit()
{
    EventSetTimer(300);
    //add(1); return;    

    StrategyCount = 0;
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
	if (UseTrade7) AssembleStrategy(7);	
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

datetime LastModifyTime; 
void OnTick()
{
	if (TimeCurrent() < LastModifyTime + Frequency) return; //Frequency秒
	Trend = GetTrend(TrendPeriod);
    g_indicator = CollectIndicators();
	
	//CloseAllIfReverse();
	
	//CloseAllIfBuySell();
	
	if(TimeCurrent() > lastDuichongTime + 36000)
	{
	    Duichong();	    
	}
	
	for (int i = 0; i < OrdersTotal(); i++)
	{
		if (!SelectOrder(i)) continue;
		
		ModifyOrder(OrderType());				
	} 	
	
    for(int i=0;i<ArraySize(Stg);i++)
    {
        Stg[i].SendOrder(g_indicator);
    }	
	
    delete g_indicator;
	
	LastModifyTime = TimeCurrent();
};

