//+------------------------------------------------------------------+
//|                                                          wpr.mq4 |
//|                                                 Eng. Ahmad Lutfi |
//|                                         https://www.lutfipro.com |
//+------------------------------------------------------------------+
#property copyright "Eng. Ahmad Lutfi"
#property link      "https://www.lutfipro.com"
#property version   "1.00"
#property strict

extern double lots=1.0;
int Slippage=10;
bool IsTrading;
int ticket = -1, BuyCount,SellCount;
 
 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
  string BoolToStr(bool bval)   {
//+------------------------------------------------------------------+
// Converts the boolean value true or false to the string "true" or "false" 
  if (bval)   return("true");
  return("false");
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
static double y1 = 0;
static double m1 = 0;
static double y2 = 0;
static double m2 = 0;

   if(IsNewCandle())
   {
   //do everything here!
   //1.test wpr values now and before!
    double X = iWPR(Symbol(),PERIOD_CURRENT,14,2);
    
    double Xfin = iWPR(Symbol(),PERIOD_CURRENT,14,1);
   
      if(OrdersTotal()==0)
      {
         //check if open buy was hit
         if(CheckOpenBuy())
         {
            
         }
         
         //check if open sell
         if(CheckOpenSell())
         {
            //open sell order!
         }
      }
      if(OrdersTotal>0 && OrdersTotal<=1) //if there's already an open Order
      {
        if( OrderSelect(0,SELECT_BY_POS,MODE_TRADES))
        {
        
        //TODO:check for a trend change Here..
        
        
            if(OrderType()==OP_BUY)
            {
                //check if open sell to close Buys!
               if(CheckOpenSell())
               {
                  //open sell order!
               }
            }
            
            if(OrderType()==OP_SELL)
            {
                  //check if open buy to close Sells!
               if(CheckOpenBuy())
               {
                  
               }
            }
        
        }
         
      }
   }
  }
//+------------------------------------------------------------------+
void handleOpenOrder()
{
  bool Isbuy = EMPTY_VALUE;
  
    if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES))
    {
      if(OrderType == OP_BUY)
      {
      //check
      
      }
      
      if(OrderType ==OP_SELL)
      {
      
      }
      
    }
  
  
}

bool CheckOpenBuy()
{
      bool flag = false;
      if((X > -100 && X<-80) && 
         ( Xfin >-80))//Xfin > -50 &&
         {
         flag = true;
         }
         return flag;
}

bool CheckOpenSell()
{
   bool flag = false;
      if((X > -20 && X<0) && 
         ( Xfin <-20))//Xfin > -50 &&
         {
            flag = true;
         }
         return flag;
}

bool IsNewCandle()
{
   static int BarsOnChart=0;
	if (Bars == BarsOnChart)
	return (false);
	BarsOnChart = Bars;
	return(true);
}

//+------------------------------------------------------------------+
//Trend Functions:
double Calc_m(double y2, double y1)
{

double m =  (y2-y1)*(-1);

return m;
}


double Calc_Theta(double m1, double m2)
{

   double Th1 = atan(m1);
   
   double Th2 = atan(m2);

   double Th = MathAbs(Th1 - Th2);
   return Th;
   
}


void TrendBuyClose()
{
   //1.select Order
       if(response) //Order is Selected!
         {
            if(y2 != iWPR(Symbol(),PERIOD_CURRENT,14,1)) //check iwpr point has changed!            {
         y1 = y2;
         y2= iWPR(Symbol(),PERIOD_CURRENT,14,1);
         m2 = Calc_m(y2,y1);
         
         //Compute  'n' Evaluate...
         //-----------------------
         double resultat = m1 * m2;
         Print("m1= "+ DoubleToStr( m1,2) +"  m2= "+DoubleToStr(m2,2) + "  &Resultant is: "+DoubleToStr(resultat,2));
            if(resultat <0)
            {

}