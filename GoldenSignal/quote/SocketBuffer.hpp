#ifndef _SOCKETBUFFER_H_
#define _SOCKETBUFFER_H_

#include <vector>

namespace quotelib
{
  class SocketBuffer
  {
  public:
    SocketBuffer()
    : buffer_(1024)
    {
      
    }
    virtual ~SocketBuffer()
    {
    }

    std::vector<char>& buffer()
    {
      return buffer_;
    }

  private:
    std::vector<char> buffer_;
  };

}

#endif /* _SOCKETBUFFER_H_ */













