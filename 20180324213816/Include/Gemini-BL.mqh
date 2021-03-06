#include <Gemini-Lib.mqh>

class Strategy111 : public BaseStrategy
{
public:
    int WPROpen;  
	int MAMargin;
    int Division;
    int From21;
    int To21;


public:  
    int GetCommand(CIndicator* ind)
    {
        if(ind.rsi_H4 > RSILimit || ind.rsi_H4 < 100 - RSILimit) return(-1);        

		int rtn = -1; 
		
		switch(Magic)
		{
			case 11:
				if(ind.wpr_M5 < WPROpen + (-100) && ind.close_M5 < ind.ma_M5_700 + 60 * BasePoint && Trend == 0)
					rtn = 0;
				else if (ind.wpr_M5 > -WPROpen && ind.close_M5 > ind.ma_M5_700 - 60 * BasePoint && Trend == 1)
					rtn = 1;
				break;
			case 12:
				if(ind.rsi_M5 < 30 && ind.close_M5 < ind.ma_M5_700 + 60 * BasePoint && Trend == 0)
					rtn = 0;
				else if ( ind.rsi_M5 > 70 && ind.close_M5 > ind.ma_M5_700 - 60 * BasePoint && Trend == 1)
					rtn = 1;
				break;
			case 21:
				if(Ask >= ind.ma_M5_700 + From21 * BasePoint && Ask <= ind.ma_M5_700 + To21 * BasePoint && Ask > ind.ma_M5_100)
					rtn = 0;
				else if (Bid <= ind.ma_M5_700 - From21 * BasePoint && Bid >= ind.ma_M5_700 - To21 * BasePoint && Bid < ind.ma_M5_100)
					rtn = 1;
				
				this.StopLoss = 160;
				this.TakeProfit = ind.ma_M5_700 / BasePoint - 20;
				break;
			case 22:
			{
			    ENUM_TIMEFRAMES period = PERIOD_M5;
			    double c1 = iClose(NULL, period, 1);
			    double o1 = iOpen(NULL, period, 1);
			    double c2 = iClose(NULL, period, 2);
			    double o2 = iOpen(NULL, period, 2);
			    double c3 = iClose(NULL, period, 3);
			    double o3 = iOpen(NULL, period, 3);
			    double c4 = iClose(NULL, period, 4);
			    double o4 = iOpen(NULL, period, 4);
			    
			    if(c1>o1 && c2>o2 && c3>o3 && c4>o4 && c1>c2 && c2>c3 && c3>c4 && Trend == 0)
			    {			          	
            	    rtn = 0; 	Print("magic22");		
            	}
        	    else if (c1<o1 && c2<o2 && c3<o3 && c4<o4 && c1<c2 && c2<c3 && c3<c4 && Trend == 1) //Sell
        	    {
            	    rtn = 1; Print("magic22");	
            	}			    
				this.TakeProfit = 100;				
			}
				break;
			case 3:
				if (Ask >= ind.bandup_M5 + 0.0005 && ind.close_M5 < ind.ma_M5_700 + MAMargin * BasePoint	&& ind.rsi_M5 < 70)
					rtn = 0; 		
				else if (Bid <= ind.bandlow_M5 - 0.0005 && ind.close_M5 > ind.ma_M5_700 - MAMargin * BasePoint && ind.rsi_M5 > 30)
					rtn = 1;
				break;
			case 4:
				if (ind.close_M5 >= ind.ma_H1_1 + ind.atr_H1_19*1.4 + 13 * BasePoint && ind.close_M5 < ind.ma_M5_700 + MAMargin * BasePoint && ind.rsi_M5 < 70)		
					rtn = 0;
				else if (ind.close_M5 <= ind.ma_H1_1 - ind.atr_H1_19*1.4 - 13 * BasePoint && ind.close_M5 > ind.ma_M5_700 - MAMargin * BasePoint	&& ind.rsi_M5 > 30)
					rtn = 1;
				break;
			case 5:
				if (ind.bandup_H1 - ind.bandlow_H1 >= 30 * BasePoint && ind.low_H1 < ind.bandlow_H1 + 3 * BasePoint && ind.close_M5 < ind.ma_M5_700 - MAMargin * BasePoint)
					rtn = 0; 		
				else if(ind.bandup_H1 - ind.bandlow_H1 >= 30 * BasePoint && ind.high_H1 > ind.bandup_H1 - 3 * BasePoint && ind.close_M5 > ind.ma_M5_700 + MAMargin * BasePoint)
					rtn = 1;    		
				break;
			case 6:
				if(ind.wpr_H4 < WPROpen + (-100) && Bid > ind.close_M15 - (-5)*BasePoint && ind.adx_H4 > Division)    	
					rtn = 0; 	
				else if (ind.wpr_H4 > -WPROpen && Bid < ind.close_M15 + (-5)*BasePoint && ind.adx_H4 > Division)
					rtn = 1;
				break;			
			case 999:
			{
				rtn = GetCMD4Patch();
				if(rtn != Trend) rtn = -1;				
			}
				break;
		}
		
    	return(rtn);
    };
 public:    
    Strategy111(int magic, int magicnumber): BaseStrategy(magic, magicnumber){ };
    ~Strategy111(){}
    
 private:
 int GetCMD4Patch()
 {
 	if(PatchPoint == 0) return -1;
 	
 	int rtn = -1;
 	for (int i = 0; i < OrdersTotal(); i++)
	{
		if (!SelectOrder(i)) continue;
		
		double lossPoint;
	
		if (OrderType() == 0)
		{
			lossPoint = OrderOpenPrice() - Bid;			
		}
		else
		{
			lossPoint = Ask - OrderOpenPrice();			
		}
	
		if(PatchPoint > 0 && lossPoint > PatchPoint * BasePoint)
		{
			rtn = OrderType();
			break;
		}
		else
		if(PatchPoint < 0 && lossPoint < PatchPoint * BasePoint)
		{
			if(OrderType() == 0)
				rtn = 1;
			else
				rtn = 0;
			break;
		}									
	} 
	
	return(rtn);
 }
 
};
