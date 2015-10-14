#ifndef _BDMESSAGE_H_
#define _BDMESSAGE_H_

//#include <stdio.h>
//#include <string.h>
//#include <assert.h>
#include <vector>
#include <iterator>
#include <sstream>
#include <iostream>

using namespace std;

namespace quotelib
{
  class BDMessage
  {
  public:
    enum { header_length = 12 };
    //default construtor
    BDMessage()
      : data_(header_length)
    {

    }

    //rang constructor
    BDMessage(vector<char>::iterator first, vector<char>::iterator last)
      : data_(first, last)
    {

    }

    // //copy constructor
    BDMessage(const BDMessage& msg)
      : data_(msg.data_)
    {
      
    }

    virtual ~BDMessage()
    {

    }

    char I()  //instrument W: Windows I: iPhone A: iPad S: SilverLight Web D:Andriod
    {
      assert_length();
      return data_[0];
    }

    void set_I(char c)
    {
      data_[0] = c;    
    }

    char P()  //product T: Terminal P: Portalbe
    {
      assert_length();
      return data_[1];
    }

    void set_P(char c)
    {
      data_[1] = c;
    }

    char O()  // reserved
    {
      assert_length();
      return data_[2];
    }

    void set_O(char c)
    {
      data_[2] = c;
    }

    char V()  // reserved
    {
      assert_length();
      return data_[3];
    }
    
    void set_V(char c)
    {
      data_[3] = c;
    }

    char major()
    {
      assert_length();
      return data_[4];
    }

    void set_major(char c)
    {
      data_[4] = c;
    }

    char minor()
    {
      assert_length();
      return data_[5];
    }

    void set_minor(char c)
    {
      data_[5] = c;
    }

    char flags()
    {
      assert_length();
      return data_[6];
    }
    
    void set_flags(char c)
    {
      data_[6] = c;
    }
    
    char value()
    {
      assert_length();
      return data_[7];
    }

    void set_value(char c)
    {
      data_[7] = c;
    }

    void set_body(int body_length, char* first, char* last)
    {
      //check length
      if (data_.size() < body_length + header_length)
	data_.resize(header_length + body_length);
      
      //set body length uses big_endianness
      static union{
	int k;
	char c[4];
      } p, q;
      
      p.k = 1;
      q.k = body_length;
      if (p.c[0] == 1) {
	//is little endian
	std::reverse(q.c, q.c + 4);
      }

      data_[8] = q.c[0];
      data_[9] = q.c[1];
      data_[10] = q.c[2];
      data_[11] = q.c[3];

      int count = 0;
      char* it = first;
      int i = 0;
      //std::cout << "data_body ";
      while(it != last){
      	data_[12 + i] = (*it);
      	//std::cout << std::hex << (int) data_[12 + i] << " ";
      	++ i;
      	++ it;
      	++ count;
      }

      //std::cout << std::endl;

      // stringstream ss;
      // ss << "set body_length: " << body_length << "body_count:" << count;
      // std::cout << ss.str() << std::endl;
    }

    int body_length() //uses big_endianness because connect to  java server
    {
      int body_length = ((int)data_[8]) * 256 * 256 * 256 + 
      	((int)data_[9]) * 256 * 256  +
      	((int)data_[10]) * 256 +
      	((int)data_[11]);
      // stringstream ss;
      // ss << (int)data_[8]  << " * 256 * 256 * 256  +" << 
      // 	(int)data_[9] << " * 256 * 256 +" <<
      // 	(int)data_[10] << " * 256 +" <<
      // 	(int)data_[11] << " ";	
      // ss << "get body_length: " << body_length;
      // std::cout << ss.str() << std::endl;
      return body_length;
    }
    
    unsigned char* body()
    {
      assert_length();
      return &data_[0] + header_length;
    }
    
    int length()
    {
      assert_length();
      return header_length + body_length();
    }

    unsigned char* data()
    {
      assert_length();
      return &data_[0];
    }

    int size()
    {
      return data_.size();
    }

    void resize(int length)
    {
      data_.resize(length);
    }

    // void set_data(char* data)
    // {
    //   data_ = data;
    // }
  private:    
    inline void assert_length()
    {
      //assert(strlen(data_) >= header_length);
    }
    vector<unsigned char> data_;
  };
}

#endif /* _BDMESSAGE_H_ */














