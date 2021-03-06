#include <Gemini-Lib.mqh>

class Strategy111 : public BaseStrategy
{
public:
    int WPROpen;  
	int MAMargin;
    int Division;
    int PatchPoint;
    int ReversePoint;

public:  
    int GetCommand(CIndicator* ind)
    {
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
				if(ind.adx_H1 < Division && ind.wpr_H1 < WPROpen + (-100) && ind.close_M5 < ind.ma_M5_700 + 60 * gl_basePoint)
					rtn = 0;
				else if (ind.adx_H1 < Division && ind.wpr_H1 > -WPROpen && ind.close_M5 > ind.ma_M5_700 - 60 * gl_basePoint)
					rtn = 1;
				break;
			case 21:
				if(ind.adx_H4 > Division && ind.adx_H4_prv1+3*gl_basePoint < ind.adx_H4 && ind.adx_H4_prv2 < ind.adx_H4_prv1 && ind.adx_H4_prv1 < Division && ind.adx_H4_pDI > ind.adx_H4_mDI && Ask > ind.ma_H4_14)
					rtn = 0;
				else if (ind.adx_H4 > Division && ind.adx_H4_prv1+3*gl_basePoint < ind.adx_H4 && ind.adx_H4_prv2 < ind.adx_H4_prv1 && ind.adx_H4_prv1 < Division && ind.adx_H4_pDI < ind.adx_H4_mDI && Bid < ind.ma_H4_14)
					rtn = 1;
				break;
			case 22:
				if(ind.adx_W1 > Division && ind.adx_W1_prv1+3*gl_basePoint < ind.adx_W1 && ind.adx_W1_prv2 < ind.adx_W1_prv1 && ind.adx_W1_prv1 < Division && ind.adx_W1_pDI > ind.adx_W1_mDI && Ask > ind.ma_W1_14)
					rtn = 0;
				else if (ind.adx_W1 > Division && ind.adx_W1_prv1+3*gl_basePoint < ind.adx_W1 && ind.adx_W1_prv2 < ind.adx_W1_prv1 && ind.adx_W1_prv1 < Division && ind.adx_W1_pDI < ind.adx_W1_mDI && Bid < ind.ma_W1_14)
					rtn = 1;
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
				rtn = GetCMD4Patch();
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
