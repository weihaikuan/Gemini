double gl_basePoint = 0.0001; 
int gl_doubleLotsSpan = 60;
int gl_slippage = 3;

enum Magic
{
    magic11 = 11,
    magic12 = 12,
    magic13 = 13,
    magic14 = 14,
    magic21 = 21,
    magic22 = 22,
    magic3 = 3,
    magic4=4,
    magic5=5,
    magic6=6,
	magic999 = 999,
};

class COrder
{
public:
    int Ticket;
    int CMD;
    double Lots;
    datetime OpenTime;    
    double OpenPrice;    
    double StopLoss;
    double TakeProfit;
    datetime CloseTime; 
    double ClosePrice;             
    double Profit;
    int MagicNumber;    
    
public:
    COrder(){};
    ~COrder(){};
	void Build(int magicnumber)
	{
		this.Ticket = OrderTicket();
		this.CMD = OrderType();
		this.Lots = OrderLots();
		this.OpenTime = OrderOpenTime();		
		this.OpenPrice = OrderOpenPrice();
		this.StopLoss = OrderStopLoss();
		this.TakeProfit = OrderTakeProfit();
		this.CloseTime = OrderCloseTime();		
		this.ClosePrice = OrderClosePrice();
		this.Profit = OrderProfit();
		this.MagicNumber = magicnumber;		
	};
	
    string toString()
    {
        string str = "***" + IntegerToString(Ticket) + "," 
            + TimeToString(OpenTime) + ","
            + DoubleToString(OpenPrice) + ","
            + IntegerToString(MagicNumber);
        return str;
    };          
      
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


class CIndicator
{
public:
    string magic;
    double close_M5,close_M15;
	double wpr_M5,wpr_M15,wpr_M30,wpr_H1,wpr_H4;
	double adx_M5,adx_M5_pDI,adx_M5_mDI, adx_M15,adx_M15_pDI,adx_M15_mDI, adx_M30,adx_M30_pDI,adx_M30_mDI;
	double adx_H1,adx_H1_pDI,adx_H1_mDI;
	double adx_H4_prv2,adx_H4_prv1,adx_H4,adx_H4_pDI,adx_H4_mDI;
	double adx_D1_prv2,adx_D1_prv1,adx_D1, adx_D1_pDI, adx_D1_mDI;
	double adx_W1_prv2,adx_W1_prv1,adx_W1, adx_W1_pDI, adx_W1_mDI;
    double ma_M5_700,ma_H1_1,ma_H4_14,ma_W1_14;
    double atr_H1_19,atr_M5_19;
	double bandup_M5,bandmiddle_M5,bandlow_M5,bandup_H1,bandlow_H1;
    double high_H1,low_H1;   
    double rsi_M5;
     
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
	indicator.adx_M30 = iADX(NULL,PERIOD_M30,14,PRICE_CLOSE,MODE_MAIN,0);
	indicator.adx_M30_pDI = iADX(NULL, PERIOD_M30, 14,PRICE_CLOSE, MODE_PLUSDI, 0);
	indicator.adx_M30_mDI = iADX(NULL, PERIOD_M30, 14,PRICE_CLOSE, MODE_MINUSDI, 0);
	indicator.adx_H1 = iADX(NULL,PERIOD_H1,14,PRICE_CLOSE,MODE_MAIN,0);
	indicator.adx_H1_pDI = iADX(NULL, PERIOD_H1, 14,PRICE_CLOSE, MODE_PLUSDI, 0);
	indicator.adx_H1_mDI = iADX(NULL, PERIOD_H1, 14,PRICE_CLOSE, MODE_MINUSDI, 0);
	
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
	
	indicator.rsi_M5 = iRSI(NULL, PERIOD_M5, 14, PRICE_CLOSE, 0);	
		
	return (indicator);
};

class BaseStrategy
{
public:
    static double Blance_Rate;
    static double MM;
    static bool UseMM;
    static double TotalOrderLimit;
    static int LastDoubleLotsTime;
    
public:
	int ModifySpan;
    int SendSpan;
    
    int MagicNumber;
    double Lots;
    int MaxOrderCount;
    int TakeProfit;
    int StopLoss;
    int BackPoint; 
    bool UsePB;
    int PBfrom;
    int PBto;  
    int LastModifyTime; 
    int LastSendTime;    

    COrder *Orders[];
	COrder *OrdersHistroy[];      
    
    BaseStrategy(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan = 300, int modifyspan = 5, bool usePB = false, int pbfrom = 20, int pbto = 2)
    {
        Lots = lots;
        MaxOrderCount = maxordercount;
        StopLoss = stoploss;
        TakeProfit = takeprofit;
        BackPoint = backpoint;  
        SendSpan = sendspan;  
        ModifySpan = modifyspan;
        UsePB = usePB;
        PBfrom = pbfrom;
        PBto = pbto;            
        LastModifyTime = 0;
        LastSendTime = 0;
    }
    ~BaseStrategy()
    {
        CleanOrder();
    }
public:    
    void RefreshOrders();   
    void CleanOrder(); 
    void PrintMe(void);   
    
    bool CloseOrder(int cmd);    
    virtual bool TobeClosed(int cmd, CIndicator* ind); 
       
    bool ModifyOrder(int cmd, CIndicator* ind);    
    virtual double GetAdjustPoint(int cmd, CIndicator* ind);    
 
    virtual int GetCommand(CIndicator* ind) = 0;    
    virtual bool SendOrder(CIndicator* ind);  
    virtual void PrintIndicator4Order(CIndicator* ind, int cmd);
      
    double GetLots();
    bool HasOrder() {return ArraySize(Orders);};
    bool CheckLots(double lots);
};

double BaseStrategy::Blance_Rate = 0.3;
double BaseStrategy::MM = 0.05;
bool BaseStrategy::UseMM = false;
double BaseStrategy::TotalOrderLimit = 0;
int BaseStrategy::LastDoubleLotsTime = 0;

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
double BaseStrategy::GetLots()
{	 
	RefreshOrders();
	int ordercount = ArraySize(this.Orders);		
    if (ordercount >= this.MaxOrderCount) return 0; 
		
	double lots;
	if (UseMM)
	{
    	lots = AccountEquity()/MarketInfo(Symbol(), MODE_MARGINREQUIRED);
    	lots = lots * MM / TotalOrderLimit;
    }
	else
	    lots = this.Lots;  
    
	lots = NormalizeDouble(lots, 2);
	
	if (!CheckLots(lots)) lots = 0;
	
	return(lots);
};
    
BaseStrategy::RefreshOrders()
{   

    CleanOrder();
	int i, magicnumber, size;
	COrder *order;
    int total = OrdersTotal();

    for (i=total - 1; i >= 0; i--)
	{
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) return;
        
        magicnumber = OrderMagicNumber();
        
        if (magicnumber != this.MagicNumber) continue;
        
		order = new COrder();		
		order.Build(magicnumber);
		
		size = 0;
		size = ArraySize(this.Orders) + 1; 
        ArrayResize(this.Orders, size);
        this.Orders[size - 1] = order;
	}
	
	total = OrdersHistoryTotal();
	
    for (i=total - 1; i >= 0; i--)
	{
		if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) return;
        
        magicnumber = OrderMagicNumber();
        
        if (magicnumber != this.MagicNumber) 
			continue;
        
		order = new COrder();		
		order.Build(magicnumber);
		
		size = 0;
		size = ArraySize(this.OrdersHistroy) + 1; 
        ArrayResize(this.OrdersHistroy, size);
        this.OrdersHistroy[size - 1] = order;	
		
		if(size == 50) break; //only get 5 orders from history
	}
};

BaseStrategy::CleanOrder()
{
    int i;
    
    for (i = 0; i < ArraySize(Orders); i++)
    {
        delete Orders[i];
        Orders[i] = NULL;
    }   
    
    ArrayResize(this.Orders, 0);
	
	for (i = 0; i < ArraySize(OrdersHistroy); i++)
    {
        delete OrdersHistroy[i];
        OrdersHistroy[i] = NULL;
    }   
    
    ArrayResize(this.OrdersHistroy, 0);
};
BaseStrategy::PrintMe(void)
{
    int i;
    for (i = 0; i < ArraySize(Orders); i++)
    {
        Print(Orders[i].toString());
    };
	for (i = 0; i < ArraySize(OrdersHistroy); i++)
    {
        Print(OrdersHistroy[i].toString());
    };
};

bool BaseStrategy::SendOrder(CIndicator* ind)
{
    if (TimeCurrent() < this.LastSendTime + this.SendSpan) return false; 
	int cmd = GetCommand(ind);
	if (cmd == -1) return false;	
	double lots = this.GetLots(); 
	if(lots <= 0) return false;
	
    double price, stoploss, takeprofit;
    color clr = clrBlue;    
    if (cmd == 1) clr = clrRed;
	
    if (cmd == 0)
    {
	    price = NormalizeDouble(Ask, Digits);
		stoploss = price - this.StopLoss * gl_basePoint;
		takeprofit = price + this.TakeProfit * gl_basePoint;		
	}
	else
	{
	    price = NormalizeDouble(Bid, Digits);
	    stoploss = price + this.StopLoss * gl_basePoint;
	    takeprofit = price - this.TakeProfit * gl_basePoint;	    
	}

	if (IsValidSL(cmd, stoploss) && IsValidTP(cmd, takeprofit)) 
	{
		int ticket = OrderSend(Symbol(), cmd, lots, price, gl_slippage, stoploss, takeprofit, IntegerToString(MagicNumber), MagicNumber, 0, clr);
		if(ticket>=0) 
		{
		    this.LastSendTime = TimeCurrent();
		    PrintIndicator4Order(ind, cmd);
		    return(true);	
		}    
		else
		    Print("下单失败,错误原因："+iGetErrorInfo(GetLastError()));				
	
	}	
    
    return false;
};
void BaseStrategy::PrintIndicator4Order(CIndicator *ind, int cmd)
{
};

bool BaseStrategy::ModifyOrder(int cmd, CIndicator* ind)
{
    if (TimeCurrent() < this.LastModifyTime + this.ModifySpan) return false;
    
    double adjustPoint = GetAdjustPoint(cmd, ind);	    	
	
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
                    this.LastModifyTime = TimeCurrent();
                    rtn = true;
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
			        this.LastModifyTime = TimeCurrent();
			        rtn = true;
			   }
			   else
			        Print("Buy单(",OrderTicket(),")修改失败,错误原因："+iGetErrorInfo(GetLastError()));			   
			}
		}
	}
	
    	
	return (rtn);
};

double BaseStrategy::GetAdjustPoint(int cmd, CIndicator* ind)
{   	
		double adjustPoint = 0;
		double backPoint = 0;
		double profit = 0;
		bool hasProtected = false;
			
		backPoint = this.BackPoint * gl_basePoint;
        
        if(!UsePB) return (-1*backPoint);
        
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
		
		if (profit >= PBfrom * gl_basePoint)
		{
		 	if (backPoint == 0) 
		 	{
		 		adjustPoint = PBto * gl_basePoint;		 		
		 	}
		 	else
		 	{
		 		if(profit < backPoint + PBto * gl_basePoint) 
		 			adjustPoint = PBto * gl_basePoint;
		 		else
		 			adjustPoint = -1 * backPoint;
		 	}
		}	
		if(adjustPoint > 0 && hasProtected) adjustPoint = 0; //only protect the first time.
		
		return (adjustPoint);
};

bool BaseStrategy::TobeClosed(int cmd,CIndicator *ind)
{
    return false;
}

bool BaseStrategy::CloseOrder(int cmd)
{    	    
    bool rtn = false;
	
	//RefreshRates();		
    if (cmd == OP_BUY)
		rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), gl_slippage, clrBlue);
	else
		rtn = OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), gl_slippage, clrRed);
	
	if(!rtn) Print("订单(",OrderTicket(),")关闭失败,错误原因："+iGetErrorInfo(GetLastError()));	       	
	
	return(rtn);
};
