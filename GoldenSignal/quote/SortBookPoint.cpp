#include "SortBookPoint.hpp"
#include <iostream>
#include <string>
#include <boost/lexical_cast.hpp>
#include "logging/DebugLog.hpp"
#include "TemplateFinder.hpp"

using namespace std;
using namespace quotelib;

DEBUG_USING_NAMESPACE

SortBookPoint::SortBookPoint(TemplateFinder* finder, uint64 sectorId, string indicateName, SortType sortDirection)
  : sectorId_(sectorId),
    indicateName_(indicateName),
    indicate_(finder->get_indicate(indicateName)),
    sortDirection_(sortDirection)
{
  DEBUG_METHOD();
}

SortBookPoint::SortBookPoint(TemplateFinder* finder, uint64 sectorId, uint32 indicate, SortType sortDirection)
  : sectorId_(sectorId),
    indicateName_(finder->get_indicateName(indicate)),
    indicate_(indicate),
    sortDirection_(sortDirection)
{
  DEBUG_METHOD();
}

SortBookPoint::~SortBookPoint()
{
  DEBUG_METHOD();
}

bool
SortBookPoint::operator==(const SortBookPoint &a) const
{
  return ((sectorId_ == a.sectorId_) && 
	  (indicateName_ == a.indicateName_) &&
	  (sortDirection_ == a.sortDirection_));
}

bool
SortBookPoint::operator!=(const SortBookPoint &a) const
{
  return ((sectorId_ != a.sectorId_) || 
	  (indicateName_ != a.indicateName_) ||
	  (sortDirection_ == a.sortDirection_));
}

bool
SortBookPoint::operator<(const SortBookPoint &a) const
{
  bool r = false;
  if (sectorId_ < a.sectorId_)
    r = true;
  else if (sectorId_ == a.sectorId_) {
    if (indicateName_ < a.indicateName_)
      r = true;
    else if (indicateName_ == a.indicateName_) {
      if (sortDirection_ < a.sortDirection_)
	r = true;
      else
	r = false;      
    }
  }
  return r;
}

string
SortBookPoint::to_string()
{
  return "sectorID: " + boost::lexical_cast<string>(sectorId_) + 
    " indicateName: " + indicateName_ + 
    " sortType: " + boost::lexical_cast<string>(sortDirection_);
}




















