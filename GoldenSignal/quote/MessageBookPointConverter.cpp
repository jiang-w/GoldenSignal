#include "MessageBookPointConverter.hpp"
#include "BDMessage.hpp"
#include "GroupBookPoint.hpp"
#include "ScalarBookPoint.hpp"
#include "SerialsBookPoint.hpp"
#include "SortBookPoint.hpp"
#include "TemplateFinder.hpp"

#include "logging/DebugLog.hpp"

#include "Application/QuickFAST.h"
#include "Common/WorkingBuffer.h"
#include "Common/Types.h"
#include "Messages/Message.h"
#include "Codecs/DataDestination.h"
#include "Codecs/Encoder.h"
#include "Codecs/Decoder.h"
#include "Codecs/SingleMessageConsumer.h"
#include "Codecs/GenericMessageBuilder.h"
#include "Codecs/DataSourceBuffer.h"

#include "Messages/FieldUInt32.h"
#include "Messages/FieldInt32.h"
#include "Messages/FieldUInt64.h"
#include "Messages/FieldAscii.h"
#include "Messages/Sequence.h"
#include "Messages/FieldSequence.h"
#include "Messages/MessageFormatter.h"

#include "Codecs/XMLTemplateParser.h"

using namespace std;
using namespace QuickFAST;
using namespace quotelib;

DEBUG_USING_NAMESPACE

MessageBookPointConverter::MessageBookPointConverter(Codecs::TemplateRegistryPtr registry)
  : registry_(registry)
  , encoder_(registry)
  , decoder_(registry)
  , heartbeat_()
  , consumer_()
{
  if (! registry->findNamedTemplate("HeartBeat", "", heartbeatRequest))
    std::cerr << "can not find HeartBeat Template" << std::endl;

  if (! registry->findNamedTemplate("ScalarRequest", "", scalarRequest))
    std::cerr << "can not find ScalarRequest Template" << std::endl;
  if (!registry->findNamedTemplate("SerialsRequest", "", serialsRequest))
    std::cerr << "can not find SerialsRequest Template" << std::endl;
  if (!registry->findNamedTemplate("SortRequest", "", sortRequest))
    std::cerr << "can not find SortRequest Template" << std::endl;
  if (!registry->findNamedTemplate("MultiScalarRequest", "", multiScalarRequest))
    std::cerr << "can not find MultiScalarRequest Template" << std::endl;

  if (!registry->findNamedTemplate("ScalarResponse", "", scalarResponse))
    std::cerr << "can not find ScalarResponse Template" << std::endl;
  if (!registry->findNamedTemplate("SerialsResponse", "", serialsResponse))
    std::cerr << "can not find SerialsResponse Template" << std::endl;
  if (!registry->findNamedTemplate("SortResponse", "", sortResponse))
    std::cerr << "can not find SortResponse Template" << std::endl;
  if (!registry->findNamedTemplate("MultiScalarResponse", "", multiScalarResponse))
    std::cerr << "can not find MultiScalarResponse Template" << std::endl;

  
}

MessageBookPointConverter::~MessageBookPointConverter()
{

}

void 
MessageBookPointConverter::GroupMessageToSubMessage(GroupBookPoint& group, 
						    vector<BDMessage>& msgs)
{
  DEBUG_METHOD();
  GroupBookPoint unsub_grop;
  GroupBookPointToMessages(group, unsub_grop, msgs);
}
							   

void
MessageBookPointConverter::GroupMessageToUnSubMessage(GroupBookPoint& group,
						      vector<BDMessage>& msgs)
{
  DEBUG_METHOD();
  GroupBookPoint sub_group;
  GroupBookPointToMessages(sub_group, group, msgs);
}

void
ConvertOneCodeSq(map<string, vector<uint32> >& oneMap, 
		 Messages::Sequence& code_sq)
{
  if (oneMap.size() == 0) {
    return;
  }
  map<string, vector<uint32> >::iterator ir;
  Messages::FieldIdentityCPtr length_field(new Messages::FieldIdentity("length"));

  for (ir = oneMap.begin(); ir != oneMap.end(); ++ ir) {
    string code = ir->first;
    Messages::FieldSetPtr code_item(new Messages::FieldSet(2));
    //add code
    code_item->addField(new Messages::FieldIdentity("Code"), 
			Messages::FieldAscii::create(code));
    //std::cout << "add code:" << code << std::endl;
      
    //add indicates
    Messages::SequencePtr indicate_sq(new Messages::Sequence(length_field, ir->second.size()));
    for (vector<uint32>::iterator ir_indicate = ir->second.begin(); ir_indicate != ir->second.end(); ++ ir_indicate){
      Messages::FieldSetPtr indicate_item(new Messages::FieldSet(1));
      indicate_item->addField(new Messages::FieldIdentity("Indicate"), 
                              Messages::FieldUInt32::create(*ir_indicate));
      // std::stringstream ss;
      // ss << "add inidicate:" << *ir_indicate;
      // std::cout << ss.str() << std::endl;
      indicate_sq->addEntry(indicate_item);
    }
    code_item->addField(Messages::FieldIdentityCPtr(new Messages::FieldIdentity("IndicateSq")), Messages::FieldSequence::create(indicate_sq));
    code_sq.addEntry(code_item);
  }
}

void 
MessageBookPointConverter::ConvertToMultiRequestMessage(map<string, vector<uint32> >& subMap,
							map<string, vector<uint32> >& unsubMap,
							BDMessage& msg)
{
  DEBUG_METHOD();
  Messages::Message fast_msg(2);
  Codecs::DataDestination des;
  WorkingBuffer wb;
  
  Messages::FieldIdentityCPtr length_field(new Messages::FieldIdentity("length"));
  // std::stringstream ss;
  // ss << "ConvertToMultiRequestMessage sub:" << subMap.size() << " unsub:" << unsubMap.size();
  // std::cout << ss.str() << std::endl;
  //add sub
  if (subMap.size() > 0) {
    // std::cout << "add sub bookpoint" << std::endl;
    Messages::SequencePtr sub_sq(new Messages::Sequence(length_field, subMap.size()));
    ConvertOneCodeSq(subMap, *sub_sq);
    fast_msg.addField(Messages::FieldIdentityCPtr(new Messages::FieldIdentity("SubCodeSq")), 
		      Messages::FieldSequence::create(sub_sq));
  }
  else {
    // fast_msg.addField(Messages::FieldIdentityCPtr(new Messages::FieldIdentity("SubCodeSq")),
    // 		      Messages::FieldSequence::createNull());
  }
    
  //add unsub
  if (unsubMap.size() > 0) {
    // std::cout << "add unsub bookpoint" << std::endl;
    Messages::SequencePtr unsub_sq(new Messages::Sequence(length_field, subMap.size()));
    ConvertOneCodeSq(unsubMap, *unsub_sq);
    fast_msg.addField(Messages::FieldIdentityCPtr(new Messages::FieldIdentity("UnSubCodeSq")),
		      Messages::FieldSequence::create(unsub_sq));
  }
  else {
    // fast_msg.addField(Messages::FieldIdentityCPtr(new Messages::FieldIdentity("UnSubCodeSq")),
    // 		      Messages::FieldSequence::createNull());
  }
  
  //display fast_msg
  // QuickFAST::Messages::MessageFormatter formatter(std::cout);
  // formatter.formatMessage(fast_msg);
  encoder_.encodeMessage(des, multiScalarRequest->getId(), fast_msg);
  des.toWorkingBuffer(wb);
  msg.set_I('A'); //ipad
  msg.set_P('P'); //portable
  msg.set_body(wb.size(), (char*)wb.begin(), (char*)wb.end());
}


void 
MessageBookPointConverter::GroupBookPointToMessages(GroupBookPoint& subGroup, 
						    GroupBookPoint& unsubGroup, 
						    vector<BDMessage>& msgs)
{
  DEBUG_METHOD();
  ScalarBookPoint* scalarBookPoint = NULL;
  SerialsBookPoint* serialsBookPoint = NULL;
  SortBookPoint* sortBookPoint = NULL;
  
  map<string, vector<uint32> > sub_map;
  map<string, vector<uint32> > unsub_map;
  //convert to multiRequestMessage
  for(BookPointIterator i = subGroup.begin(), end = subGroup.end();
      i != end; ++ i) {
    BDMessage bd_msg;
    if (serialsBookPoint = dynamic_cast<SerialsBookPoint*>(&*i)){
      if (BookPointToMessage(&*i, Sub, bd_msg)) {
	msgs.push_back(bd_msg);
      }
    }
    else if (sortBookPoint = dynamic_cast<SortBookPoint*>(&*i)){
      if (BookPointToMessage(&*i, Sub, bd_msg)) {
	msgs.push_back(bd_msg);
      }
    }
    else if (scalarBookPoint = dynamic_cast<ScalarBookPoint*>(&*i)) {
      string code = scalarBookPoint->Code();
      uint32 indicate = scalarBookPoint->Indicate();
      // std::stringstream ss;
      // ss << "insert to submap code:" << code << " indicate:" << indicate;
      // std::cout << ss.str() << std::endl;
      map<string, vector<uint32> >::iterator ir;
      ir = sub_map.find(code);
      if (ir == sub_map.end()) {
	vector<uint32> indicates;
	indicates.push_back(indicate);
	// std::cout << "insert new indicate" << std::endl;
	sub_map.insert(map<string, vector<uint32> >::value_type(code, indicates));
      }
      else {
	// std::cout << "add new indicate" << std::endl;
	ir->second.push_back(indicate);
      }
    }
  }

  for(BookPointIterator i = unsubGroup.begin(), end = unsubGroup.end();
      i != end; ++ i) {
    if (scalarBookPoint = dynamic_cast<ScalarBookPoint*>(&*i)) {
      string code = scalarBookPoint->Code();
      uint32 indicate = scalarBookPoint->Indicate();
      map<string, vector<uint32> >::iterator ir;
      ir = unsub_map.find(code);
      if (ir == unsub_map.end()) {
	vector<uint32> indicates;
	indicates.push_back(indicate);
	unsub_map.insert(map<string, vector<uint32> >::value_type(code, indicates));
      }
      else {
	ir->second.push_back(indicate);
      }
    }
  }
  // std::cout << "convert to multi request messages" << std::endl;
  BDMessage multi_msg;
  ConvertToMultiRequestMessage(sub_map, unsub_map, multi_msg);
  msgs.push_back(multi_msg);
}

//can not use the static heartbeat messages,
//because the presencemap is different according then encoding sequence
void
MessageBookPointConverter::EncodeHeartbeat(BDMessage& msg)
{
  Messages::Message fast_msg(1);
  Codecs::DataDestination des;
  WorkingBuffer wb;
  
  fast_msg.addField(new Messages::FieldIdentity("HeartBeatFlag"),
		    Messages::FieldUInt32::create(80808));
  
  encoder_.encodeMessage(des, heartbeatRequest->getId(), fast_msg);
  des.toWorkingBuffer(wb);
  msg.set_I('A'); //ipad
  msg.set_P('P'); //portable
  msg.set_body(wb.size(), (char*)wb.begin(), (char*)wb.end());
}

bool 
MessageBookPointConverter::BookPointToMessage(BookPoint* bookPoint,
					      MessageType msgType, BDMessage& msg)
{
  DEBUG_METHOD();
  ScalarBookPoint* scalarBookPoint;
  SerialsBookPoint* serialsBookPoint;
  SortBookPoint* sortBookPoint;

  //Messages::Message fast_msg(registry_->maxFieldCount());
  Codecs::DataDestination des;
  WorkingBuffer wb;
  bool r = false;
  if ((scalarBookPoint = dynamic_cast<ScalarBookPoint*>(bookPoint))){
    Messages::Message fast_msg(3);
    fast_msg.addField(new Messages::FieldIdentity("MessageType"),
		      Messages::FieldUInt32::create((uint)msgType));
    fast_msg.addField(new Messages::FieldIdentity("Code"),
		      Messages::FieldAscii::create(scalarBookPoint->Code()));
    fast_msg.addField(new Messages::FieldIdentity("Indicate"),
		      Messages::FieldUInt32::create(scalarBookPoint->Indicate()));

    // std::stringstream ss;
    // ss << "templateID: " << scalarRequest->getId() << std::endl;
    // std::cout << ss.str() << std::endl;
    encoder_.encodeMessage(des, scalarRequest->getId(), fast_msg);
    des.toWorkingBuffer(wb);
    r = true;
  }
  else if ((serialsBookPoint = dynamic_cast<SerialsBookPoint*>(bookPoint)) && (msgType == Sub)){
    Messages::Message fast_msg(6);
    fast_msg.addField(new Messages::FieldIdentity("Code"), 
		      Messages::FieldAscii::create(serialsBookPoint->Code()));
    fast_msg.addField(new Messages::FieldIdentity("Indicate"),
		      Messages::FieldUInt32::create(serialsBookPoint->Indicate()));
    fast_msg.addField(new Messages::FieldIdentity("BeginDate"),
		      Messages::FieldUInt32::create(serialsBookPoint->BeginDate()));
    fast_msg.addField(new Messages::FieldIdentity("BeginTime"),
		      Messages::FieldUInt32::create(serialsBookPoint->BeginTime()));
    fast_msg.addField(new Messages::FieldIdentity("NumberType"),
		      Messages::FieldUInt32::create(serialsBookPoint->NumberType()));
    fast_msg.addField(new Messages::FieldIdentity("NumberFromBegin"),
		      Messages::FieldInt32::create(serialsBookPoint->NumberFromBegin()));

    encoder_.encodeMessage(des, serialsRequest->getId(), fast_msg);
    des.toWorkingBuffer(wb);
    r = true;
  }
  else if ((sortBookPoint = dynamic_cast<SortBookPoint*>(bookPoint)) && (msgType == Sub)){
    Messages::Message fast_msg(3);
    fast_msg.addField(new Messages::FieldIdentity("SectorId"),
		      Messages::FieldUInt64::create(sortBookPoint->SectorId()));
    fast_msg.addField(new Messages::FieldIdentity("Indicate"),
		      Messages::FieldUInt32::create(sortBookPoint->Indicate()));
    fast_msg.addField(new Messages::FieldIdentity("SortType"),
		      Messages::FieldUInt32::create(sortBookPoint->SortDirection()));    

    encoder_.encodeMessage(des, sortRequest->getId(), fast_msg);
    des.toWorkingBuffer(wb);
    r = true;
  }

  msg.set_I('A'); //ipad
  msg.set_P('P'); //portable
  msg.set_body(wb.size(), (char*)wb.begin(), (char*)wb.end());
  return r;
}



void 
MessageBookPointConverter::MessageToBookPointVector(BDMessage& msg, 
						    vector< BookPointFieldItem >& book_point_vector)
	
{
  DEBUG_METHOD();
  // stringstream ss;
  // ss << "msg.body_length:" << msg.body_length();
  // std::cout << ss.str() << std::endl;

  Codecs::DataSourceBuffer source((unsigned char*)msg.body(), msg.body_length());
  Codecs::GenericMessageBuilder builder(consumer_);
  try {
        decoder_.reset();
        decoder_.decodeMessage(source, builder);
  }catch (QuickFAST::EncodingError error) {
        std::cout <<"get error for decode message: "<<error.what() << std::endl;
        return;
  }
  
  Messages::Message& fast_msg = consumer_.message();
  
  //BookPoint* bookPoint;
  TemplateFinder finder(registry_);
  template_id_t t_id = decoder_.getTopmostTemplateId();
  
  // stringstream s0;
  // s0 << "t_id: " << t_id << " scalarResponse template id: " << scalarResponse->getId();
  // std::cout << s0.str() << std::endl;

  if (t_id == scalarResponse->getId()){
    const StringBuffer* value;
    Messages::FieldIdentity code_field("Code");
    fast_msg.getString(code_field, ValueType::ASCII, value);
    std::string code(*value);

    uint64 indicate;
    Messages::FieldIdentity indicate_field("Indicate");
    fast_msg.getUnsignedInteger(indicate_field, ValueType::UINT32, indicate);
    
    // stringstream s1;
    // s1 << "code: " << code << " indicate: " << indicate;
    // std::cout << s1.str() << std::endl;
    BookPoint* bookPoint = new ScalarBookPoint(&finder, code, indicate);
    bookPoint =  new ScalarBookPoint(&finder, code, indicate);
    // std::cout << "received a bookpoint" << bookPoint->to_string() << std::endl;
    Messages::MessageField field = fast_msg[fast_msg.size() - 1];    
    //Messages::FieldCPtr msg_field(field.getField());
    BookPointPtr bookPointPtr(bookPoint);
    // std::cout << "converter scalar book point:" << bookPointPtr->to_string() << std::endl;
    BookPointFieldItem item(bookPointPtr, field);
    //item.bookpoint = bookPointPtr;
    //item.msg_field = field;
    book_point_vector.push_back(item);
  }
  else if (t_id == serialsResponse->getId()){
    const StringBuffer* value;
    Messages::FieldIdentity code_field("Code");
    fast_msg.getString(code_field, ValueType::ASCII, value);
    std::string code(*value);
    
    uint64 indicate;
    Messages::FieldIdentity indicate_field("Indicate");
    fast_msg.getUnsignedInteger(indicate_field, ValueType::UINT32, indicate);
    
    SerialsBookPoint* serials = new SerialsBookPoint(&finder, code, indicate);
    
    uint64 beginDate;
    Messages::FieldIdentity date_field("BeginDate");
    fast_msg.getUnsignedInteger(date_field, ValueType::UINT32, beginDate);
    
    uint64 beginTime;
    Messages::FieldIdentity time_field("BeginTime");
    fast_msg.getUnsignedInteger(time_field, ValueType::UINT32, beginTime);

    uint64 numberType;
    Messages::FieldIdentity type_field("NumberType");
    fast_msg.getUnsignedInteger(type_field, ValueType::UINT32, numberType);

    int64 numberFromBegin;
    Messages::FieldIdentity number_field("NumberFromBegin");
    fast_msg.getSignedInteger(number_field, ValueType::INT32, numberFromBegin);

    serials->set_BeginDate(beginDate);
    serials->set_BeginTime(beginTime);
    serials->set_NumberType((quotelib::SerialsNumberType)numberType);
    serials->set_NumberFromBegin(numberFromBegin);

    BookPoint* bookPoint = serials;
    Messages::MessageField field = fast_msg[fast_msg.size() - 1];
    //Messages::FieldCPtr msg_field(field.getField());
    BookPointPtr bookPointPtr(bookPoint);
    //item.bookpoint = bookPointPtr;
    //item.msg_field = field;
    BookPointFieldItem item(bookPointPtr, field);
    book_point_vector.push_back(item);
  }
  else if (t_id == sortResponse->getId()){
    uint64 sectorId;
    Messages::FieldIdentity sector_field("SectorId");
    fast_msg.getUnsignedInteger(sector_field, ValueType::UINT64, sectorId);

    uint64 indicate;
    Messages::FieldIdentity indicate_field("Indicate");
    fast_msg.getUnsignedInteger(indicate_field, ValueType::UINT32, indicate);

    uint64 sortType;
    Messages::FieldIdentity type_field("SortType");
    fast_msg.getUnsignedInteger(type_field, ValueType::UINT32, sortType);

    BookPoint* bookPoint = new SortBookPoint(&finder, sectorId, indicate, (quotelib::SortType)sortType);
    Messages::MessageField field = fast_msg[fast_msg.size() - 1];
    //Messages::FieldCPtr msg_field(field.getField());

    BookPointPtr bookPointPtr(bookPoint);
    //item.bookpoint = bookPointPtr;
    //item.msg_field = field;
    BookPointFieldItem item(bookPointPtr, field);
    book_point_vector.push_back(item);
  }
  else if (t_id == multiScalarResponse->getId()) {
    // std::cout << "received a multiScalarResponse" << std::endl;
    Messages::FieldIdentity code_sq_field("CodeSq");
    Messages::FieldIdentity indicate_sq_field("IndicateSq");
    Messages::FieldIdentity indicate_field("Indicate");
    Messages::FieldIdentity code_field("Code");
    
    Messages::FieldCPtr code_sq_f;
    // std::cout << "multiScalarResponse 1" << std::endl;
    bool r = fast_msg.getField(code_sq_field, code_sq_f);
    if (!r)
      return;
    // std::cout << "multiScalarResponse 2" << std::endl;
    const Messages::SequenceCPtr code_sq = code_sq_f->toSequence();
    // std::cout << "multiScalarResponse 2.1" << std::endl;
    for (Messages::Sequence::const_iterator it = code_sq->begin();
	 it != code_sq->end();
	 ++it){
      //code
      Messages::FieldSetCPtr code_sq_field_set = *it;
      // std::cout << "multiScalarResponse 3" << std::endl;
      const StringBuffer* value;
      code_sq_field_set->getString(code_field, ValueType::ASCII, value);      
      std::string code(*value);
      // std::cout << "multiScalarResponse code:" << code << std::endl;
      //idicate sequence
      Messages::FieldCPtr indicate_sq_f;
      code_sq_field_set->getField(indicate_sq_field, indicate_sq_f);
      
      const Messages::SequenceCPtr indicate_sq = indicate_sq_f->toSequence();
      for (Messages::Sequence::const_iterator indicate_it = indicate_sq->begin();
	   indicate_it != indicate_sq->end();
	   ++indicate_it){
	
	//indicate
	Messages::FieldSetCPtr indicate_sq_field_set = *indicate_it;
	uint64 indicate;
	indicate_sq_field_set->getUnsignedInteger(indicate_field, ValueType::UINT32, indicate);
	BookPoint* bookPoint = new ScalarBookPoint(&finder, code, indicate);
	BookPointPtr bookPointPtr(bookPoint);
	// std::cout << "multi response" << bookPointPtr->to_string() << std::endl;
	//data
	Messages::MessageField field = (*indicate_sq_field_set)[indicate_sq_field_set->size() - 1];
	BookPointFieldItem item(bookPointPtr, field);
	book_point_vector.push_back(item);
      }
    }
  }
  else{
    std::cerr << "unknow template response" << std::endl;
  }

  //BookPointPtr bookPointPtr(bookPoint);
  //return bookPointPtr;
}

// const Messages::FieldCPtr&
// MessageBookPointConverter::field()
// {
//   Messages::Message& msg = consumer_.message();
//   Messages::Message::const_iterator it = msg.end();
//   -- it;
//   const Messages::FieldIdentityCPtr& identity = it->getIdentity();
//   const Messages::FieldCPtr& field = it->getField();
  
//   return field;
// }




















