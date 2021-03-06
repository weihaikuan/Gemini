#include <Gemini-Lib.mqh>

class Strategy999 : public BaseStrategy
{
private:
	bool HasDoubleLots()
	{
		bool hasDoubleLots = false;
		for (int i=OrdersTotal() - 1; i >= 0; i--)
		{
			if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) return true;
			if(OrderMagicNumber() == magic999) 
			{ 
				hasDoubleLots = true;
				break;
			}			   
		}
		return(hasDoubleLots);
	}
	
public:	
   	void SendOrder()
   	{
   		if(HasDoubleLots()) return;
   		
   		int i; int count = 0;
   		int cmd = -1;
   		double lots = 0;

   		for (i=OrdersHistoryTotal() - 1; i >= 0; i--)
		{
			if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) return;
			if (OrderMagicNumber() == this.MagicNumber) break;
			if((	OrderType() == 0 && OrderClosePrice() - OrderOpenPrice() <= -199 * gl_basePoint)				
				|| (OrderType() == 1 && OrderClosePrice() - OrderOpenPrice() >= 199 * gl_basePoint)	)
			{
	        	if(cmd != -1 && OrderType() != cmd) 
	        	{
	        		Print("倍仓失败！历史账单有问题，不符合逻辑，请检查"); 
	        		return;
	        	}
	        	
	        	//止损开同向单
	        	cmd = OrderType(); 
	        	lots += OrderLots();
	        }   
	        else if((OrderType() == 0 && OrderClosePrice() - OrderOpenPrice() >= 199 * gl_basePoint)				
				|| (OrderType() == 1 && OrderClosePrice()- OrderOpenPrice() <= -199 * gl_basePoint))
			{
				
				//止盈开反向单
				int ordercmd = OrderType();
				if (ordercmd == 0)
					ordercmd = 1;
				else
					ordercmd = 0;
					
	        	if(cmd != -1 && ordercmd != cmd) 
	        	{
	        		Print("倍仓失败！历史账单有问题，不符合逻辑，请检查"); 
	        		return;
	        	}
	        	cmd = ordercmd;
	        	lots += OrderLots();
	        }      
			
			if(++count == 50) break;
		}	
   		
	    if(cmd != -1 && lots > 0)
	    {
	    	lots *= 2;
	    	
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
				    return;	
				}    
				else
				    Print("下单失败,错误原因："+iGetErrorInfo(GetLastError()));				
			
			}	
	    }
   	}
    bool TobeClosed(int cmd, CIndicator* ind)
    {
        bool toBeClosed = false;				
    	return(toBeClosed);    	
    	
    };        
    
    int GetCommand(CIndicator* ind)
    {
        int rtn = -1;    
    	return(rtn);
    };
    Strategy999(double lots = 0, int maxordercount = 1, int stoploss = 100, int takeprofit = 500, int backpoint = 100)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint)
    {
        MagicNumber = magic999;         
    }
    ~Strategy999()
    {
        CleanOrder();
    }
};


class Strategy1 : public BaseStrategy
{
public:
    double MA_Margin_out;
    int WPROpen;  
    double Division;

    double Adx;
    double Wpr;

public:  
    virtual void SetIndicator(CIndicator* ind) = NULL;
    void PrintIndicator4Order(CIndicator* ind, int cmd)
    {
        Print("cmd=", cmd, ", Adx=", Adx, ", Wpr=", Wpr, ", Division=", Division, ", WPROpen=", WPROpen);
    } 
    
    int GetCommand(CIndicator* ind)
    {
        SetIndicator(ind);
        int rtn = -1;        

    	if(Adx < Division && Wpr < WPROpen + (-100))    	
    	{     	    
    	    rtn = 0; 	
    	}
    	else if (Adx < Division && Wpr > -WPROpen)
    	{     	    
    	    rtn = 1;
    	}
    	
    	return(rtn);
    };
 public:    
    Strategy1(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan, int wpropen, int division)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        WPROpen = wpropen;
        Division = division;
    }
    ~Strategy1()
    {
        CleanOrder();
    }
};

//2，15分钟WPR+15分钟ADX震荡
class Strategy11 : public Strategy1
{
public:
    void SetIndicator(CIndicator* ind)
    {
        Adx = ind.adx_M5;
        Wpr = ind.wpr_M5;   
    }
    
    Strategy11(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.11, int stoploss=350, int takeprofit=200,int backpoint=20,int wpropen=6,int division=25)
        : Strategy1(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan,wpropen, division)
    {
        MagicNumber = magic11;        
    }   
};
//3，5分钟WPR+5分钟ADX震荡
class Strategy12 : public Strategy1
{
public:
    void SetIndicator(CIndicator* ind)
    {
        Adx = ind.adx_M15;
        Wpr = ind.wpr_M15;   
    }
    
    Strategy12(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.11, int stoploss=350, int takeprofit=200,int backpoint=20,int wpropen=6,int division=25)
        : Strategy1(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan,wpropen, division)
    {
        MagicNumber = magic12;        
    }   
};
class Strategy13 : public Strategy1
{
public:
    void SetIndicator(CIndicator* ind)
    {
        Adx = ind.adx_M30;
        Wpr = ind.wpr_M30;   
    }
    
    Strategy13(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.11, int stoploss=350, int takeprofit=200,int backpoint=20,int wpropen=6,int division=25)
        : Strategy1(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan,wpropen, division)
    {
        MagicNumber = magic13;        
    }   
};
class Strategy14 : public Strategy1
{
public:
    void SetIndicator(CIndicator* ind)
    {
        Adx = ind.adx_H1;
        Wpr = ind.wpr_H1;   
    }
    
    Strategy14(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.11, int stoploss=350, int takeprofit=200,int backpoint=20,int wpropen=6,int division=25)
        : Strategy1(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan,wpropen, division)
    {
        MagicNumber = magic14;        
    }   
};


class Strategy2 : public BaseStrategy
{
public:
    double MA;
    int Mamargin;  
    double Division;
    double Adx;
    double AdxPDI;
    double AdxMDI;
    double AdxP1;
    double AdxP2;

public:  
    virtual void SetIndicator(CIndicator* ind) = NULL;
    void PrintIndicator4Order(CIndicator* ind, int cmd)
    {
        Print("cmd=", cmd, ", Adx=", Adx, ", AdxP1=", AdxP1, ", AdxP2=", AdxP2, ", AdxPDI=", AdxPDI, ", AdxMDI=", AdxMDI, ", MA=", MA);
    } 
    /*4小时：三线确认ADX上穿25，（前线<上线<25,上线+3<当前线，且当前线>=25.）；+DI>-DI,且对应K线收盘价在均线MA（14）上方，做买单。
            三线确认ADX上穿25，（前线<上线<25,上线+3<当前线，且当前线>=25.）；+DI<-DI,且对应K线收盘价在均线MA（14）下方，做卖单。
            止损：建仓K线对应的MA（14）外+20点。
            止盈：100点。
             移动跟损：20点。
    */
    int GetCommand(CIndicator* ind)
    {
        SetIndicator(ind);
        int rtn = -1;        

    	if(Adx > Division && AdxP1+3*gl_basePoint < Adx && AdxP2 < AdxP1 && AdxP1 < Division && AdxPDI > AdxMDI && Ask > MA)    	
    	{ 
    	    this.StopLoss = (Ask - (MA - Mamargin * gl_basePoint)) / gl_basePoint;
    	    Print("MA=",MA,",Mamargin=", Mamargin, ",Bid=", Ask, ", StopLoss=", StopLoss);
    	    rtn = 0; 	    	    
    	}
    	else if (Adx > Division && AdxP1+3*gl_basePoint < Adx && AdxP2 < AdxP1 && AdxP1 < Division && AdxPDI < AdxMDI && Bid < MA)   
    	{     	
    	    this.StopLoss = ((MA + Mamargin * gl_basePoint) - Bid) / gl_basePoint; 
    	    Print("MA=",MA,",Mamargin=", Mamargin, ",Bid=", Bid, ", StopLoss=", StopLoss);
    	    rtn = 1;
    	}
    	
    	return(rtn);
    };
 public:    
    Strategy2(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan, int mamargin, int division)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        Mamargin = mamargin;
        Division = division;
        this.TakeProfit = takeprofit;
    }
    ~Strategy2()
    {
        CleanOrder();
    }
};

class Strategy21 : public Strategy2
{
public:
    void SetIndicator(CIndicator* ind)
    {
        Adx = ind.adx_H4;
        AdxP2 = ind.adx_H4_prv2;  
        AdxP1 = ind.adx_H4_prv1;
        AdxPDI = ind.adx_H4_pDI;
        AdxMDI = ind.adx_H4_mDI;
        MA = ind.ma_H4_14;
    }
    
    Strategy21(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.21, int stoploss=0, int takeprofit=100, int backpoint=20, int mamargin=20, int division=25)
        : Strategy2(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan,mamargin, division)
    {
        MagicNumber = magic21;        
    }   
    
};

class Strategy22 : public Strategy2
{
public:
    void SetIndicator(CIndicator* ind)
    {
        Adx = ind.adx_W1;
        AdxP2 = ind.adx_W1_prv2;  
        AdxP1 = ind.adx_W1_prv1;
        AdxPDI = ind.adx_W1_pDI;
        AdxMDI = ind.adx_W1_mDI;
        MA = ind.ma_W1_14;
    }
    
    Strategy22(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.21, int stoploss=0, int takeprofit=100, int backpoint=20, int mamargin=20, int division=25)
        : Strategy2(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan,mamargin, division)
    {
        MagicNumber = magic22;        
    }   
    
};

//3，5分钟布林带+5分钟ATR突破
class Strategy3 : public BaseStrategy
{
public:
    double MA_Margin_out;
    void PrintIndicator4Order(CIndicator* ind, int cmd)
    {
        Print("cmd=", cmd, ", bandup_M5=", ind.bandup_M5, ", bandlow_M5=", ind.bandlow_M5, ", atr_M5_19=", ind.atr_M5_19, ", close_M5=", ind.close_M5, 
         ", rsi_M5=", ind.rsi_M5, ", ma_M5_700=", ind.ma_M5_700);
    } 
    
    bool TobeClosed(int cmd, CIndicator* ind)
    {
        bool toBeClosed = false;
        if (cmd == OP_BUY && ind.close_M5 <= ind.ma_H1_1 - ind.atr_H1_19*1.4 - 13*gl_basePoint)
			toBeClosed = true;
		else if (cmd == OP_SELL && ind.close_M5 >= ind.ma_H1_1 + ind.atr_H1_19*1.4 + 13*gl_basePoint)
			toBeClosed = true;
		
    	return(toBeClosed);    	
    	
    };        
    
    int GetCommand(CIndicator* ind)
    {
        int rtn = -1;       
        if (Ask >= ind.bandup_M5 + 0.0005 && ind.atr_M5_19 <= 0.0002 && ind.close_M5 < ind.ma_M5_700 + MA_Margin_out * gl_basePoint
        	&& ind.rsi_M5 < 70) //Buy
    	{
    	    rtn = 0; 		
    	}
    	else if (Bid <= ind.bandlow_M5 - 0.0005 && ind.atr_M5_19 <= 0.0002 && ind.close_M5 > ind.ma_M5_700 - MA_Margin_out * gl_basePoint
    		&& ind.rsi_M5 > 30) //Sell
    	{
    	    rtn = 1; 		
    	}
    	
    	return(rtn);    
    };
        
    Strategy3(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.21, int stoploss=0, int takeprofit=100, int backpoint=20, int mamargin=20)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        this.MagicNumber = magic3;  
        MA_Margin_out = mamargin;
    }
    ~Strategy3()
    {
        CleanOrder();
    }
};
//4，5分钟布林带+1小时MA突破系统；
class Strategy4 : public BaseStrategy
{
public:
    double MA_Margin_out;
    void PrintIndicator4Order(CIndicator* ind, int cmd)
    {
        Print("cmd=", cmd, ", ma_H1_1=", ind.ma_H1_1, ", atr_H1_19=", ind.atr_H1_19, ", close_M5=", ind.close_M5, ", rsi_M5=", ind.rsi_M5, ", ma_M5_700=", ind.ma_M5_700);
    } 
    bool TobeClosed(int cmd, CIndicator* ind)
    {
        bool toBeClosed = false;
        if (cmd == OP_BUY && ind.close_M5 <= ind.ma_H1_1 - ind.atr_H1_19*1.4 - 13*gl_basePoint)
			toBeClosed = true;
		else if (cmd == OP_SELL && ind.close_M5 >= ind.ma_H1_1 + ind.atr_H1_19*1.4 + 13*gl_basePoint)
			toBeClosed = true;
		
    	return(toBeClosed);    	
    	
    };     
    int GetCommand(CIndicator* ind)
    {
 
		int rtn = -1;       

        if (ind.close_M5 >= ind.ma_H1_1 + ind.atr_H1_19*1.4 + 13 * gl_basePoint && ind.close_M5 < ind.ma_M5_700 + MA_Margin_out * gl_basePoint
        	&& ind.rsi_M5 < 70)		
		{
    	    rtn = 0; 		
    	}
	    else if (ind.close_M5 <= ind.ma_H1_1 - ind.atr_H1_19*1.4 - 13 * gl_basePoint && ind.close_M5 > ind.ma_M5_700 - MA_Margin_out * gl_basePoint
	    	&& ind.rsi_M5 > 30) //Sell
	    {
    	    rtn = 1;
    	}
	   
    	return(rtn);
    };
    
    Strategy4(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.21, int stoploss=0, int takeprofit=100, int backpoint=20, int mamargin=20)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        this.MagicNumber = magic4;
        this.MA_Margin_out = mamargin; 

    }
    ~Strategy4()
    {
        CleanOrder();
    }
};


//5. 700MA外200点抄底
class Strategy5 : public BaseStrategy
{
public:
    double MA_Margin_out;
    void PrintIndicator4Order(CIndicator* ind, int cmd)
    {
        Print("cmd=", cmd, ", bandup_H1=", ind.bandup_H1, ", bandlow_H1=", ind.bandlow_H1, ", low_H1=", ind.low_H1, ", high_H1=", ind.high_H1, ", close_M5=", ind.close_M5, 
         ", rsi_M5=", ind.rsi_M5, ", ma_M5_700=", ind.ma_M5_700);
    } 
    bool TobeClosed(int cmd, CIndicator* ind)
    {
        bool toBeClosed = false;
        if (cmd == OP_BUY && ind.bandup_H1 - ind.bandlow_H1 >= 30 * gl_basePoint && ind.high_H1 > ind.bandup_H1 - 3 * gl_basePoint)
			toBeClosed = true;	
		else if (cmd == OP_SELL && ind.bandup_H1 - ind.bandlow_H1 >= 30 * gl_basePoint && ind.low_H1 < ind.bandlow_H1 + 3 * gl_basePoint)
		    toBeClosed = true;
	    
    	return(toBeClosed);
    };
    
    int GetCommand(CIndicator* ind)
    {
        int rtn = -1;
        if (ind.bandup_H1 - ind.bandlow_H1 >= 30 * gl_basePoint && ind.low_H1 < ind.bandlow_H1 + 3 * gl_basePoint
    		&& ind.close_M5 < ind.ma_M5_700 - MA_Margin_out * gl_basePoint)
    		
    	{
    	    rtn = 0; 		
    	}
    	else if(ind.bandup_H1 - ind.bandlow_H1 >= 30 * gl_basePoint && ind.high_H1 > ind.bandup_H1 - 3 * gl_basePoint
    		&& ind.close_M5 > ind.ma_M5_700 + MA_Margin_out * gl_basePoint)
    		
    	{
    	    rtn = 1;    		
    	}
    	    
    	return(rtn);
    };
    
    Strategy5(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.21, int stoploss=0, int takeprofit=100, int backpoint=20, int mamargin=20)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        this.MagicNumber = magic5;  
        MA_Margin_out = mamargin;
    }
    ~Strategy5()
    {
        CleanOrder();
    }
};

//6，4小时WPR+4小时ADX反转系统
class Strategy6 : public BaseStrategy
{
public:
    int WPROpen;
    double Division;  
    void PrintIndicator4Order(CIndicator* ind, int cmd)
    {
        Print("cmd=", cmd, ", wpr_H4=", ind.wpr_H4, ", adx_H4=", ind.adx_H4, ", close_M15=", ind.close_M15, ", Bid=", Bid);
    }
    int GetCommand(CIndicator* ind)
    {
        int rtn = -1;        

    	if(ind.wpr_H4 < WPROpen + (-100) && Bid > ind.close_M15 - (-5)*gl_basePoint    	    
    	    && ind.adx_H4 > Division
    	    )    	
    	{ 
    	    rtn = 0; 	
    	}
    	else if (ind.wpr_H4 > -WPROpen && Bid < ind.close_M15 + (-5)*gl_basePoint    	    
    	    && ind.adx_H4 > Division
    	    )
    	{ 
    	    rtn = 1;
    	}
    	
    	return(rtn);
    };
    
    Strategy6(int maxordercount, int sendspan=300, int modifyspan=5, double lots=0.21, int stoploss=0, int takeprofit=100, int backpoint=20, int wpropen=6, int division = 55)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        this.MagicNumber = magic6;
        WPROpen = wpropen;
        Division = division;
    }
    ~Strategy6()
    {
        CleanOrder();
    }
};