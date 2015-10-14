#ifndef _SCALARBOOKPOINT_H_
#define _SCALARBOOKPOINT_H_

#include <iostream>
#include "BookPoint.hpp"
#include "TemplateFinder.hpp"

using namespace std;

namespace quotelib
{
  class ScalarBookPoint : public BookPoint
  {
  public:
    //ScalarBookPoint();
    ScalarBookPoint(TemplateFinder* finder, string code, string indicateName);
    ScalarBookPoint(TemplateFinder* finder, string code, uint32 indicate);

    virtual ~ScalarBookPoint();
  
    virtual string to_string();
    bool operator==(const ScalarBookPoint &a) const;
    bool operator!=(const ScalarBookPoint &a) const;
    bool operator<(const ScalarBookPoint &a) const;
    friend inline ostream & operator<<(ostream &os, const ScalarBookPoint &a)
    {
      os << "ScalarBookPoint code: " << a.code_ << " indicateName: " << a.indicateName_ ;
      return os;
    }
    
    string Code()
    {
      return code_;
    }

    uint32 Indicate()
    {
      return indicate_;
    }

    string IndicateName()
    {
      return indicateName_;
    }
  private:
    string code_;
    uint32 indicate_;
    string indicateName_;
  };

}

#endif /* _SCALARBOOKPOINT_H_ */










