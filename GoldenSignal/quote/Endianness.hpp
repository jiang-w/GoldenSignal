#ifndef _ENDIANNESS_H_
#define _ENDIANNESS_H_

#include <vector>

using namespace std;

namespace quotelib
{
  class Endianness
  {
  public:
    Endianness()
    {
      int i = 1;
      char* low = (char*) &i;
      if (low[0] == 1){
	is_big_endian_ = true;
      }
      else {
       	is_big_endian_ = false;	    
      } 
    }

    virtual ~Endianness()
    {
    }

    int get_length(vector<char> buffer, vector<char>::size_type start)
    {
      char buf[4];
      if (is_big_endian_)
	for (int i = 0; i < 4; ++i)
	  buf[i] = buffer[start + i];
      else 
	for (int i = 0; i < 4; ++i)
	  buf[i] = buffer[start + 4 - i];

      return buf[0] * 256 * 256 * 256 + buf[1] * 256 * 256 + buf[2] * 256 + buf[3];
    }

    void put_length_big_endian(vector<char> buffer, vector<char>::size_type start, int length)
    {
      for (int i = 0; i < 4; ++i){
	buffer[start + i] = (char) length >> (8 * (4 - i - 1));
      }
    }

    bool is_big_endian()
    {
      return is_big_endian_;
    }

  private:
    bool is_big_endian_;
  };
}

#endif /* _ENDIANNESS_H_ */










