#ifndef _BOOPOINT_H_
#define _BOOPOINT_H_
#include <string>
#include <iostream>
#include <boost/shared_ptr.hpp>

using namespace std;

namespace quotelib
{
  class BookPoint
  {
  public:
    BookPoint();
    virtual ~BookPoint();
    virtual string to_string();
  };

  typedef boost::shared_ptr<BookPoint> BookPointPtr;
  typedef boost::shared_ptr<const BookPoint> BookPointCPtr;
}

#endif /* _BOOPOINT_H_ */










