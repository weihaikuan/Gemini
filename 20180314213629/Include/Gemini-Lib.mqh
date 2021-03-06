double BasePoint = 0.0001; 
extern int Koffset = 3;

struct CPrice
{
    double Open;
    double Close;
    double High;
    double Low;
};

struct CBox
{
    bool IsUp;
    double High;
    double Low; 
    double Len;
};

int GetShape1(CPrice &p)
{
    int rtn = -1;
    if(p.High - p.Open < Koffset * BasePoint  && p.High - p.Close < (p.High - p.Low) / 3) 
        rtn = 1;
        //探顶：单根K线之上吊线。如一个人吊在了高处。在相对高的位置上出现，是行情可能见顶的信号之一。 
        //开盘价=最高价，并且（最高价-收盘价）小于（最高价-最低价）的三分之一
    else if(MathAbs(p.Open - p.Close) < Koffset * BasePoint) 
        rtn = 2; //十字线
    else if(p.Open > p.Close && p.High - p.Open > (p.Open - p.Close) * 2 || p.Open < p.Close && p.High - p.Close > (p.Close - p.Open) * 2) 
        rtn = 3;
        //探顶：单根K线之流星线。如天外流星自高空砸落，预示行情可能见顶。
        //开盘价大于收盘价，并且（最高价-开盘价）大于（开盘价-收盘价）的两倍。
    else if(p.Open > p.Close)
        rtn = 4;//阴线
    else if(p.Open < p.Close)
        rtn = 5;//阳线
    else if(p.High - p.Close < Koffset * BasePoint && p.High - p.Open < (p.High - p.Low) / 3)
        rtn = 11;
        //探底：单根K线之锤子线。如一把锤子，在凿穿市场的底部。 
        //收盘价=最高价，并且（最高价-开盘价）小于（最高价-最低价）的三分之一 
    
    return(rtn);
};
int GetShape2(CPrice &p1, CPrice &p2)
{
    int rtn = -1;
    if(GetShape1(p1) == 5 && GetShape1(p2) == 4 && p2.Open - p2.Close > (p1.Close - p1.Open) * 1.5)
        rtn = 1;
        //探顶：双根K线之看跌吞没。
        //第一根K线为阳线（收盘价大于开盘 价），第二根K线 为阴线，并且第二根K线的实体长度（开 盘价-收盘价）大于第一根K线实体长度（收盘价-开盘价）的1.5倍。
    else if(GetShape1(p1) == 5 && GetShape1(p2) == 4 && p2.Open >= p1.Close && p2.Close < (p1.High + p1.Low) / 2)
        rtn = 2;
        //探顶：双根K线之乌云盖顶。
        //第一 根K线为阳线，第二根K线为阴线且第二根K线的开盘价大于或等于第一根K线的收盘价，并且第二根K线的收盘价小于第一根K线的二分之一。
    else if(GetShape1(p1) == 2 && GetShape1(p2) == 2)
        rtn = 3;
        //探顶(或探底)：双根K线之双针。
        //第一根K线为十字线，第二根K线仍然为十字线。
    else if(GetShape1(p1) == 4 && GetShape1(p2) == 5 && p2.Close - p2.Open > (p1.Open - p1.Close) * 1.5)
        rtn = 11;
        //探底：双根K线之看涨吞没。
        //第一根K线为阴线（开盘价大于收盘 价），第二根K线 为阳线，并且第二根K线的实体长度（收 盘价-开盘价）大于第一根K线实体长度（开盘价-收盘价）的1.5倍。
    else if(GetShape1(p1) == 4 && GetShape1(p2) == 5 && p2.Open <= p1.Close && p2.Close > (p1.High + p1.Low) / 2)
        rtn = 12;
        //探底：双根K线之刺透形态（也称斩回形态）。
        //第一 根K线为阴线，第二根K线为阳线且第二根K线的开盘价小于或等于第一根K线的收盘价，并且第二根K线的收盘价大于第一根K线的二分之一。   
    
    return(rtn);
};

int GetShape3(CPrice &p1, CPrice &p2, CPrice &p3)
{
    int rtn = -1;
    if(GetShape1(p1) == 5 && (GetShape1(p2) == 2 || MathAbs(p2.Close - p2.Open) < (p1.High - p1.Low) / 3) && GetShape1(p3) == 4 && p3.Open - p3.Close > (p1.Close - p1.Open) * 2 / 3)
        rtn = 1;
        //探顶：三根K线之黄昏之星。
        //第一根K线为阳线 ，第二根K线 为十字线或 者第 二根K线的实体长度（开盘 价与收盘价之间的距离，可阳线也可阴线 ）小于第一根K线长度的三分之一，
        //第三根K线为阴线，并且第三根K线的实体长度（开盘价-收盘价）大于第一根K线实体长度（收盘价-开盘价）的三分之二
    else if(1==2)
        rtn = 2;
        //探顶：多根K线之平头顶部(此处还未找到判定方法)todo
    else if(GetShape1(p1) == 4 && (GetShape1(p2) == 2 || MathAbs(p2.Close - p2.Open) < (p1.High - p1.Low) / 3) && GetShape1(p3) == 5 && p3.Close - p3.Open > (p1.Open - p1.Close) * 2 / 3)
        rtn = 11;
        //探底：三根K线之启明之星。
        //第一根K线为阴线 ，第二根K线 为十字线或 者第 二根K线的实体长度（开盘 价与收盘价之间的距离，可阳线也可阴线 ）小于第一根K线长度的三分之一，
        //第三根K线为阳线，并且第三根K线的实体长度（收盘价-开盘价）大于第一根K线实体长度（开盘价-收盘价）的三分之二
    else if(1==2)
        rtn == 12;
        //探底：多根K线之平头底部(此处还未找到判定方法)todo
    return(rtn);
};

class CMarket
{
private:
    ENUM_TIMEFRAMES frame;
    int lastDay;
    CPrice prices[];
    int queueLength;
    int hasShizi[];//十字线 2
    int hasShangdiao_11[];//上吊线 1
    int hasLiuxing_11[];//流星线 3
    int hasChuizi_10[];//锤子线 11
    int hasKanDieTunMo_21[];//双根K线之看跌吞没 1
    int hasWuYunGaiDing_21[];//乌云盖顶 2
    int hasShuangZhen[];//双针 3
    int hasKanZhangTunMo_20[];//看涨吞没 11
    int hasCiTou_20[];//刺透形态 12
    int hasHuangHunZhiXing_31[];//黄昏之星 1
    int hasQiMingZhiXing_30[];//启明之星 11     
    double boxHigh;
    double boxLow;
    int boxLength;
    int boxPosition;
    int hasbox;
    int trend;
    
    void RefreshQueue(int from, int to)
    {       
        for(int m=from; m<=to; m++)
        {
            int k1,k2,k3, len;
            k1 = GetShape1(prices[m]);
            switch(k1)
            {
                case 1:
                    len = ArraySize(this.hasShangdiao_11);
                    ArrayResize(this.hasShangdiao_11, len + 1);
                    this.hasShangdiao_11[len] = m;
                    break;
                case 2:
                    len = ArraySize(this.hasShizi);
                    ArrayResize(this.hasShizi, len + 1);
                    this.hasShizi[len] = m;
                case 3:
                    len = ArraySize(this.hasLiuxing_11);
                    ArrayResize(this.hasLiuxing_11, len + 1);
                    this.hasLiuxing_11[len] = m;
                case 11:
                    len = ArraySize(this.hasChuizi_10);
                    ArrayResize(this.hasChuizi_10, len + 1);
                    this.hasChuizi_10[len] = m;
                  
            }    
            if(m <= to - 1)
            {
                k2 = GetShape2(prices[m], prices[m+1]);
                switch(k2)
                {
                    case 1:
                        len = ArraySize(this.hasKanDieTunMo_21);
                        ArrayResize(this.hasKanDieTunMo_21, len + 1);
                        this.hasKanDieTunMo_21[len] = m + 1;
                        break;
                    case 2:
                        len = ArraySize(this.hasWuYunGaiDing_21);
                        ArrayResize(this.hasWuYunGaiDing_21, len + 1);
                        this.hasWuYunGaiDing_21[len] = m + 1;
                        break;
                    case 3:
                        len = ArraySize(this.hasShuangZhen);
                        ArrayResize(this.hasShuangZhen, len + 1);
                        this.hasShuangZhen[len] = m + 1;
                        break;
                    case 11:
                        len = ArraySize(this.hasKanZhangTunMo_20);
                        ArrayResize(this.hasKanZhangTunMo_20, len + 1);
                        this.hasKanZhangTunMo_20[len] = m + 1;
                        break;
                    case 12:
                        len = ArraySize(this.hasCiTou_20);
                        ArrayResize(this.hasCiTou_20, len + 1);
                        this.hasCiTou_20[len] = m + 1;
                        break;
                }
            }
            if(m <= to - 2)
            {
                k3 = GetShape3(prices[m], prices[m+1], prices[m+2]);
                switch(k3)
                {
                    case 1:
                        len = ArraySize(this.hasHuangHunZhiXing_31);
                        ArrayResize(this.hasHuangHunZhiXing_31, len + 1);
                        this.hasHuangHunZhiXing_31[len] = m + 2;
                        break;
                    case 11:
                        len = ArraySize(this.hasQiMingZhiXing_30);
                        ArrayResize(this.hasQiMingZhiXing_30, len + 1);
                        this.hasQiMingZhiXing_30[len] = m + 2;
                        break;
                }
            }  
            
            
        }       
        
    };    
    
    void RefreshKbox()
    {
        int lenPrice = ArraySize(prices);
        if(lenPrice < 4) return;
        
        double kbox[][2];// 盘整box；
        int size = ArraySize(kbox);
        int i = lenPrice - 1;        
        while(true)
        {
            double high0 = prices[i].High;  
            double low0 = prices[i].Low;
            
            if(size == 0)
            {
                ArrayResize(kbox, 1);
                kbox[0][0] = high0;
                kbox[0][1] = low0;
                size++;
            }
            else
            {        
                double high1 = kbox[0][0];
                double low1 = kbox[0][1];
                
                double high = high0 > high1? high0:high1;
                double low = low0 < low1? low0:low1;
                if(high - low < 100 * BasePoint)
                {
                    ArrayResize(kbox, size + 1);
                    kbox[size][0] = high0;
                    kbox[size][1] = low0;
                    
                    size++;
                }
                else if(size<4)
                {
                    ArrayFree(kbox);
                    ArrayResize(kbox,0);
                    break;
                }
                else
                {   hasbox = 1;                 
                    this.boxHigh = high;
                    this.boxLow = low;
                    this.boxLength = size;
                    this.boxPosition = lenPrice - 1;
                    break;
                }         
                
            }   
            i--;
            if(i<0) break;
        }      
    };
    
    void AppendNewK()
    {
        bool hasNew = false;
        if(frame == PERIOD_D1)
        {
            int today = TimeDay(TimeCurrent());
            if(today != lastDay)
            {
                hasNew = true;                
                lastDay = today;
            }            
        }
        else if(frame == PERIOD_W1)
        {
        }
        
        if(hasNew)
        {
            ArrayResize(prices, queueLength + 1);
            prices[queueLength].Open = iOpen(NULL, frame, 1);
            prices[queueLength].Close = iClose(NULL, frame, 1);
            prices[queueLength].Low = iLow(NULL, frame, 1);
            prices[queueLength].High = iHigh(NULL, frame, 1);
            
            double maFast1 = iMA(NULL, frame, 10, 0, MODE_SMA, PRICE_CLOSE, 2);
            double maFast = iMA(NULL, frame, 10, 0, MODE_SMA, PRICE_CLOSE, 1);
            double maSlow1 = iMA(NULL, frame, 20, 0, MODE_SMA, PRICE_CLOSE, 2);
            double maSlow = iMA(NULL, frame, 20, 0, MODE_SMA, PRICE_CLOSE, 1);
            
            if(maFast > maSlow && maFast1 <= maSlow1)
                this.trend = 0;
            else if(maFast < maSlow && maFast1 >= maSlow1)
                this.trend = 1;
                
            RefreshQueue(queueLength - 2, queueLength);
            RefreshKbox();
            queueLength++;
            
            
        }
    };
    
    int GetKline(int &arr[], string kname = "")
    {
        int rtn = -1;
        if(ArraySize(arr) > 0)
        {
            rtn = this.queueLength - arr[ArraySize(arr) - 1];
            Print(kname, "=", rtn);
        }
        
        return(rtn);
    };
    
public:
    CMarket(ENUM_TIMEFRAMES kframe, int n)
    {
        if(n < 10) n = 10;
        trend = -1;
        
        frame = kframe;
        lastDay = TimeDay(TimeCurrent());
        ArrayResize(prices, n);
        double maFast1, maFast;
        double maSlow1, maSlow;
        for(int i = n - 1; i >= 0; i--)
        {
            prices[i].Open = iOpen(NULL, frame, i+1);
            prices[i].Close = iClose(NULL, frame, i+1);
            prices[i].Low = iLow(NULL, frame, i+1);
            prices[i].High = iHigh(NULL, frame, i+1);
            
            maFast1 = iMA(NULL, kframe, 10, 0, MODE_SMA, PRICE_CLOSE, i+2);
            maFast = iMA(NULL, kframe, 10, 0, MODE_SMA, PRICE_CLOSE, i+1);
            maSlow1 = iMA(NULL, kframe, 20, 0, MODE_SMA, PRICE_CLOSE, i+2);
            maSlow = iMA(NULL, kframe, 20, 0, MODE_SMA, PRICE_CLOSE, i+1);
            
            if(maFast > maSlow && maFast1 <= maSlow1)
                this.trend = 0;
            else if(maFast < maSlow && maFast1 >= maSlow1)
                this.trend = 1;
            
            //Print("price",i,"=", prices[i].Close);
        }  
        
        if(this.trend == -1)
        {
            if(iMA(NULL, kframe, 10, 0, MODE_SMA, PRICE_CLOSE, 0) >= iMA(NULL, kframe, 20, 0, MODE_SMA, PRICE_CLOSE, 0))
                trend = 0;
            else
                trend = 1;
        }
        
        queueLength = n;
        RefreshQueue(0, queueLength - 1);
        RefreshKbox();
    
    };
    
    /*
    uping, downing
    
    */
    int GetTradeSign()
    {
        AppendNewK();
        
        int rtn = -1;
        int k;
        if(this.hasbox && this.boxPosition == this.queueLength - 1)
        {
            Print("hasbox=", this.queueLength - this.boxPosition, ", Len=", this.boxLength, ",high=",this.boxHigh, ",low=", this.boxLow);
        }
        else 
        {
            k = GetKline(this.hasHuangHunZhiXing_31, "HuangHunZhiXing");
            if(k == 0 && this.trend == 0)
            {
            }
            else
            {
                k = GetKline(this.hasQiMingZhiXing_30, "QiMingZhiXing");
                if(k == 0 && this.trend == 1)
                {
                }
                else
                {
                    k = GetKline(this.hasCiTou_20, "CiTou");
                    if(k == 0 && this.trend == 1)
                    {
                    }
                    else
                    {
                    }
                }
            }        
        }
        
        return(rtn);
    };         
};