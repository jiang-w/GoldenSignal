#ifndef _GROUPBOOKPOINT_H_
#define _GROUPBOOKPOINT_H_

#include "BookPoint.hpp"
#include <boost/ptr_container/ptr_list.hpp>

using namespace std;

namespace quotelib
{
  typedef boost::ptr_list<BookPoint> BookPointList;
  typedef BookPointList::iterator BookPointIterator;
  typedef BookPointList::size_type BookPointSizeType;
  typedef BookPointList::auto_type BookPointTransport;

  class GroupBookPoint : BookPoint
  {
  public:
    GroupBookPoint();
    GroupBookPoint(BookPointIterator begin, BookPointIterator end);
    virtual ~GroupBookPoint();

    virtual string to_string();
    
    void add(BookPoint *bookPoint);
    BookPointTransport remove(BookPointIterator bookPointIterator);
    auto_ptr<BookPointList> remove_all();
    void transfer(std::auto_ptr<BookPointList> other);
    BookPointIterator begin();
    BookPointIterator end();
    BookPointSizeType size();
    
  private:
    BookPointList list_;
  };

}

#endif /* _GROUPBOOKPOINT_H_ */















