#ifndef _MESSAGEBOOKPOINTCONVERTER_H_
#define _MESSAGEBOOKPOINTCONVERTER_H_

#include "GroupBookPoint.hpp"
#include "BDMessage.hpp"

#include "Application/QuickFAST.h"
#include "Codecs/TemplateRegistry.h"
#include "Codecs/Encoder.h"
#include "Codecs/Decoder.h"

#include "Codecs/SingleMessageConsumer.h"
#include "Codecs/GenericMessageBuilder.h"

using namespace std;
using namespace QuickFAST;

namespace quotelib
{
  enum MessageType {
    Sub = 1,
    UnSub = 2
  };
  
  class BookPointFieldItem
  {
  private:
    BookPointPtr book_point_;
    Messages::MessageField msg_field_;

  public:
    BookPointFieldItem(BookPointPtr book_point, Messages::MessageField msg_field)
      : book_point_(book_point),
	msg_field_(msg_field)
    {
      
    }

    BookPointPtr getBookPoint()
    {
      return book_point_;
    }

    Messages::MessageField getMessageField()
    {
      return msg_field_;
    }
  };
  
  class MessageBookPointConverter
  {
  public:
    MessageBookPointConverter(Codecs::TemplateRegistryPtr registry);
    virtual ~MessageBookPointConverter();
    
    void GroupMessageToSubMessage(GroupBookPoint& group, vector<BDMessage>& msgs);
    void GroupMessageToUnSubMessage(GroupBookPoint& group, vector<BDMessage>& msgs);
    void GroupBookPointToMessages(GroupBookPoint& subGroup, 
				  GroupBookPoint& unsubGroup, 
				  vector<BDMessage>& msgs);
    void MessageToBookPointVector(BDMessage& msg, 
    				  vector< BookPointFieldItem >& book_point_vector);
    const Messages::FieldCPtr& field();
    Messages::Message& message()
    {
      return consumer_.message();
    }
    
    void EncodeHeartbeat(BDMessage& msg);
  private:
    bool BookPointToMessage(BookPoint* bookPoint, MessageType msgType, BDMessage& msg);

    void ConvertToMultiRequestMessage(map<string, vector<uint32> >& subMap,
    				      map<string, vector<uint32> >& unsubMap,
    				      BDMessage& msg);
    
  private:
    Codecs::TemplateRegistryPtr registry_;

    //basic request response message template
    Codecs::TemplatePtr heartbeatRequest;
    
    Codecs::TemplatePtr scalarRequest;
    Codecs::TemplatePtr serialsRequest;
    Codecs::TemplatePtr sortRequest;
    Codecs::TemplatePtr multiScalarRequest;
    
    Codecs::TemplatePtr scalarResponse;
    Codecs::TemplatePtr serialsResponse;
    Codecs::TemplatePtr sortResponse;
    Codecs::TemplatePtr multiScalarResponse;

    Codecs::Encoder encoder_;
    Codecs::Decoder decoder_;

    Codecs::SingleMessageConsumer consumer_;
    //Codecs::GenericGroupBuilder builder_;

    BDMessage heartbeat_;
  };
}

#endif /* _MESSAGEBOOKPOINTCONVERTER_H_ */
















