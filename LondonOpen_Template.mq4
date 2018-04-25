//+------------------------------------------------------------------+
//|                                                  LondonOpen1.mq4 |
//|                                                 Eng. Ahmad Lutfi |
//|                                         https://www.lutfipro.com |
//+------------------------------------------------------------------+
#property copyright "Eng. Ahmad Lutfi"
#property link      "https://www.lutfipro.com"
#property version   "1.00"
#property strict

   extern double Lots=0.01;
   extern double StopLoss=50;
   extern double TakeProfit=100;
   double pips=1;
bool tickplease = false;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int HrDiff = 0;
int MnDiff = 0;
int Offset = 0;
string orientation ="";
int BollingerPeriod = 20;
int BollingerDeviation = 2;

int Slippage = 5;

int pendingbuyticket =0;
int pendingsellticket =0;
//---
int WhentoMoveToBE = 30;

int PipsToLockIn = 30;


int WhenToTrail = 30;

int TrailAmount = 30;
//---

bool BuyFlag = false;
bool SellFlag  = false;
int Sellticket = 0; int Buyticket = 0; bool IsBuying = false; bool IsSelling=false;
int pendingBuys = 0; int pendingSells =0;int lastOpenTime = 0;  
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
datetime Svr2Gmt(datetime svrtime)
{
datetime GMT =0;
   if(orientation=="E")//svr> GMT
   {
      GMT = svrtime - /*((HrDiff*3600)+ (MnDiff))*/Offset*3600;
        
   }
   else              //svr < GMT
   {
       GMT = svrtime + Offset*3600;
   
   }
  return GMT;
}

datetime Gmt2Svr(datetime GMT)
{
datetime svrtime = 0;

    if(orientation=="E")//GMT < svr
   {
   svrtime = GMT + Offset*3600;
   
   }
   else
   {
   
    svrtime = GMT - Offset*3600;
   }
  return svrtime;
}

void initSvrOffest()
{
 AdjustServerOffset();
 AdjustServerOrientation();
}
void AdjustServerOffset()
{
   //get Offset
  HrDiff =  MathAbs( TimeHour(TimeGMT()) -TimeHour( TimeCurrent()) );
  MnDiff = MathAbs( TimeMinute(TimeGMT()) -TimeMinute( TimeCurrent()));
  Offset = HrDiff + (MnDiff/60);
}
void AdjustServerOrientation()
{
  //get Orientation
    if(TimeGMT()< TimeCurrent())
  {
         orientation = "E";
  
  }
  
  else if(TimeGMT()> TimeCurrent())
  {
       orientation = "W";  
  
  }
  else if(TimeGMT()== TimeCurrent())
  {
    orientation ="N";
  }
}
int OnInit()
  {
//---
   initSvrOffest();
   
 int  p = AdjustPips();
  WhentoMoveToBE *= p;

 PipsToLockIn *= p;


 WhenToTrail *= p;

 TrailAmount *= p;
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
  static  int hr=0; hr=  TimeHour(TimeGMT());
//---
if(!tickplease)
{
if(IsNewCandle())//&&!tickplease)
{
     printf("New Candle! WOW!");
    //  hr=  TimeHour(TimeGMT());//(Svr2Gmt(TimeCurrent()));

   if(hr==8)
    {
     //strategy rules here
     //checkStrategy Rules
     printf("8 AM.."+" Check for rules!");
     CheckForBollingerBandTrade(15);
    
    }
  
      if(hr==20) //closing orders time for this day!
      {
        
          printf(DayOfWeek()+"Closing Time 20!");
       //  closeAllPendingOrders();
          deletePendingBuys();
          deletePendingSells();
         closeAllOpenOrders();
         
         if(BuyFlag)
         {
       //  printf("Current buying");//reset Buy variables!
         
                   Buyticket=0; //reset the Buyticket!
               BuyFlag = false; //reset this BuyFlag!
               SellFlag = false;
         }
         if(SellFlag) //reset Sell variables!
         {
            Sellticket=0;
               BuyFlag = false; //reset this BuyFlag!
               SellFlag = false;
         }

               
      }

   }
}
else if(tickplease)
   {
 
      CheckPendingOrders();//TODO: ...
      if(BuyFlag==true || SellFlag==true)
      {
       tickplease = false;
      // break;
      //  lastOpenTime=0;
      }
       
   if( hr==20) //closing orders time for this day!
      {
        //  SelectnClose();
      printf(DayOfWeek()+"Closing Time 20!");
         //closeAllPendingOrders();
         closeAllOpenOrders();
         
         tickplease=false;
         Sellticket =0;Buyticket=0;
          BuyFlag = false; SellFlag = false;
          deletePendingBuys();
          deletePendingSells();
          
          ////
          if(BuyFlag)
         {
      
               Buyticket=0; //reset the Buyticket!
               BuyFlag = false; //reset this BuyFlag!
               SellFlag = false;
         }
         if(SellFlag) //reset Sell variables!
         {
               Sellticket=0;
               BuyFlag = false; //reset this BuyFlag!
               SellFlag = false;
         }
          
          
          ///
          
          
      }
   }

  }
  
  //
 /* void SelectnClose()
{
         if(BuyFlag==true || SellFlag==true)
         {
             
          if(BuyFlag==true) //buy was hit
          {
            if(OrderSelect(Buyticket,SELECT_BY_TICKET,MODE_TRADES))         
            { 
  
             if(OrderClose( Buyticket,OrderLots(),OrderOpenPrice(),Slippage))
              {
               //Buy period is finished!
               Buyticket=0; //reset the Buyticket!
               BuyFlag = false; //reset this BuyFlag!
               SellFlag = false;
               
               //Update total profit..
              }
            }
          }
           else if(SellFlag==true)// if we are selling
           
          {
            //make sure to close pending buy orders
           if(OrderSelect(Sellticket,SELECT_BY_TICKET,MODE_TRADES))
           {
              if(OrderClose( Sellticket,OrderLots(),OrderOpenPrice(),Slippage))
              {
                //Sell period is finished!
                Sellticket = 0; //reset the Sellticket!
               BuyFlag = false;
               SellFlag = false;
               
               //Update total profit..
               
               //do statistics clean-up
               
               
              } 
              
            }      
          }
          
         }
}
*/
//+------------------------------------------------------------------+
void SetPendingOrders(double Upband,double Dnband)
{
	    //setup a  new Trade for the day!
	  HandleReturnedOrder(PendingBuyOrder(Upband));
	  HandleReturnedOrder( PendingSellOrder(Dnband));
	  tickplease = true;
}

void CheckForBollingerBandTrade(int TimeFrame=60)
{
//   double Macd_Value=iMACD(NULL,0,Fast_Macd_Ema,Slow_Macd_Ema,1,PRICE_CLOSE,MODE_MAIN,1);
 //  double threshold=Macd_Threshold*pips;
   double MiddleBB=iBands(NULL,TimeFrame,BollingerPeriod,BollingerDeviation,0,0,MODE_MAIN,1);
   double LowerBB=iBands(NULL,TimeFrame,BollingerPeriod,BollingerDeviation,0,0,MODE_LOWER,1);
	double UpperBB=iBands(NULL,TimeFrame,BollingerPeriod,BollingerDeviation,0,0,MODE_UPPER,1);
	
	//double dist1 = MathAbs(MiddleBB - LowerBB);
	//double dist2 = MathAbs(MiddleBB - UpperBB);
	  if(BandsAreNarrow(UpperBB,MiddleBB,LowerBB))
	  {
	    //setup a  new Trade for the day!
	  SetPendingOrders(UpperBB,LowerBB);
	 // HandleReturnedOrder(PendingBuyOrder(UpperBB));
	//  HandleReturnedOrder( PendingSellOrder(LowerBB));
	 // tickplease = true;
	  }
	
	
 
}
bool BandsAreNarrow(double UpperBB,double MiddleBB, double LowerBB, int initDistance=15)
{
 bool AreNarrow= false;
	double dist1 = MathAbs(MiddleBB - LowerBB);
	double dist2 = MathAbs(MiddleBB - UpperBB);
  if(dist1 <=initDistance*pips*AdjustPips() && dist2 <=initDistance*pips*AdjustPips())
  {
  AreNarrow= true;
  
  }
  return AreNarrow;
}

//+------------------------------------------------------------------------------

void OrderEntry(int direction)
{
int buyticket=0;int sellticket=0;
bool res = false;
   if(direction==0)
   {
      double tp=Ask+TakeProfit*pips;
      double sl=Ask-StopLoss*pips;
      if(OpenOrdersThisPair(Symbol())==0)
       buyticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,NULL,0,0,Green);
      if(buyticket>0)res= OrderModify(buyticket,OrderOpenPrice(),sl,tp,0,CLR_NONE);
   }
   
   if(direction==1)
   {
     double tp=Bid-TakeProfit*pips;
     double sl=Bid+StopLoss*pips;
      if(OpenOrdersThisPair(Symbol())==0)
       sellticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,NULL,0,0,Red);
      if(sellticket>0)res= OrderModify(sellticket,OrderOpenPrice(),sl,tp,0,CLR_NONE);
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
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
      if(OrderSymbol()== pair) 
      {total++;}
      }
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

int AdjustPips()
{ int num = 1;

      double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
   	if (ticksize == 0.00001 || ticksize == 0.001)
	   num = 1*10;
	   else num =1;
	   
	   return num;
}


int PendingBuyOrder( double price,int TpAsPips=100,int SlAsPips = 50) //Buy at the specified Point!
{
   double Price = price; double  takeprofit=0.0;  double   stoploss=0.0;
   
  //Adjust pips
   int PipAdjust = AdjustPips();
   //Adjust slippage tp and sl
   int slippage = Slippage* PipAdjust;
   
  
  // double take_profit 
  if(TpAsPips >0)
  {
      takeprofit = Price + TpAsPips * Point * PipAdjust; 
         takeprofit = NormalizeDouble(takeprofit,Digits);
  }
  else if(TpAsPips==0)
  {
        takeprofit = 0;
        takeprofit = NormalizeDouble(takeprofit,Digits);
  }

         if(SlAsPips > 0)
         {
    //double stop_loss 
         stoploss= Price - SlAsPips * Point * PipAdjust;
         }
         else if(SlAsPips == 0)
         {
         stoploss=0;
         stoploss = NormalizeDouble(stoploss,Digits);
         }
   int result = 0;
   if(Price<takeprofit && Price > stoploss &&OrdersTotal()<=2)
   {
   if(Ask > Price) //was >
   {
       result = OrderSend(Symbol(), OP_BUYLIMIT, Lots,NormalizeDouble( Price,Digits), slippage, stoploss, takeprofit,"ACandles_Long",0,0,CLR_NONE);
   }
   if(Ask < Price)//was <
   {
       result = OrderSend(Symbol(), OP_BUYSTOP, Lots, NormalizeDouble( Price,Digits), slippage, stoploss, takeprofit,"ACandles_Long",0,0,CLR_NONE);
   }
   }
   return result;
   
}

int PendingSellOrder(double price,int TpAsPips=100,int SlAsPips = 50) //Buy at the specified Point!
{
   double Price = price;double  takeprofit=0.0;  double   stoploss=0.0;
   
  //Adjust pips
   int PipAdjust = AdjustPips();
   //Adjust slippage tp and sl
   int slippage = Slippage* PipAdjust;
     if(TpAsPips !=0)
  {
      // double take_profit 
         takeprofit = Price - TpAsPips * Point * PipAdjust; 
   }
   else
   {  takeprofit = 0; }
            if(SlAsPips !=0)
         {
     //double stop_loss 
         stoploss= Price + SlAsPips * Point * PipAdjust;
         }
         else
         {  stoploss= 0;}
   int result =0;
   
      if(Price<stoploss && Price > takeprofit&&OrdersTotal()<=2)
   {
      if(Bid > Price)
   {
   result = OrderSend(Symbol(),OP_SELLSTOP,Lots,NormalizeDouble(Price,Digits),slippage,stoploss,takeprofit,"ACandles_Short",0,0,CLR_NONE);
   }
   if(Bid < Price)
   {
   result = OrderSend(Symbol(),OP_SELLLIMIT,Lots,NormalizeDouble(Price,Digits),slippage,stoploss,takeprofit,"ACandles_Short",0,0,CLR_NONE);
   }
   }
   return result;
}
bool HandleReturnedOrder(int num)
{
   bool flag = false;
  if(num<=0)
  {
      flag = false;  //Order Failed!
        
  }
  if(num>0)
  {
     flag = true; //Order Succeeded!
  }
  return flag;
}


void CheckPendingOrders()
{
 // static int prevBuy=0; static int prevSell =0;
  static bool buyT=false; static bool sellT=false;
  //check pending buys sells

    //pendingBuys=0; pendingSells=0;
 printf("Entered Once ...lastOpenTime=0"+"\t Orders= "+OrdersTotal());
 //if(prevBuy !=1 && prevSell!=1)
 //{
 
    for(int i = (OrdersTotal()-1); i >= 0; i --)
   {
   //select each trade at a  time
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        { //Count Current Pending trades
         
                //---
             
                if(OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
                {
                  Buyticket = OrderTicket();
                  //pendingBuys++;//;  //buy=1 should be!
                break;
                }
                 if(OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
                {
                  Sellticket = OrderTicket();
                  break;
               //   pendingSells++;  //sell=1 should be!
                
                }
             //---
             
         }
      }
 ///
 
      if( IsBuyTriggered()==true)//||buyT==false)
      {
             buyT=true;
          
      }
      if(buyT)
      {
           printf("Buy activated..");
            if(HandleExecBuys())
            {
                  
                 BuyFlag = true;
                 tickplease = false;
               buyT = false;
            }
         
      }
      
      
      
      if(IsSellTriggered()==true)//||sellT==false)
      {
         sellT=true;

      }     
      
      if(sellT)
      {
           printf("Sell activated..");
         if(HandleExecSells())
         {
         
            SellFlag = true;
            tickplease = false;
            //printf("sell activated..");
             sellT=false;
         }
        
      
      }


}

 //---

void checkPendingwasHit()
{
   if(pendingBuys==0|| pendingSells==0)//either was hit!
   {
         if(pendingBuys==0) //a pending buy just went off!
         {
            for(int j = (OrdersTotal()-1); j >= 0; j --)
             {
               //select the Buy trade now..
                     if( OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
                    {  if(OrderType()==OP_BUY)
                      {
                        Buyticket = OrderTicket();
                           IsBuying = True;
                           //IsSelling = false;// still we have to Delete the remaining pending sell
                        break;
                      }
                    }
             }
         }
         else if(pendingSells==0) //a pending sell just went off!
         {
         
            for(int k = (OrdersTotal()-1); k >= 0; k --)
                {
               //select each trade at a  time
                      if(OrderSelect(k, SELECT_BY_POS, MODE_TRADES))
                      {
                      if(OrderType()==OP_SELL)
                         {
                           Sellticket  = OrderTicket();
                           IsSelling = true;
                          // IsBuying = false;
                           break;
                         }
                     }
                }
         
         }
         
         if(IsBuying)
         {
             deletePendingSells(); //Delete the remaining pending sell
              //buyflag
             BuyFlag=true;
            // Seg = false;
             IsBuying = false;
         }
         
         else if(IsSelling)
         {
            //Delete pending Buys
            deletePendingBuys();
            //sellflag
            SellFlag =true;
           // BuyFlag = false;
            IsSelling = false;
         }
   
   }
   

}

bool deletePendingBuys()
{
 bool done = false;
                 for(int i = (OrdersTotal()-1); i >= 0; i --)
                {
               //select each trade at a  time
                 if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                   {
                 
                    if(OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
                        {
                        printf("found..trying to close it");
                        Sleep(1000);
                        done = OrderDelete(OrderTicket());
                            if(done)
                           {
                           printf("Buy's Closed Done!");
                              break;
                           }
                       }            
                   }
                                                     
                }
return done;

}


bool deletePendingSells()
{
 bool done = false;
 
               for(int i = (OrdersTotal()-1); i >= 0; i --)
                {
               //select each trade at a  time
                 if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                    {
                 
                    if(OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
                        {
                         
                          done = OrderDelete(OrderTicket());
                           if(done)
                           {
                           printf("Sell's Closed Done!");
                              break;
                           }

                        }            
                     }
                                            
                      
                 }
return done;

}

//---
void Movetobreakeven()
{
   for(int b=OrdersTotal()-1; b>=0; b--)
   {
    if(OrderSymbol() == Symbol())
    {
      if(OrderType() == OP_BUY)
      {
         if(Bid-OrderOpenPrice() > WhentoMoveToBE*pips)
         {
            if(OrderOpenPrice()>OrderStopLoss())
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(PipsToLockIn*pips),OrderTakeProfit(),0,clrNONE);
            }
         }
      }
    }
   }
   
   for(int s=OrdersTotal()-1; s >=0;s--)
   {
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() == Symbol())
         {
            if(OrderType() == OP_SELL)
            {
               if(OrderOpenPrice() - Ask >WhentoMoveToBE*pips)
               {
                  if(OrderOpenPrice() < OrderStopLoss())
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice() - (PipsToLockIn*pips),OrderTakeProfit(),0,clrNONE);
                  }
               }
               }
         }
      }
      }
      
      //END-FOR!

}

void AdjustTrail()
{
   for(int b=OrdersTotal()-1;b>=0;b--)
   {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() == Symbol())
         {
            if(OrderType() == OP_BUY)
            {
               if(Bid-OrderOpenPrice() > WhenToTrail*pips)
               {
                  if(OrderStopLoss()<Bid-pips*TrailAmount)
                  {
                    OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(pips*TrailAmount),OrderTakeProfit(),0,clrNONE);
                  }
               }
            }
       }
      }
   }
   //
   
      for(int s=OrdersTotal()-1;s>=0;s--)
   {
   
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol() == Symbol())
         {  
            if(OrderType() == OP_SELL)
            {
               if(OrderOpenPrice() - Ask > WhenToTrail*pips)
               {
                     if(OrderStopLoss() > Ask+TrailAmount*pips||OrderStopLoss()==0)
                     {
                        OrderModify(OrderTicket(),OrderOpenPrice(),(Ask+TrailAmount*pips),OrderTakeProfit(),0,clrNONE);
                     }
               
               }
            }
         }
      }
   
   }
}

///


void closeAllPendingOrders()

{
//static bool flag =false
  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close pending orders
      case OP_BUYLIMIT  : result = OrderDelete( OrderTicket() );
      case OP_BUYSTOP   : result = OrderDelete( OrderTicket() );
      case OP_SELLLIMIT : result = OrderDelete( OrderTicket() );
      case OP_SELLSTOP  : result = OrderDelete( OrderTicket() );
     // flag=true;
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
     //flag=false
    }  
  }

}

void closeAllOpenOrders()
{
  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          break;
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  

}
}

//---
//---
//---
//+------------------------------------------------------------------+
    bool IsBuyTriggered()
    {
    bool IsTriggered = false;
            // search in all positions from the current list of open positions
            for ( int i = OrdersTotal()-1; i>=0; i--)
            {
                if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                {
                   if(OrderType() == OP_BUY)
                   {
                    if(Buyticket ==  OrderTicket()) //Order has Changed to BUY
                    {
                       IsTriggered = true;
                    break;
                    }
                   }
                }
             
             
             }
             return IsTriggered;
       }
       
 bool IsSellTriggered()
    {
    bool IsTriggered = false;
            // search in all positions from the current list of open positions
            for ( int i = OrdersTotal()-1; i>=0; i--)
            {
                if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                {
                      if(OrderType() == OP_SELL)
                      {
                          if(Sellticket ==  OrderTicket()) //Order has Changed to BUY
                          {
                             IsTriggered = true;
                          break;
                          }
                      }
                }
              
             }
 return IsTriggered;
}
bool HandleExecBuys()
{
   printf("deleting pending sells...");
bool res  = false;
         for ( int i = OrdersTotal()-1; i>=0; i--)
            {
                 if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              if(OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)
                { 
                  res =  OrderDelete(OrderTicket(),clrAzure);
                  break;
                }
             
             }
             return res;
            }

bool HandleExecSells()
{
bool res  = false;
         for ( int i = OrdersTotal()-1; i>=0; i--)
            {
                 if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              if(OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)
                { 
                  res =  OrderDelete(OrderTicket(),clrMaroon);
                  break;
                }
             
             }
             return res;
 }
 