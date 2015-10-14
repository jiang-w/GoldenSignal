#include "SerialsBookPoint.hpp"
#include <iostream>
#include "logging/DebugLog.hpp"
#include "TemplateFinder.hpp"

using namespace std;
using namespace quotelib;

DEBUG_USING_NAMESPACE

SerialsBookPoint::SerialsBookPoint(TemplateFinder* finder, string code, string indicateName)
  : code_(code),
    indicateName_(indicateName),
    indicate_(finder->get_indicate(indicateName))
{
  DEBUG_METHOD();
}

SerialsBookPoint::SerialsBookPoint(TemplateFinder* finder, string code, uint32 indicate)
  : code_(code),
    indicateName_(finder->get_indicateName(indicate)),
    indicate_(indicate)
{
  DEBUG_METHOD();
}

    
SerialsBookPoint::~SerialsBookPoint()
{
  DEBUG_METHOD();
}

bool
SerialsBookPoint::operator==(const SerialsBookPoint &a) const
{
  return (a.code_ == code_ && a.indicateName_ == indicateName_);
}

bool
SerialsBookPoint::operator<(const SerialsBookPoint &a) const
{
  bool r = false;
  if (code_ < a.code_)
    r = true;
  else if (code_ == a.code_){
    if (indicateName_ < a.indicateName_)
      r = true;
    else
      r = false;
  }
  return r;
}

bool
SerialsBookPoint::operator!=(const SerialsBookPoint &a) const
{
  return ((a.code_ != code_) || (a.indicateName_ != indicateName_));
}

string
SerialsBookPoint::to_string()
{
  //  DEBUG_METHOD();
  //  DEBUG_VALUE_AND_TYPE_OF(*this);
  return "code: " + code_ + " indicateName: " + indicateName_;
}
















