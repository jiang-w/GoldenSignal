#include "BookPoint.hpp"
#include "GroupBookPoint.hpp"
#include <string>
#include <exception>
#include <sstream>
#include "logging/DebugLog.hpp"


using namespace quotelib;
using namespace std;

DEBUG_USING_NAMESPACE

GroupBookPoint::GroupBookPoint()
{
  DEBUG_METHOD();
}

GroupBookPoint::GroupBookPoint(BookPointIterator begin, BookPointIterator end)
  : list_(begin, end)
{
  DEBUG_METHOD();
}

GroupBookPoint::~GroupBookPoint()
{
  DEBUG_METHOD();
}


void
GroupBookPoint::add(BookPoint *bookPoint)
{
  list_.push_back(bookPoint);
}

BookPointTransport 
GroupBookPoint::remove(BookPointIterator bookPointIterator)
{
  if (bookPointIterator == list_.end()){
    throw std::exception();
  }
  return list_.release(bookPointIterator);
}

auto_ptr<BookPointList>
GroupBookPoint::remove_all(){
  return list_.release();
}

void
GroupBookPoint::transfer(auto_ptr<BookPointList> other)
{
  list_.transfer(list_.end(), *other);
  BOOST_ASSERT(other->empty());
}

BookPointIterator 
GroupBookPoint::begin()
{
  return list_.begin();
}

BookPointIterator
GroupBookPoint::end()
{
  return list_.end();
}

BookPointSizeType
GroupBookPoint::size()
{
  return list_.size();
}

string 
GroupBookPoint::to_string()
{
  DEBUG_METHOD();
  std::ostringstream ss;
  for(BookPointIterator i = list_.begin(), end = list_.end();
      i != end; ++i){
    ss << (*i).to_string() << std::endl;
  }
  return ss.str();
}


















