//+------------------------------------------------------------------+
//|                                                    UpFractal.mq4 |
//|                                                 Eng. Ahmad Lutfi |
//|                                         https://www.lutfipro.com |
//+------------------------------------------------------------------+
#property copyright "Eng. Ahmad Lutfi"
#property link      "https://www.lutfipro.com"
#property version   "1.00"
#property strict

extern double TakeProfit = 30;
extern double StopLoss = 10;
extern double LotSize = 0.01;
extern int    Slippage = 10;
int PipAdjust =1;

int buyticket = 0;
int sellticket =0;

double resistanceLine=0.0;
double supportLine = 0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int AdjustPips()
{
   int pt = 1;
   if(Digits==5 || Digits==3)
   {
      pt *=10;
   }
   return pt;
}
void InitVals()
{
  PipAdjust = AdjustPips();
  TakeProfit *= PipAdjust;
  StopLoss *= PipAdjust;
  Slippage *= PipAdjust;
}
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(IsNewCandle())
   {
      int Candle = 1;
      //check last candle  was  an  Upper Fractal
      if(FractalDown(Candle))
      {
       //draw Support line
       
       // supportLine = getLoPart(1);
        supportLine = Low[Candle];
        supportLine = NormalizeDouble(supportLine,Digits);
         //TODO: set a pending Sell Order...
         if(supportLine<Ask && supportLine<Bid)
         {
            //set a pending Sell Order!
            setPendingSell(supportLine);
         }
      }
    
      if(FractalUP(Candle))
      {
       //draw resistance line
       //resistanceLine = getHiPart(); the easy Way!!
       
       resistanceLine = High[Candle];
       
       resistanceLine = NormalizeDouble(resistanceLine,Digits);

          //TODO: set a pending BUY Order...
          if(resistanceLine> Ask && resistanceLine > Bid)
          {
                  //Set a Pending Buy!
                  setPendingBuy(resistanceLine);
          }
     
      }
      
   
   }
  }
  //---
  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  
  bool FractalUP(int Lookback=1)
  {
   bool IsUpFractal = EMPTY_VALUE;
    //  if(Lookback!=0)
  // {

         int Candle0 = Lookback-1;
         int Candle1 = Lookback;
         int Candle2 = Lookback + 1;
         int Candle3 = Lookback + 2;
         
        if( (getHiPart(Candle1)>getHiPart(Candle2) &&   getHiPart(Candle2)>getHiPart(Candle3) ) 
          &&  ( Open[Candle0] < getHiPart(Candle1 ) ) )
        {
               IsUpFractal = true;
        }
        //TODO: Place the Downfractal here and set upFlag to false;
           if ( ((getLoPart(Candle1)<getLoPart(Candle2)) && (getLoPart(Candle2)<getLoPart(Candle3)) )
            && (Open[Candle0]> getLoPart(Candle1))
            )
         {
            IsUpFractal = false;
         }
  //  }
  return IsUpFractal;
  }
  
  bool FractalDown(int Lookback =1)
  {
     bool IsDownFractal = EMPTY_VALUE;
  // if(Lookback!=0)
  // {

         int Candle0 = Lookback-1;
         int Candle1 = Lookback;
         int Candle2 = Lookback + 1;
         int Candle3 = Lookback + 2;
         
         if ( ((getLoPart(Candle1)<getLoPart(Candle2)) && (getLoPart(Candle2)<getLoPart(Candle3)) )
            && (Open[Candle0]> getLoPart(Candle1))
            )
         {
            IsDownFractal = true;
         }
            
         if( (getHiPart(Candle1)>getHiPart(Candle2) &&   getHiPart(Candle2)>getHiPart(Candle3) ) 
          &&  ( Open[Candle0] < getHiPart(Candle1 ) ) )
        {
               IsDownFractal = false;
        }
  // }
         return IsDownFractal;
  }
  
  bool IsBullCandle(int lookback=1)
{
   bool f = false;
   if(Open[lookback]<Close[lookback])
   {
      f = true;
   }
   return f;
}

bool IsBearCandle(int lookback=1)
{
   bool f = false;
   if(Open[lookback] > Close[lookback])
   {
      f= true;
   }
   return f;
}
//+------------------------------------------------------------------+
    double getHiPart(int Candle=1)
  {
  
      double HiPart = 0;
      if(IsBullCandle(Candle))
      {
         //the below part is Open[Candle1]
         
       HiPart =   Close[Candle];    
      }
      if(IsBearCandle(Candle))
      {
       HiPart = Open[Candle];
      }
      return NormalizeDouble(HiPart,Digits);
  }
 
 double getLoPart(int Candle=1)
 {
   double LoPart = 0;
   if(IsBullCandle(Candle))
   {
      LoPart = Open[Candle];               
   }
   if(IsBearCandle(Candle))
   {
      LoPart = Close[Candle]; 
   }
   
   return NormalizeDouble(LoPart,Digits);
 }
  
  void OrderEntry(int direction)
{
   if(direction==0)
   {
      double tp=Ask+TakeProfit*Point;
      double sl=Ask-StopLoss*Point;
      if(OpenOrdersThisPair(Symbol())==0)
      int buyticket = OrderSend(Symbol(),OP_BUY,LotSize,Ask,3,0,0,NULL,/*MagicNumber*/0,0,Green);
      if(buyticket>0)OrderModify(buyticket,OrderOpenPrice(),sl,tp,0,CLR_NONE);
   }
   
   if(direction==1)
   {
     double tp=Bid-TakeProfit*Point;
     double sl=Bid+StopLoss*Point;
      if(OpenOrdersThisPair(Symbol())==0)
      int sellticket = OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,0,0,NULL,0/*MagicNumber*/,0,Red);
      if(sellticket>0)OrderModify(sellticket,OrderOpenPrice(),sl,tp,0,CLR_NONE);
   }

}

//+------------------------------------------------------------------+
//checks to see if any orders open on this currency pair.
//+------------------------------------------------------------------+
int OpenOrdersThisPair(string pair)
{
  int total=0;
   for(int i=OrdersTotal()-1; i >= 0; i--)
	  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()== pair) total++;
	  }
	  return (total);
}

//+------------------------------------------------------------------+
//insuring its a new candle function
//+------------------------------------------------------------------+
bool IsNewCandle()
{
   static int BarsOnChart=0;
	if (Bars == BarsOnChart)
	return (false);
	BarsOnChart = Bars;
	return(true);
}

//+------------------------------------------------------------------+

int setPendingBuy(double Price)
{
  // int slippage = Slippage * PipAdjust; 
   
   double stop_loss = Price - (StopLoss * Point); //* PipAdjust;
   double take_profit = Price +( TakeProfit * Point);// * PipAdjust; 
   int result =0;
   if(Ask > Price)
   {
   result = OrderSend(Symbol(),OP_BUYLIMIT,LotSize,Price,Slippage,stop_loss,take_profit,"ACandles_Long",0,0,CLR_NONE);
   }
   if(Ask < Price)
   {
   result = OrderSend(Symbol(),OP_BUYSTOP,LotSize,Price,Slippage,stop_loss,take_profit,"ACandles_Long",0,0,CLR_NONE);
   }
   return result;
}

int setPendingSell(double Price)
{
   double stop_loss = Price + (StopLoss * Point); //* PipAdjust;
   double take_profit = Price -( TakeProfit * Point);// * PipAdjust;
    
   int result =0;
   
      if(Bid > Price)
   {
   result = OrderSend(Symbol(),OP_SELLSTOP,LotSize,Price,Slippage,stop_loss,take_profit,"ACandles_Short",0,0,CLR_NONE);
   }
   if(Bid < Price)
   {
   result = OrderSend(Symbol(),OP_SELLLIMIT,LotSize,Price,Slippage,stop_loss,take_profit,"ACandles_Short",0,0,CLR_NONE);
   }
   return result;
}