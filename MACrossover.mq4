//+------------------------------------------------------------------+
//|                                                  MACrossover.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Mateus Nascimento"
#property link      "https://www.mateusnascimento.com"
#property version   "1.00"
#property strict


input int SlowMovingAverage = 26;
input int FastMovingAverage = 12;


int MagicNumber = 12345;
int MaxCloseSlippagePips = 10;
double LotsToTrade = 1.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
      
   if(IsNewBar()){
      
      // Get last moving averages
      double L1SlowMA = iMA(NULL, 0, SlowMovingAverage, 0, MODE_SMA, PRICE_CLOSE, 1);
      double L1FastMA = iMA(NULL, 0, FastMovingAverage, 0, MODE_SMA, PRICE_CLOSE, 1);
      
      // Get penult moving averages
      double L2SlowMA = iMA(NULL, 0, SlowMovingAverage, 0, MODE_SMA, PRICE_CLOSE, 2);
      double L2FastMA = iMA(NULL, 0, FastMovingAverage, 0, MODE_SMA, PRICE_CLOSE, 2);
         
      // If FastMa cross up SlowMA at last bar    
      if(L1FastMA > L1SlowMA && L2FastMA <=  L2SlowMA){
         // TODO buy
         //Print("BUY " + L1FastMA + " > " + L1SlowMA + " && " + L2FastMA + " <= " + L2SlowMA);         
         CloseSellTrades();
         int OrderResult = OrderSend(Symbol(), OP_BUY, LotsToTrade, Ask, 0, 0, 0, "Buy Order", MagicNumber, 0, clrGreen);
         
       // If FastMa cross down SlowMA at last bar
      }else if(L1FastMA < L1SlowMA && L2FastMA >=  L2SlowMA){
         // TODO sell
         CloseBuyTrades();
         int OrderResult = OrderSend(Symbol(), OP_BUY, LotsToTrade, Bid, 0, 0, 0, "Sell Order", MagicNumber, 0, clrGreen);
      }  
   }        
}

// Function verifies it is a first tick from a new bar
bool IsNewBar(){
      
   static datetime lastbar;
   datetime curbar = Time[0];
   
   if(lastbar != curbar){
      lastbar = curbar;
      return true;
   }else{
      return false;
   }
}

// Return total number of open trades
int GetTotalOpenTrades(){
   
   int TotalOpenTrades = 0;
   
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderSymbol() != Symbol()) continue;
         if(OrderMagicNumber() != MagicNumber) continue;
         if(OrderCloseTime() != 0) continue;
         
         TotalOpenTrades = TotalOpenTrades + 1; 
      }   
   }
      
   return TotalOpenTrades;
      
}

// Close all open buy trades
void CloseBuyTrades(){
   int CloseResult = 0;   
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderSymbol() != Symbol()) continue;
         if(OrderMagicNumber() != MagicNumber) continue;
         if(OrderType() == OP_SELL) continue;
         if(OrderType() == OP_BUY) CloseResult = OrderClose(OrderTicket(), OrderLots(), Bid, MaxCloseSlippagePips, clrRed);         
      }   
   }
}

// Close all open sell trades
void CloseSellTrades(){
   int CloseResult = 0;   
   for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderSymbol() != Symbol()) continue;
         if(OrderMagicNumber() != MagicNumber) continue;
         if(OrderType() == OP_BUY) continue;
         if(OrderType() == OP_SELL) CloseResult = OrderClose(OrderTicket(), OrderLots(), Bid, MaxCloseSlippagePips, clrRed);         
      }   
   }
}