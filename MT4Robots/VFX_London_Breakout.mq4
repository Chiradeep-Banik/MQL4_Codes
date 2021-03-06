//+-----------------------------------------------------------------------------------------------------------------+
//|                                                                                         VFX London Breakout.mq4 |
//|                                                                                       Copyright © 2017, Vini FX |
//|                                                                                             vini-fx@hotmail.com |
//+-----------------------------------------------------------------------------------------------------------------+

//|:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::|
//|*****************************************************************************************************************|
//| Trader,                                                                                                         |
//|                                                                                                                 |
//| 1. If this code is useful to you and you want to collaborate with my work:                                      |
//|    * PayPal..: vinicius-fx@hotmail.com;                                                                         |
//|    * NETELLER: vini-fx@hotmail.com;                                                                             |
//|    * MQL5....: https://www.mql5.com/en/users/vinicius-fx/seller.                                                |
//|                                                                                                                 |
//| 2. If you implement updates in this application, please share.                                                  |
//|                                                                                                                 |
//| Thank you very much.                                                                                            |
//|*****************************************************************************************************************|
//|:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::|

//=== Properties
#property copyright   "Copyright © 2017, Vini FX"
#property description "System of automatic trading during the London session which uses"
#property description "a strategy to identify a valid trading range in the intraday timeframes"
#property description "and awaits the breakout to open position."
#property link        "https://www.mql5.com/en/market/product/17442"
#property version     "1.10"
#property strict

//=== Enumerations
enum ENUM_LON_OPEN
  {
   H00M00 =     0,   // 00:00
   H00M30 =  1800,   // 00:30
   H01M00 =  3600,   // 01:00
   H01M30 =  5400,   // 01:30
   H02M00 =  7200,   // 02:00
   H02M30 =  9000,   // 02:30
   H03M00 = 10800,   // 03:00
   H03M30 = 12600,   // 03:30
   H04M00 = 14400,   // 04:00
   H04M30 = 16200,   // 04:30
   H05M00 = 18000,   // 05:00
   H05M30 = 19800,   // 05:30
   H06M00 = 21600,   // 06:00
   H06M30 = 23400,   // 06:30
   H07M00 = 25200,   // 07:00
   H07M30 = 27000,   // 07:30
   H08M00 = 28800,   // 08:00
   H08M30 = 30600,   // 08:30
   H09M00 = 32400,   // 09:00
   H09M30 = 34200,   // 09:30
   H10M00 = 36000,   // 10:00
   H10M30 = 37800,   // 10:30
   H11M00 = 39600,   // 11:00
   H11M30 = 41400,   // 11:30
   H12M00 = 43200,   // 12:00
   H12M30 = 45000,   // 12:30
   H13M00 = 46800,   // 13:00
   H13M30 = 48600,   // 13:30
   H14M00 = 50400,   // 14:00
   H14M30 = 52200,   // 14:30
   H15M00 = 54000,   // 15:00
   H15M30 = 55800,   // 15:30
   H16M00 = 57600,   // 16:00
   H16M30 = 59400,   // 16:30
   H17M00 = 61200,   // 17:00
   H17M30 = 63000,   // 17:30
   H18M00 = 64800,   // 18:00
   H18M30 = 66600,   // 18:30
   H19M00 = 68400,   // 19:00
   H19M30 = 70200,   // 19:30
   H20M00 = 72000,   // 20:00
   H20M30 = 73800,   // 20:30
   H21M00 = 75600,   // 21:00
   H21M30 = 77400,   // 21:30
   H22M00 = 79200,   // 22:00
   H22M30 = 81000,   // 22:30
   H23M00 = 82800,   // 23:00
   H23M30 = 84600    // 23:30
  };
enum ENUM_POS_DAY
  {
   PosLongOnly,      // Long Only
   PosShortOnly,     // Short Only
   PosLongShort,     // Long & Short
   PosNo             // None
  };
enum ENUM_RISK_BY
  {
   RiskPercentage,   // Percentage
   RiskAmount,       // Amount
   RiskFixedLot      // Fixed Lot
  };

//=== Global input variables
input ENUM_LON_OPEN LondonOpen   = H10M00;           // London Opening Time
input ENUM_POS_DAY  PosMonday    = PosNo;            // Positions On Monday
input ENUM_POS_DAY  PosTuesday   = PosShortOnly;     // Positions On Tuesday
input ENUM_POS_DAY  PosWednesday = PosShortOnly;     // Positions On Wednesday
input ENUM_POS_DAY  PosThursday  = PosShortOnly;     // Positions On Thursday
input ENUM_POS_DAY  PosFriday    = PosShortOnly;     // Positions On Friday
input ENUM_RISK_BY  PosRiskBy    = RiskPercentage;   // Set Positions Risk By
input double        PosRisk      = 0.5;              // Positions Risk
input int           StopLoss     = 300;              // Stop Loss (Points)
input int           TakeProfit   = 600;              // Take Profit (Points)
input int           MaxRange     = 380;              // Maximum Trading Range (Points)
input int           MinRange     = 110;              // Minimum Trading Range (Points)
input int           BreakRange   = 10;               // Break Of Trading Range (Points)
input int           MaxSpread    = 15;               // Maximum Spread (Points)
input int           Slippage     = 10;               // Maximum Price Slippage (Points)
input int           MagicNumber  = 112233;           // Magic Number

//=== Global internal variables
ENUM_POS_DAY Positions[7];
double       RangeSpread;
string       ErrMsg;
//+-----------------------------------------------------------------------------------------------------------------+
//| Expert initialization function                                                                                  |
//+-----------------------------------------------------------------------------------------------------------------+
int OnInit()
  {
   //--- Checks Positions Risk
   if(PosRisk <= 0)
     {
      Alert(Symbol(), " - Positions Risk is required.");
      Print(Symbol(), " - Positions Risk is required.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   //--- Checks Stop Loss Level
   if(StopLoss <= 0)
     {
      Alert(Symbol(), " - Stop Loss is required.");
      Print(Symbol(), " - Stop Loss is required.");
      return(INIT_PARAMETERS_INCORRECT);
     }
   //--- Checks Take Profit Level
   if(TakeProfit <= 0)
     {
      Alert(Symbol(), " - Take Profit is required.");
      Print(Symbol(), " - Take Profit is required.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   //--- Initializes variables
   Positions[0] = PosNo;
   Positions[1] = PosMonday;
   Positions[2] = PosTuesday;
   Positions[3] = PosWednesday;
   Positions[4] = PosThursday;
   Positions[5] = PosFriday;
   Positions[6] = PosNo;
   //--- Range spread
   RangeSpread = BreakRange * Point;

   return(INIT_SUCCEEDED);
  }
//+-----------------------------------------------------------------------------------------------------------------+
//| Expert tick function                                                                                            |
//+-----------------------------------------------------------------------------------------------------------------+
void OnTick()
  {
   //--- Local variables
   ENUM_POS_DAY Pos;
   int          k, ShiftLondon;
   datetime     TradeStart, TradeEnd;
   double       SymSpread, RangeHigh, RangeLow, Lot, SL, TP;

   //--- Initializes variables
   TradeStart = StringToTime(TimeToString(TimeCurrent(), TIME_DATE)) + LondonOpen;
   TradeEnd   = TradeStart + 18000;   //--- 18000 sec = 5 hours

   //=== Checks to open orders
   if(TimeCurrent() < TradeStart || TimeCurrent() >= TradeEnd) {return;}
   SymSpread = MarketInfo(Symbol(), MODE_SPREAD);
   if(MaxSpread > 0 && MaxSpread < SymSpread) {return;}
   SymSpread = SymSpread * Point;

   //--- Check if there is already open order
   for(k = OrdersTotal() - 1; k >= 0; k--)
     {
      if(OrderSelect(k, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {return;}
        }
     }

   //--- Identify trading range
   ShiftLondon = int((iTime(NULL, PERIOD_M15, 0) - TradeStart) / 900);   //--- 900 sec = 15 min
   RangeHigh   = iHigh(NULL, PERIOD_M15, iHighest(NULL, PERIOD_M15, MODE_HIGH, 6, ShiftLondon + 1));
   RangeLow    = iLow (NULL, PERIOD_M15, iLowest (NULL, PERIOD_M15, MODE_LOW,  6, ShiftLondon + 1));

   if((RangeHigh - RangeLow) / Point > MinRange && (RangeHigh - RangeLow) / Point < MaxRange)
     {
      Pos = Positions[DayOfWeek()];
      if(Bid > RangeHigh + RangeSpread && Bid < RangeHigh + RangeSpread * 3 && (Pos == PosLongOnly || Pos == PosLongShort))
        {
         if(iHigh(NULL, PERIOD_M15, 1) > RangeHigh + RangeSpread) {return;}
         SL = Ask - StopLoss * Point;
         if(iLow(NULL, PERIOD_M1, 0) <= SL) {return;}
         TP = Ask + TakeProfit * Point;
         Lot = CalculateVolume(OP_BUY, SL);

         if(!CheckVolume(Lot))
           {Print(Symbol(), " - ", ErrMsg);}
         else if(AccountFreeMarginCheck(Symbol(), OP_BUY, Lot) <= 0.0 || _LastError == ERR_NOT_ENOUGH_MONEY)
           {Print(Symbol(), " - ", ErrorDescription(GetLastError()));}
         else if(OrderSend(Symbol(), OP_BUY, Lot, Ask, Slippage, SL, TP, "VFX", MagicNumber, 0, clrBlue) == -1)
           {Print(Symbol(), " - ", ErrorDescription(GetLastError()));}
        }
      else if(Bid < RangeLow - RangeSpread && Bid > RangeLow - RangeSpread * 3 && (Pos == PosShortOnly || Pos == PosLongShort))
        {
         if(iLow(NULL, PERIOD_M15, 1) < RangeLow - RangeSpread) {return;}
         SL = Bid + StopLoss * Point;
         if(iHigh(NULL, PERIOD_M1, 0) + SymSpread >= SL) {return;}
         TP = Bid - TakeProfit * Point;
         Lot = CalculateVolume(OP_SELL, SL);

         if(!CheckVolume(Lot))
           {Print(Symbol(), " - ", ErrMsg);}
         else if(AccountFreeMarginCheck(Symbol(), OP_SELL, Lot) <= 0.0 || _LastError == ERR_NOT_ENOUGH_MONEY)
           {Print(Symbol(), " - ", ErrorDescription(GetLastError()));}
         else if(OrderSend(Symbol(), OP_SELL, Lot, Bid, Slippage, SL, TP, "VFX", MagicNumber, 0, clrRed) == -1)
           {Print(Symbol(), " - ", ErrorDescription(GetLastError()));}
        }
     }
  }
//+-----------------------------------------------------------------------------------------------------------------+
//| Calculate volume function                                                                                       |
//+-----------------------------------------------------------------------------------------------------------------+
double CalculateVolume(int OpType, double SL)
  {
   //--- Local variables
   double TickValue, Risk, Lot;

   //--- Checks Set Positions Risk By
   if(PosRiskBy == RiskFixedLot) {return(PosRisk);}

   //--- Tick Value
   if(OpType == OP_BUY)
     {
      TickValue = ((Ask - SL) / Point) * MarketInfo(Symbol(), MODE_TICKVALUE);
     }
   else
     {
      TickValue = ((SL - Bid) / Point) * MarketInfo(Symbol(), MODE_TICKVALUE);
     }
   if(TickValue == 0.0) {return(0.0);}
   //--- Volume Size
   Risk = PosRisk;
   if(PosRiskBy == RiskPercentage) {Risk = (AccountBalance() + AccountCredit()) * (PosRisk / 100);}
   Lot = NormalizeDouble(Risk / TickValue, 2);

   return(Lot);
  }
//+-----------------------------------------------------------------------------------------------------------------+
//| Check volume function                                                                                           |
//+-----------------------------------------------------------------------------------------------------------------+
bool CheckVolume(double Lot)
  {
   //--- Minimal allowed volume for trade operations
   double MinVolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   if(Lot < MinVolume)
     {
      ErrMsg = StringConcatenate("Volume less than the minimum allowed. The minimum volume is ", MinVolume, ".");
      return(false);
     }

   //--- Maximal allowed volume of trade operations
   double MaxVolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   if(Lot > MaxVolume)
     {
      ErrMsg = StringConcatenate("Volume greater than the maximum allowed. The maximum volume is ", MaxVolume, ".");
      return(false);
     }

   //--- Get minimal step of volume changing
   double VolumeStep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);

   int Ratio = (int)MathRound(Lot / VolumeStep);
   if(MathAbs(Ratio * VolumeStep - Lot) > 0.0000001)
     {
      ErrMsg = StringConcatenate("The volume is not multiple of the minimum gradation ", VolumeStep,
                                 ". Volume closest to the valid ", Ratio * VolumeStep, ".");
      return(false);
     }

   //--- Correct volume value
   return(true);
  }
//+-----------------------------------------------------------------------------------------------------------------+
//| Error description function                                                                                      |
//+-----------------------------------------------------------------------------------------------------------------+
string ErrorDescription(int ErrorCode)
  {
   //--- Local variable
   string ErrorMsg;

   switch(ErrorCode)
     {
      //--- Codes returned from trade server
      case 0:    ErrorMsg="No error returned.";                                             break;
      case 1:    ErrorMsg="No error returned, but the result is unknown.";                  break;
      case 2:    ErrorMsg="Common error.";                                                  break;
      case 3:    ErrorMsg="Invalid trade parameters.";                                      break;
      case 4:    ErrorMsg="Trade server is busy.";                                          break;
      case 5:    ErrorMsg="Old version of the client terminal.";                            break;
      case 6:    ErrorMsg="No connection with trade server.";                               break;
      case 7:    ErrorMsg="Not enough rights.";                                             break;
      case 8:    ErrorMsg="Too frequent requests.";                                         break;
      case 9:    ErrorMsg="Malfunctional trade operation.";                                 break;
      case 64:   ErrorMsg="Account disabled.";                                              break;
      case 65:   ErrorMsg="Invalid account.";                                               break;
      case 128:  ErrorMsg="Trade timeout.";                                                 break;
      case 129:  ErrorMsg="Invalid price.";                                                 break;
      case 130:  ErrorMsg="Invalid stops.";                                                 break;
      case 131:  ErrorMsg="Invalid trade volume.";                                          break;
      case 132:  ErrorMsg="Market is closed.";                                              break;
      case 133:  ErrorMsg="Trade is disabled.";                                             break;
      case 134:  ErrorMsg="Not enough money.";                                              break;
      case 135:  ErrorMsg="Price changed.";                                                 break;
      case 136:  ErrorMsg="Off quotes.";                                                    break;
      case 137:  ErrorMsg="Broker is busy.";                                                break;
      case 138:  ErrorMsg="Requote.";                                                       break;
      case 139:  ErrorMsg="Order is locked.";                                               break;
      case 140:  ErrorMsg="Buy orders only allowed.";                                       break;
      case 141:  ErrorMsg="Too many requests.";                                             break;
      case 145:  ErrorMsg="Modification denied because order is too close to market.";      break;
      case 146:  ErrorMsg="Trade context is busy.";                                         break;
      case 147:  ErrorMsg="Expirations are denied by broker.";                              break;
      case 148:  ErrorMsg="The amount of open and pending orders has reached the limit.";   break;
      case 149:  ErrorMsg="An attempt to open an order opposite when hedging is disabled."; break;
      case 150:  ErrorMsg="An attempt to close an order contravening the FIFO rule.";       break;
      //--- Mql4 errors
      case 4000: ErrorMsg="No error returned.";                                             break;
      case 4001: ErrorMsg="Wrong function pointer.";                                        break;
      case 4002: ErrorMsg="Array index is out of range.";                                   break;
      case 4003: ErrorMsg="No memory for function call stack.";                             break;
      case 4004: ErrorMsg="Recursive stack overflow.";                                      break;
      case 4005: ErrorMsg="Not enough stack for parameter.";                                break;
      case 4006: ErrorMsg="No memory for parameter string.";                                break;
      case 4007: ErrorMsg="No memory for temp string.";                                     break;
      case 4008: ErrorMsg="Not initialized string.";                                        break;
      case 4009: ErrorMsg="Not initialized string in array.";                               break;
      case 4010: ErrorMsg="No memory for array string.";                                    break;
      case 4011: ErrorMsg="Too long string.";                                               break;
      case 4012: ErrorMsg="Remainder from zero divide.";                                    break;
      case 4013: ErrorMsg="Zero divide.";                                                   break;
      case 4014: ErrorMsg="Unknown command.";                                               break;
      case 4015: ErrorMsg="Wrong jump (never generated error).";                            break;
      case 4016: ErrorMsg="Not initialized array.";                                         break;
      case 4017: ErrorMsg="Dll calls are not allowed.";                                     break;
      case 4018: ErrorMsg="Cannot load library.";                                           break;
      case 4019: ErrorMsg="Cannot call function.";                                          break;
      case 4020: ErrorMsg="Expert function calls are not allowed.";                         break;
      case 4021: ErrorMsg="Not enough memory for temp string returned from function.";      break;
      case 4022: ErrorMsg="System is busy (never generated error).";                        break;
      case 4023: ErrorMsg="Dll-function call critical error.";                              break;
      case 4024: ErrorMsg="Internal error.";                                                break;
      case 4025: ErrorMsg="Out of memory.";                                                 break;
      case 4026: ErrorMsg="Invalid pointer.";                                               break;
      case 4027: ErrorMsg="Too many formatters in the format function.";                    break;
      case 4028: ErrorMsg="Parameters count exceeds formatters count.";                     break;
      case 4029: ErrorMsg="Invalid array.";                                                 break;
      case 4030: ErrorMsg="No reply from chart.";                                           break;
      case 4050: ErrorMsg="Invalid function parameters count.";                             break;
      case 4051: ErrorMsg="Invalid function parameter value.";                              break;
      case 4052: ErrorMsg="String function internal error.";                                break;
      case 4053: ErrorMsg="Some array error.";                                              break;
      case 4054: ErrorMsg="Incorrect series array using.";                                  break;
      case 4055: ErrorMsg="Custom indicator error.";                                        break;
      case 4056: ErrorMsg="Arrays are incompatible.";                                       break;
      case 4057: ErrorMsg="Global variables processing error.";                             break;
      case 4058: ErrorMsg="Global variable not found.";                                     break;
      case 4059: ErrorMsg="Function is not allowed in testing mode.";                       break;
      case 4060: ErrorMsg="Function is not allowed for call.";                              break;
      case 4061: ErrorMsg="Send mail error.";                                               break;
      case 4062: ErrorMsg="String parameter expected.";                                     break;
      case 4063: ErrorMsg="Integer parameter expected.";                                    break;
      case 4064: ErrorMsg="Double parameter expected.";                                     break;
      case 4065: ErrorMsg="Array as parameter expected.";                                   break;
      case 4066: ErrorMsg="Requested history data is in updating state.";                   break;
      case 4067: ErrorMsg="Internal trade error.";                                          break;
      case 4068: ErrorMsg="Resource not found.";                                            break;
      case 4069: ErrorMsg="Resource not supported.";                                        break;
      case 4070: ErrorMsg="Duplicate resource.";                                            break;
      case 4071: ErrorMsg="Custom indicator cannot initialize.";                            break;
      case 4072: ErrorMsg="Cannot load custom indicator.";                                  break;
      case 4073: ErrorMsg="No history data.";                                               break;
      case 4074: ErrorMsg="No memory for history data.";                                    break;
      case 4075: ErrorMsg="Not enough memory for indicator calculation.";                   break;
      case 4099: ErrorMsg="End of file.";                                                   break;
      case 4100: ErrorMsg="Some file error.";                                               break;
      case 4101: ErrorMsg="Wrong file name.";                                               break;
      case 4102: ErrorMsg="Too many opened files.";                                         break;
      case 4103: ErrorMsg="Cannot open file.";                                              break;
      case 4104: ErrorMsg="Incompatible access to a file.";                                 break;
      case 4105: ErrorMsg="No order selected.";                                             break;
      case 4106: ErrorMsg="Unknown symbol.";                                                break;
      case 4107: ErrorMsg="Invalid price.";                                                 break;
      case 4108: ErrorMsg="Invalid ticket.";                                                break;
      case 4109: ErrorMsg="Trade is not allowed in the Expert Advisor properties.";         break;
      case 4110: ErrorMsg="Longs are not allowed in the Expert Advisor properties.";        break;
      case 4111: ErrorMsg="Shorts are not allowed in the Expert Advisor properties.";       break;
      case 4112: ErrorMsg="Automated trading disabled by trade server.";                    break;
      case 4200: ErrorMsg="Object already exists.";                                         break;
      case 4201: ErrorMsg="Unknown object property.";                                       break;
      case 4202: ErrorMsg="Object does not exist.";                                         break;
      case 4203: ErrorMsg="Unknown object type.";                                           break;
      case 4204: ErrorMsg="No object name.";                                                break;
      case 4205: ErrorMsg="Object coordinates error.";                                      break;
      case 4206: ErrorMsg="No specified subwindow.";                                        break;
      case 4207: ErrorMsg="Graphical object error.";                                        break;
      case 4210: ErrorMsg="Unknown chart property.";                                        break;
      case 4211: ErrorMsg="Chart not found.";                                               break;
      case 4212: ErrorMsg="Chart subwindow not found.";                                     break;
      case 4213: ErrorMsg="Chart indicator not found.";                                     break;
      case 4220: ErrorMsg="Symbol select error.";                                           break;
      case 4250: ErrorMsg="Notification error.";                                            break;
      case 4251: ErrorMsg="Notification parameter error.";                                  break;
      case 4252: ErrorMsg="Notifications disabled.";                                        break;
      case 4253: ErrorMsg="Notification send too frequent.";                                break;
      case 4260: ErrorMsg="FTP server is not specified.";                                   break;
      case 4261: ErrorMsg="FTP login is not specified.";                                    break;
      case 4262: ErrorMsg="FTP connection failed.";                                         break;
      case 4263: ErrorMsg="FTP connection closed.";                                         break;
      case 4264: ErrorMsg="FTP path not found on server.";                                  break;
      case 4265: ErrorMsg="File not found in the Files directory to send on FTP server.";   break;
      case 4266: ErrorMsg="Common error during FTP data transmission.";                     break;
      case 5001: ErrorMsg="Too many opened files.";                                         break;
      case 5002: ErrorMsg="Wrong file name.";                                               break;
      case 5003: ErrorMsg="Too long file name.";                                            break;
      case 5004: ErrorMsg="Cannot open file.";                                              break;
      case 5005: ErrorMsg="Text file buffer allocation error.";                             break;
      case 5006: ErrorMsg="Cannot delete file.";                                            break;
      case 5007: ErrorMsg="Invalid file handle (file closed or was not opened).";           break;
      case 5008: ErrorMsg="Wrong file handle (handle index is out of handle table).";       break;
      case 5009: ErrorMsg="File must be opened with FILE_WRITE flag.";                      break;
      case 5010: ErrorMsg="File must be opened with FILE_READ flag.";                       break;
      case 5011: ErrorMsg="File must be opened with FILE_BIN flag.";                        break;
      case 5012: ErrorMsg="File must be opened with FILE_TXT flag.";                        break;
      case 5013: ErrorMsg="File must be opened with FILE_TXT or FILE_CSV flag.";            break;
      case 5014: ErrorMsg="File must be opened with FILE_CSV flag.";                        break;
      case 5015: ErrorMsg="File read error.";                                               break;
      case 5016: ErrorMsg="File write error.";                                              break;
      case 5017: ErrorMsg="String size must be specified for binary file.";                 break;
      case 5018: ErrorMsg="Incompatible file (for string arrays-TXT, for others-BIN).";     break;
      case 5019: ErrorMsg="File is directory, not file.";                                   break;
      case 5020: ErrorMsg="File does not exist.";                                           break;
      case 5021: ErrorMsg="File cannot be rewritten.";                                      break;
      case 5022: ErrorMsg="Wrong directory name.";                                          break;
      case 5023: ErrorMsg="Directory does not exist.";                                      break;
      case 5024: ErrorMsg="Specified file is not directory.";                               break;
      case 5025: ErrorMsg="Cannot delete directory.";                                       break;
      case 5026: ErrorMsg="Cannot clean directory.";                                        break;
      case 5027: ErrorMsg="Array resize error.";                                            break;
      case 5028: ErrorMsg="String resize error.";                                           break;
      case 5029: ErrorMsg="Structure contains strings or dynamic arrays.";                  break;
      case 5200: ErrorMsg="Invalid URL.";                                                   break;
      case 5201: ErrorMsg="Failed to connect to specified URL.";                            break;
      case 5202: ErrorMsg="Timeout exceeded.";                                              break;
      case 5203: ErrorMsg="HTTP request failed.";                                           break;
      default:   ErrorMsg="Unknown error.";
     }
   return(ErrorMsg);
  }
//+-----------------------------------------------------------------------------------------------------------------+
//| Expert End                                                                                                      |
//+-----------------------------------------------------------------------------------------------------------------+