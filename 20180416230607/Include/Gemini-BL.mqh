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
				if(ind.adx_M5 < Division && ind.wpr_M5 < WPROpen + (-100) && ind.close_M5 < ind.ma_M5_700 + 60 * gl_basePoint)
					rtn = 0;
				else if (ind.adx_M5 < Division && ind.wpr_M5 > -WPROpen && ind.close_M5 > ind.ma_M5_700 - 60 * gl_basePoint )
					rtn = 1;
				break;
			case 12:
				if(ind.rsi_M5 < 30 && ind.close_M5 < ind.ma_M5_700 + 60 * gl_basePoint)
					rtn = 0;
				else if ( ind.rsi_M5 > 70 && ind.close_M5 > ind.ma_M5_700 - 60 * gl_basePoint)
					rtn = 1;
				break;
			case 21:
				if(Ask >= ind.ma_M5_700 + From21 * gl_basePoint && Ask <= ind.ma_M5_700 + To21 * gl_basePoint && Ask > ind.ma_M5_100)
					rtn = 0;
				else if (Bid <= ind.ma_M5_700 - From21 * gl_basePoint && Bid >= ind.ma_M5_700 - To21 * gl_basePoint && Bid < ind.ma_M5_100)
					rtn = 1;
				
				this.StopLoss = 160;
				this.TakeProfit = ind.ma_M5_700 / gl_basePoint - 20;
				break;
			case 22:
			{
			    double high_h0 = iHigh(NULL, PERIOD_H1, 0);
			    double high_h1 = iHigh(NULL, PERIOD_H1, 1);
			    double high_h2 = iHigh(NULL, PERIOD_H1, 2);
			    double high_h3 = iHigh(NULL, PERIOD_H1, 3);
			    double high_4 = high_h0 > high_h1 ? high_h0 : high_h1;
			    high_4 = high_4 > high_h2 ? high_4 : high_h2;
			    high_4 = high_4 > high_h3 ? high_4 : high_h3;
			    
			    double low_h0 = iLow(NULL, PERIOD_H1, 0);
			    double low_h1 = iLow(NULL, PERIOD_H1, 1);
			    double low_h2 = iLow(NULL, PERIOD_H1, 2);
			    double low_h3 = iLow(NULL, PERIOD_H1, 3);
			    double low_4 = low_h0 > low_h1 ? low_h0 : low_h1;
			    low_4 = low_4 > low_h2 ? low_4 : low_h2;
			    low_4 = low_4 > low_h3 ? low_4 : low_h3;

			    double atr_h4 = iATR(NULL, PERIOD_H4, 1, 1);

			    int atrPoint = atr_h4 / gl_basePoint;
			    
				if(atrPoint > 50 && Ask < high_4 - atrPoint / 2 * gl_basePoint && ind.rsi_M5 < 30)
					rtn = 0;					
				else if (atrPoint > 50 && Ask > low_4 - atrPoint / 2 * gl_basePoint && ind.rsi_M5 > 70)
					rtn = 1;
				
				this.TakeProfit = 40;
				this.StopLoss = atrPoint/2 + 25;
			}
				break;
			case 3:
				if (Ask >= ind.bandup_M5 + 0.0005 && ind.atr_M5_19 <= 0.0002 && ind.close_M5 < ind.ma_M5_700 + MAMargin * gl_basePoint	&& ind.rsi_M5 < 70)
					rtn = 0; 		
				else if (Bid <= ind.bandlow_M5 - 0.0005 && ind.atr_M5_19 <= 0.0002 && ind.close_M5 > ind.ma_M5_700 - MAMargin * gl_basePoint && ind.rsi_M5 > 30)
					rtn = 1;
				break;
			case 4:
				if (ind.close_M5 >= ind.ma_H1_1 + ind.atr_H1_19*1.4 + 13 * gl_basePoint && ind.close_M5 < ind.ma_M5_700 + MAMargin * gl_basePoint && ind.rsi_M5 < 70)		
					rtn = 0;
				else if (ind.close_M5 <= ind.ma_H1_1 - ind.atr_H1_19*1.4 - 13 * gl_basePoint && ind.close_M5 > ind.ma_M5_700 - MAMargin * gl_basePoint	&& ind.rsi_M5 > 30)
					rtn = 1;
				break;
			case 5:
				if (ind.bandup_H1 - ind.bandlow_H1 >= 30 * gl_basePoint && ind.low_H1 < ind.bandlow_H1 + 3 * gl_basePoint && ind.close_M5 < ind.ma_M5_700 - MAMargin * gl_basePoint)
					rtn = 0; 		
				else if(ind.bandup_H1 - ind.bandlow_H1 >= 30 * gl_basePoint && ind.high_H1 > ind.bandup_H1 - 3 * gl_basePoint && ind.close_M5 > ind.ma_M5_700 + MAMargin * gl_basePoint)
					rtn = 1;    		
				break;
			case 6:
				if(ind.wpr_H4 < WPROpen + (-100) && Bid > ind.close_M15 - (-5)*gl_basePoint && ind.adx_H4 > Division)    	
					rtn = 0; 	
				else if (ind.wpr_H4 > -WPROpen && Bid < ind.close_M15 + (-5)*gl_basePoint && ind.adx_H4 > Division)
					rtn = 1;
				break;			
			case 999:
			{
				rtn = GetCMD4Patch();
				if(rtn == 0 && ind.rsi_M5 < 30)
				    rtn = 0;
				else
				if (rtn == 1 && ind.rsi_M5 > 70)
				    rtn = 1;
				else
				    rtn = -1;
			}
				break;
		}
		
		if(rtn != GetTrend()) rtn = -1;		
		
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
		
		double lossPoint, slPoint;
	
		if (OrderType() == 0)
		{
			lossPoint = OrderOpenPrice() - Bid;
			slPoint = OrderOpenPrice() - OrderStopLoss();
		}
		else
		{
			lossPoint = Ask - OrderOpenPrice();
			slPoint = OrderStopLoss() - OrderOpenPrice();
		}
	
		if(PatchPoint > 0 && lossPoint > PatchPoint * gl_basePoint)
		{
			rtn = OrderType();
			break;
		}
		else
		if(PatchPoint < 0 && lossPoint < PatchPoint * gl_basePoint)
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
