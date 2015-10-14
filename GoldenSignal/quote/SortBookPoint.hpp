#ifndef _SORTBOOKPOINT_H_
#define _SORTBOOKPOINT_H_

#include <iostream>
#include "BookPoint.hpp"
#include "TemplateFinder.hpp"

using namespace std;

namespace quotelib
{
  enum SortType {
    asc = 1,
    des = 2,
    none = 3
  };

  class SortBookPoint : public BookPoint
  {
  public:
    SortBookPoint(TemplateFinder* finder, uint64 sectorId, string indicateName, SortType sortDirection);
    SortBookPoint(TemplateFinder* finder, uint64 sectorId, uint32 indicate, SortType sortDirection);
    virtual ~SortBookPoint();
    
    virtual string to_string();
    bool operator==(const SortBookPoint &a) const;
    bool operator!=(const SortBookPoint &a) const;
    bool operator<(const SortBookPoint &a) const;
    friend inline ostream & operator<<(ostream &os, const SortBookPoint &a)
    {
      os << "SortBookPoint sectorId: " << a.sectorId_ << 
	" indicateName: " << a.indicateName_ <<
	" sortType_" << a.sortDirection_;
      return os;
    }

    uint64 SectorId()
    {
      return sectorId_;
    }

    string IndicateName()
    {
      return indicateName_;
    }

    uint32 Indicate()
    {
      return indicate_;
    }

    SortType SortDirection()
    {
      return sortDirection_;
    }

  private:
    uint64 sectorId_;
    string indicateName_;
    uint32 indicate_;
    SortType sortDirection_;
  };
}

#endif /* _SORTBOOKPOINT_H_ */










