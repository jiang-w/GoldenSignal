#include "ScalarBookPoint.hpp"
#include <iostream>
#include "logging/DebugLog.hpp"
#include "TemplateFinder.hpp"

DEBUG_USING_NAMESPACE

using namespace std;
using namespace quotelib;

ScalarBookPoint::ScalarBookPoint(TemplateFinder* finder, string code, string indicateName)
  : code_(code), 
    indicate_(finder->get_indicate(indicateName)),
    indicateName_(indicateName)
{
  DEBUG_METHOD();
}

ScalarBookPoint::ScalarBookPoint(TemplateFinder* finder, string code, uint32 indicate)
  : code_(code)
  , indicate_(indicate)
  , indicateName_(finder->get_indicateName(indicate))
{
  DEBUG_METHOD();
}

ScalarBookPoint::~ScalarBookPoint()
{
  DEBUG_METHOD();
}


bool ScalarBookPoint::operator==(const ScalarBookPoint &a) const {
  return (a.code_ == code_ && a.indicateName_ == indicateName_);
}

bool ScalarBookPoint::operator<(const ScalarBookPoint &a) const {
  bool r = false;
  if (code_ < a.code_)
    r = true;
  else if (code_ == a.code_) {
    if (indicateName_ < a.indicateName_)
      r = true;
    else
      r = false;
  }
  return r;
}

bool ScalarBookPoint::operator!=(const ScalarBookPoint &a) const {
  return ((a.code_ != code_) || (a.indicateName_ != indicateName_));
}

string
ScalarBookPoint::to_string()
{
  //DEBUG_METHOD();
  //DEBUG_VALUE_AND_TYPE_OF(*this);
  return "code: " + code_ + " indicateName: " + indicateName_;
}
