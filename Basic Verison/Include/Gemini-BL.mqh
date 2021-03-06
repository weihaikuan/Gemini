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
   		//Print("OrdersHistoryTotal=", OrdersHistoryTotal());
   		for (i=OrdersHistoryTotal() - 1; i >= 0; i--)
		{
			if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) return;
			if (OrderMagicNumber() == this.magic) break;
			//Print("cmd=",OrderType(), " chajia=", OrderClosePrice()- OrderOpenPrice(), " Open=", OrderOpenPrice()," close=",OrderClosePrice());
			//if(OrderCloseTime() < TimeCurrent() - gl_doubleLotsSpan - 5 * 50) return;
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
				if (ordercmd = 0)
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
			
			if(++count == 50) break; //only get 5 orders from history
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
				int ticket = OrderSend(Symbol(), cmd, lots, price, 30, stoploss, takeprofit, IntegerToString(magic), magic, 0, clr);
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
        //Print("Strategy01::TobeClosed", " magic=", this.magic);
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
        magic = magic999;         
    }
    ~Strategy999()
    {
        CleanOrder();
    }
};

class Strategy01 : public BaseStrategy
{
public:
    double MA_Margin_out;
 
    
    bool TobeClosed(int cmd, CIndicator* ind)
    {
        //Print("Strategy01::TobeClosed", " magic=", this.magic);
        bool toBeClosed = false;

		if (cmd == OP_BUY && ind.wpr_H4 > (-WPRClose)) 
			toBeClosed = true;
		else if (cmd == OP_SELL && ind.wpr_H4 < WPRClose + (-100))
			toBeClosed = true;
					
    	return(toBeClosed);    	
    	
    };        
    
    virtual int GetCommand(CIndicator* ind)
    {
        //Print("Strategy02::GetCommand", " magic=", this.magic);
        int rtn = -1;        

    	if(ind.wpr_H4 < WPROpen + (-100) && Bid > ind.close_M15 - (-5)*gl_basePoint    	    
    	    && ind.adx_H4 > 55
    	    )    	
    	{ 
    	    rtn = 0; 	
    	}
    	else if (ind.wpr_H4 > -WPROpen && Bid < ind.close_M15 + (-5)*gl_basePoint    	    
    	    && ind.adx_H4 > 55
    	    )
    	{ 
    	    rtn = 1;
    	}
    	
    	return(rtn);
    };
    
    Strategy01(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        magic = magic01;
    }
    ~Strategy01()
    {
        CleanOrder();
    }
};

class Strategy02 : public BaseStrategy
{
public:
    double MA_Margin_out;

    bool TobeClosed(int cmd, CIndicator* ind)
    {
        //Print("Strategy02::TobeClosed", " magic=", this.magic);
        bool toBeClosed = false;        

		if (cmd == OP_BUY && ind.wpr_M15 > (-WPRClose) && Bid > ind.close_M15 - 5 * gl_basePoint) 
			toBeClosed = true;
		else if (cmd == OP_SELL && ind.wpr_M15 < WPRClose + (-100) && Bid < ind.close_M15 + 5 * gl_basePoint)
			toBeClosed = true;
					
    	return(toBeClosed);    	
    	
    };        
    
    virtual int GetCommand(CIndicator* ind)
    {
        //Print("Strategy02::GetCommand", " magic=", this.magic);
        int rtn = -1;        

    	if(ind.wpr_M15 < WPROpen + (-100) && Bid > ind.close_M15 - (-5)*gl_basePoint
    	    && (ind.adx_H1 <20 && ind.adx_M15<20
    	       || ind.adx_M15 < 30 && ind.adx_M15 >= 20 && ind.adx_M15_pDI > ind.adx_M15_mDI)
    	    )    	
    	{ 
    	    rtn = 0; 	
    	}
    	else if (ind.wpr_M15 > -WPROpen && Bid < ind.close_M15 + (-5)*gl_basePoint
    	    && (ind.adx_H1 <20 && ind.adx_M15<20
    	       || ind.adx_M15 < 30 && ind.adx_M15 >= 20 && ind.adx_M15_pDI < ind.adx_M15_mDI)
    	    )
    	{ 
    	    rtn = 1;
    	}
    	
    	return(rtn);
    };
    
    Strategy02(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        magic = magic02;
    }
    ~Strategy02()
    {
        CleanOrder();
    }
};


class Strategy03 : public BaseStrategy
{
public:
    double MA_Margin_out;
    
    bool TobeClosed(int cmd, CIndicator* ind)
    {
        //Print("Strategy03::TobeClosed", " magic=", this.magic);
        bool toBeClosed = false;
        if (cmd == OP_BUY && ind.close_M5 <= ind.ma_H1_1 - ind.atr_H1_19*1.4 - 13*gl_basePoint)
			toBeClosed = true;
		else if (cmd == OP_SELL && ind.close_M5 >= ind.ma_H1_1 + ind.atr_H1_19*1.4 + 13*gl_basePoint)
			toBeClosed = true;
		
    	return(toBeClosed);    	
    	
    };        
    
    virtual int GetCommand(CIndicator* ind)
    {
        //Print("Strategy03::GetCommand", " magic=", this.magic);
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
        
    Strategy03(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan) 
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        magic = magic03;  
    }
    ~Strategy03()
    {
        CleanOrder();
    }
};

class Strategy04 : public Strategy03
{
public:
    
    int GetCommand(CIndicator* ind)
    {
        
        //Print("Strategy04::GetCommand", " magic=", this.magic);
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
    
    Strategy04(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan) 
        : Strategy03(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        magic = magic04; 

    }
    ~Strategy04()
    {
        CleanOrder();
    }
};


class Strategy05 : public BaseStrategy
{
public:
    double MA_Margin_out;
    
    bool TobeClosed(int cmd, CIndicator* ind)
    {
        //Print("Strategy05::TobeClosed", " magic=", this.magic);
        bool toBeClosed = false;
        if (cmd == OP_BUY && ind.bandup_H1 - ind.bandlow_H1 >= 30 * gl_basePoint && ind.high_H1 > ind.bandup_H1 - 3 * gl_basePoint)
			toBeClosed = true;	
		else if (cmd == OP_SELL && ind.bandup_H1 - ind.bandlow_H1 >= 30 * gl_basePoint && ind.low_H1 < ind.bandlow_H1 + 3 * gl_basePoint)
		    toBeClosed = true;
	    
    	return(toBeClosed);
    };
    
    int GetCommand(CIndicator* ind)
    {
        //Print("Strategy05::GetCommand", " magic=", this.magic);
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
    
    Strategy05(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan) 
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        magic = magic05;  
    }
    ~Strategy05()
    {
        CleanOrder();
    }
};

class Strategy06 : public BaseStrategy
{
public: 
	double Division;
	
    bool TobeClosed(int cmd, CIndicator* ind)
    {
        //Print("Strategy05::TobeClosed", " magic=", this.magic);
        bool toBeClosed = false;
	    
    	return(toBeClosed);
    };
    
    virtual int GetCommand(CIndicator* ind)
    {
        //Print("Strategy05::GetCommand", " magic=", this.magic);
        int rtn = -1;
        if (ind.adx_H4 > Division && ind.adx_H4 > ind.adx_H4_prv1 && ind.adx_H4_prv1 > ind.adx_H4_prv2 && ind.adx_H4_prv1 < Division && ind.adx_H4_pDI > ind.adx_H4_mDI)
   	    	rtn = 0; 		
    	else if(ind.adx_H4 > Division && ind.adx_H4 > ind.adx_H4_prv1 && ind.adx_H4_prv1 > ind.adx_H4_prv2 && ind.adx_H4_prv1 < Division && ind.adx_H4_pDI < ind.adx_H4_mDI)
    	    rtn = 1;    		
    	    
    	return(rtn);
    };
    
    Strategy06(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan, int division = 25) 
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan)
    {
        magic = magic06;  
        Division = division;
    }
    ~Strategy06()
    {
        CleanOrder();
    }
};
class Strategy07 : public Strategy06
{
public:   
    int GetCommand(CIndicator* ind)
    {
        //Print("Strategy05::GetCommand", " magic=", this.magic);
        int rtn = -1;
        if (ind.adx_D1 > Division && ind.adx_D1 > ind.adx_D1_prv1 && ind.adx_D1_prv1 > ind.adx_D1_prv2 && ind.adx_D1_prv1 < Division && ind.adx_D1_pDI > ind.adx_D1_mDI)
   	    	rtn = 0; 		
    	else if(ind.adx_D1 > Division && ind.adx_D1 > ind.adx_D1_prv1 && ind.adx_D1_prv1 > ind.adx_D1_prv2 && ind.adx_D1_prv1 < Division && ind.adx_D1_pDI < ind.adx_D1_mDI)
    	    rtn = 1;   		
    	    
    	return(rtn);
    };
    
    Strategy07(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan, int division = 25) 
        : Strategy06(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan, division)
    {
        magic = magic07;  
    }
    ~Strategy07()
    {
        CleanOrder();
    }
};
class Strategy08 : public Strategy06
{
public:  
    int GetCommand(CIndicator* ind)
    {
        //Print("Strategy05::GetCommand", " magic=", this.magic);
        int rtn = -1;
        if (ind.adx_W1 > Division && ind.adx_W1 > ind.adx_W1_prv1 && ind.adx_W1_prv1 > ind.adx_W1_prv2 && ind.adx_W1_prv1 < Division && ind.adx_W1_pDI > ind.adx_W1_mDI)
   	    	rtn = 0; 		
    	else if(ind.adx_W1 > Division && ind.adx_W1 > ind.adx_W1_prv1 && ind.adx_W1_prv1 > ind.adx_W1_prv2 && ind.adx_W1_prv1 < Division && ind.adx_W1_pDI < ind.adx_W1_mDI)
    	    rtn = 1;   		
    	    
    	return(rtn);
    };
    
    Strategy08(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan, int division = 30) 
        : Strategy06(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan,division)
    {
        magic = magic08;  
    }
    ~Strategy08()
    {
        CleanOrder();
    }
};

class Strategy001 : public BaseStrategy
{
public:
    double MA_Margin_out;
 
   virtual int GetCommand(CIndicator* ind)
    {
        //Print("Strategy02::GetCommand", " magic=", this.magic);
        int rtn = -1;        

    	if(ind.adx_D1<30 && ind.wpr_M5 < WPROpen + (-100) && ind.adx_M5<30 && ind.adx_M5_pDI > ind.adx_M5_mDI)    	
			rtn = 0;  
    	else if (ind.adx_D1<30 && ind.wpr_M5 > -WPROpen && ind.adx_M5<30 && ind.adx_M5_pDI < ind.adx_M5_mDI)
       	    rtn = 1;
    	
    	return(rtn);
    };
    
    Strategy001(double lots, int maxordercount, int stoploss, int takeprofit, int backpoint, int sendspan, int modifyspan, bool usePB = false, int pbfrom = 0, int pbto = 0)
        : BaseStrategy(lots, maxordercount,stoploss,takeprofit,backpoint, sendspan, modifyspan,usePB,pbfrom,pbto)
    {
        magic = magic001;
    }
    ~Strategy001()
    {
        CleanOrder();
    }
};