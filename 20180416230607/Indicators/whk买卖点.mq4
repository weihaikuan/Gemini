#property copyright "palanka"
#property link      ""
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
//----
int ParmMult=2; // multiply the standard parameters by this scale factor

double signal_sell[];
double signal_buy[];

int init()
  {
   SetIndexBuffer(0,signal_sell);
   SetIndexBuffer(1,signal_buy);
   IndicatorShortName("Fx10Setup");
   SetIndexEmptyValue(0, 0.0) ;
   SetIndexEmptyValue(1, 0.0) ;
   //
   SetIndexStyle(0,DRAW_ARROW,0,1);
   SetIndexArrow(0,234);
   SetIndexStyle(1,DRAW_ARROW,0,1);
   SetIndexArrow(1,233);
   //
   IndicatorDigits(1);

   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
{

	int counted_bars = IndicatorCounted();
	if(counted_bars < 0)  return(-1);
	if(counted_bars > 0)   counted_bars--;
	int shift = Bars - counted_bars;
	if(counted_bars==0) shift-=1+26*ParmMult;
	
	int total = shift;
	
	while(shift>=0)
	{
		signal_sell[shift]=0.0;
		signal_buy[shift]=0.0;
		//----
		
		F5(shift, total);
			
		shift--;
	}
	//----
	return(0);
}
//+------------------------------------------------------------------+

void F1(int shift, int total)
{
//----
	double fastMA=iMA(NULL, 0, 5 * ParmMult, 0, MODE_LWMA, PRICE_CLOSE, shift);
	double slowMA=iMA(NULL, 0, 10 * ParmMult, 0, MODE_SMA, PRICE_CLOSE, shift);
	//----
	if (fastMA > slowMA)
	{
		bool RsiUp=iRSI(NULL, 0, 14 * ParmMult, PRICE_CLOSE, shift)>=55.0;
		//and iRSI(p1, 1) > iRSI(p1, 2)
		double Stoch0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_MAIN, shift);
		double Stoch1 = iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_MAIN, shift + 1);
		double StochSig0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_SIGNAL, shift);
		bool StochUp=(Stoch0 > StochSig0);// && Stoch0 > Stoch1);	//and Stoch0 >= StochHigh
		double MacdCurrent=iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_MAIN, shift);
		double MacdPrevious = iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_MAIN, shift + 1);
		double MacdSig0=iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_SIGNAL, shift);
		bool MacdUp=(MacdCurrent > MacdSig0);// && MacdCurrent > MacdPrevious && MacdCurrent > 50);
		if (StochUp && RsiUp && MacdUp)
			signal_sell[shift]=High[shift] + 0.3/MathPow(10.0, Digits - 1);
	}
	else if (fastMA < slowMA)
	{
		bool RsiDown=iRSI(NULL, 0, 14 * ParmMult, PRICE_CLOSE, shift)<=45.0;
		//and iRSI(p1, 2) > iRSI(p1, 1)
		Stoch0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_MAIN, shift);
		// double Stoch1 = iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, PRICE_CLOSE, MODE_MAIN, shift + 1);
		StochSig0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_SIGNAL, shift);
		bool StochDown=(Stoch0 < StochSig0);
		//and Stoch0 < Stoch1
		//and Stoch0 <= StochLow
		MacdCurrent=iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_MAIN, shift);
		// double MacdPrevious = iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_MAIN, shift + 1);
		MacdSig0=iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_SIGNAL, shift);
		bool MacdDown=(MacdCurrent < MacdSig0);
		//and  MacdCurrent < MacdPrevious
		//and MacdCurrent < 50
		if (StochDown && RsiDown && MacdDown)
			signal_buy[shift]=Low[shift] - 0.3/MathPow(10.0, Digits - 1);
	}
}


void F2(int shift, int total)
{
		double fastMA=iMA(NULL, 0, 5 * ParmMult, 0, MODE_LWMA, PRICE_CLOSE, shift);
		double slowMA=iMA(NULL, 0, 10 * ParmMult, 0, MODE_SMA, PRICE_CLOSE, shift);
		
		double Stoch0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_MAIN, shift);
		double StochSig0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_SIGNAL, shift);
		
		double bandup = iBands(NULL, 0, 18, 2, 0, PRICE_CLOSE, MODE_UPPER, shift); 
		double bandmiddle = iBands(NULL, 0, 18, 2, 0, PRICE_CLOSE, MODE_MAIN, shift);
		double bandlow = iBands(NULL, 0, 18, 2, 0, PRICE_CLOSE, MODE_LOWER, shift);	
		double high = iHigh(NULL, 0, shift);
		double low = iLow(NULL,0,shift);
		
		double Rsi = iRSI(NULL, 0, 14 * ParmMult, PRICE_CLOSE, shift);
		double wpr = iWPR(NULL, 0, 28*ParmMult, shift); 
		
		if (fastMA > slowMA && Stoch0 < StochSig0 && wpr > -10 )
		{
		    signal_sell[shift]=High[shift] + 0.3/MathPow(10.0, Digits - 1);
		}
		else if (fastMA < slowMA && Stoch0 > StochSig0 && wpr <-90)
		{
		    
		    signal_buy[shift]=Low[shift] + 0.3/MathPow(10.0, Digits - 1);
		} 
}

void F3(int shift, int total)
{
		double adx = iADX(NULL,0,14,PRICE_CLOSE,MODE_MAIN,shift);
		double division = 25;
		double wpr = iWPR(NULL, 0, 14, shift);
		
		if(adx < division && wpr < -90)    	
    	{     	    
    	    signal_buy[shift]=Low[shift] + 0.3/MathPow(10.0, Digits - 1);
    	}
    	else if (adx < division && wpr > -10)
    	{     	    
    	    signal_sell[shift]=High[shift] + 0.3/MathPow(10.0, Digits - 1);
    	}
	
}

void F4(int shift, int total)
{
//----
	double fastMA=iMA(NULL, 0, 5 * ParmMult, 0, MODE_LWMA, PRICE_CLOSE, shift);
	double slowMA=iMA(NULL, 0, 10 * ParmMult, 0, MODE_SMA, PRICE_CLOSE, shift);
	//----
	if (fastMA > slowMA)
	{
		bool RsiUp=iRSI(NULL, 0, 14 * ParmMult, PRICE_CLOSE, shift)>=55.0;
		//and iRSI(p1, 1) > iRSI(p1, 2)
		double Stoch0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_MAIN, shift);
		// double Stoch1 = iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, PRICE_CLOSE, MODE_MAIN, shift + 1);
		double StochSig0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_SIGNAL, shift);
		bool StochUp=(Stoch0 > StochSig0);
		//and Stoch0 > Stoch1
		//and Stoch0 >= StochHigh
		double MacdCurrent=iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_MAIN, shift);
		// double MacdPrevious = iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_MAIN, shift + 1);
		double MacdSig0=iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_SIGNAL, shift);
		bool MacdUp=(MacdCurrent > MacdSig0);
		//and  MacdCurrent > MacdPrevious
		//and MacdCurrent > 50
		if (StochUp && RsiUp && MacdUp)
			signal_sell[shift]=High[shift] + 0.3/MathPow(10.0, Digits - 1);
	}
	else if (fastMA < slowMA)
	{
		bool RsiDown=iRSI(NULL, 0, 14 * ParmMult, PRICE_CLOSE, shift)<=45.0;
		//and iRSI(p1, 2) > iRSI(p1, 1)
		Stoch0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_MAIN, shift);
		// double Stoch1 = iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, PRICE_CLOSE, MODE_MAIN, shift + 1);
		StochSig0=iStochastic(NULL, 0, 5*ParmMult, 3*ParmMult, 3*ParmMult, MODE_SMA, 1, MODE_SIGNAL, shift);
		bool StochDown=(Stoch0 < StochSig0);
		//and Stoch0 < Stoch1
		//and Stoch0 <= StochLow
		MacdCurrent=iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_MAIN, shift);
		// double MacdPrevious = iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_MAIN, shift + 1);
		MacdSig0=iMACD(NULL, 0, 12*ParmMult, 26*ParmMult, 9*ParmMult, PRICE_CLOSE, MODE_SIGNAL, shift);
		bool MacdDown=(MacdCurrent < MacdSig0);
		//and  MacdCurrent < MacdPrevious
		//and MacdCurrent < 50
		if (StochDown && RsiDown && MacdDown)
			signal_buy[shift]=Low[shift] - 0.3/MathPow(10.0, Digits - 1);
	}
}

void F5(int shift, int total)
{
		double ma2=iMA(NULL, 0, 2, 0, MODE_LWMA, PRICE_CLOSE, shift);
	    double ma5=iMA(NULL, 0, 5, 0, MODE_LWMA, PRICE_CLOSE, shift);
		double ma10=iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, shift);
		double wpr = iWPR(NULL, 0, 14, shift);
	
		if (ma2<ma5 && ma5>ma10 && wpr>-30)
			signal_sell[shift]=High[shift] + 0.3/MathPow(10.0, Digits - 1);
		if (ma2>ma5 && ma5<ma10 && wpr<-70)
			signal_buy[shift]=Low[shift] + 0.3/MathPow(10.0, Digits - 1);
	
}