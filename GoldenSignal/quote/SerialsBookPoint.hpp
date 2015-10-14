#ifndef _SERIALSBOOKPOINT_H_
#define _SERIALSBOOKPOINT_H_

#include <iostream>
#include <string>
#include "BookPoint.hpp"
#include "TemplateFinder.hpp"

using namespace std;

namespace quotelib
{
    enum SerialsNumberType {
        Day = 1,    //per day
        Number = 2, //per number
        TREND_5MIN = 5, // 分钟线请求(五分钟)
        KLINE_MIN = 11,
        KLINE_5MIN = 12,
        KLINE_15MIN = 13,
        KLINE_30MIN = 14,
        KLINE_60MIN = 15,
        KLINE_DAY = 16,
        KLINE_WEEK = 17,
        KLINE_MONTH = 18,
        KLINE_SEASON = 19,
        KLINE_YEAR = 20
    };

  class SerialsBookPoint : public BookPoint
  {
  public:
    //SerialsBookPoint();
    SerialsBookPoint(TemplateFinder* finder, string code, string indicateName);
    SerialsBookPoint(TemplateFinder* finder, string code, uint32 indicate);
    virtual ~SerialsBookPoint();
    
    virtual string to_string();
    bool operator==(const SerialsBookPoint &a) const;
    bool operator!=(const SerialsBookPoint &a) const;
    bool operator<(const SerialsBookPoint &a) const;
    friend inline ostream & operator<<(ostream &os, const SerialsBookPoint &a)
    {
      os << "SerialsBookPoint code: " << a.code_ << " indicateName: " << a.indicateName_ ;
      return os;
    }

    string Code()
    {
      return code_;
    }

    string IndicateName()
    {
      return indicateName_;
    }
    
    uint32 Indicate()
    {
      return indicate_;
    }

    uint32 BeginDate()
    {
      return beginDate_;
    }

    void set_BeginDate(uint32 value)
    {
      beginDate_ = value;
    }

    uint32 BeginTime()
    {
      return beginTime_;
    }

    void set_BeginTime(uint32 value)
    {
      beginTime_ = value;
    }

    SerialsNumberType NumberType()
    {
      return numberType_;
    }

    void set_NumberType(SerialsNumberType value)
    {
      numberType_ = value;
    }

    int NumberFromBegin()
    {
      return numberFromBegin_;
    }

    void set_NumberFromBegin(int value)
    {
      numberFromBegin_ = value;
    }

  private:
    string code_;
    string indicateName_;
    uint32 indicate_;
    uint32 beginDate_;
    uint32 beginTime_;
    SerialsNumberType numberType_;
    int numberFromBegin_;
    
  };
}
#endif /* _SERIALSBOOKPOINT_H_ */















