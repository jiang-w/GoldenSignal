#include "MessageBroker.hpp"
#include "FastComm.hpp"
#include <algorithm>
#include "logging/DebugLog.hpp"


using namespace quotelib;
using namespace std;
using namespace QuickFAST;

DEBUG_USING_NAMESPACE

MessageBroker::MessageBroker(Codecs::TemplateRegistryPtr registry)
    : io_service_()
    , registry_(registry)
    , converter_(registry)
    , heartbeat_timer_(io_service_, boost::posix_time::seconds(10))
    , formater_(std::cout)
{
    DEBUG_METHOD();
    // tcp::resolver resolver(io_service_);
    // tcp::resolver::query query("q2.chinabigdata.com", "443");
    // tcp::resolver::iterator iterator = resolver.resolve(query);
    // fastcomm = new FastComm(io_service_, iterator);
    const std::string ip = "q1.chinabigdata.com";
    const std::string port = "443";
    fastcomm = new FastComm(io_service_, ip, port);
    fastcomm->set_on_receive_msg(boost::bind(&MessageBroker::handle_receive_msg, this, _1));

    heartbeat_timer_.async_wait(boost::bind(&MessageBroker::handle_heartbeat_timer,
                                            this, 
                                            boost::asio::placeholders::error));

    t = new boost::thread(boost::bind(&boost::asio::io_service::run, &io_service_));
}

MessageBroker::MessageBroker(Codecs::TemplateRegistryPtr registry, const std::string ip, const std::string port)
    : io_service_()
    , registry_(registry)
    , converter_(registry)
    , heartbeat_timer_(io_service_, boost::posix_time::seconds(10))
    , formater_(std::cout)
{
    DEBUG_METHOD();
    // tcp::resolver resolver(io_service_);
    // tcp::resolver::query query(ip, port);
    // tcp::resolver::iterator iterator = resolver.resolve(query);
    fastcomm = new FastComm(io_service_, ip, port);
    fastcomm->set_on_receive_msg(boost::bind(&MessageBroker::handle_receive_msg, this, _1));

    heartbeat_timer_.async_wait(boost::bind(&MessageBroker::handle_heartbeat_timer,
                                            this, 
                                            boost::asio::placeholders::error));

    t = new boost::thread(boost::bind(&boost::asio::io_service::run, &io_service_));
}


MessageBroker::~MessageBroker()
{
    DEBUG_METHOD();
    delete t;
    delete fastcomm;
}

void
MessageBroker::sub(quotelib::GroupBookPoint &group)
{
    //convert bookpoint to BDMessage
    DEBUG_METHOD();

    try {
        vector<BDMessage> msgs;
        converter_.GroupMessageToSubMessage(group, msgs);
        // std::cout << "sub message size: "<< msgs.size() << std::endl;
        for(vector<BDMessage>::iterator i = msgs.begin(), end = msgs.end();
            i != end; ++ i){
            fastcomm->do_write(*i);
            last_send_ = boost::posix_time::second_clock::local_time();
        }
    }
    catch(exception& e){
        std::cerr << "sub error: " << e.what() << std::endl;
    }
}

void 
MessageBroker::unsub(quotelib::GroupBookPoint &group)
{
    //convert bookpoint to BDMessage
    DEBUG_METHOD();

    try {
        vector<BDMessage> msgs;
        converter_.GroupMessageToUnSubMessage(group, msgs);
        // std::cout << "unsub message size: "<< msgs.size() << std::endl;
        for(vector<BDMessage>::iterator i = msgs.begin(), end = msgs.end();
            i != end; ++ i){
            fastcomm->do_write(*i);    
            last_send_ = boost::posix_time::second_clock::local_time();
        }
    }
    catch(exception& e){
        std::cerr << "unsub error: " << e.what() << std::endl;
    }
}

void 
MessageBroker::sub_unsub(GroupBookPoint& subGroup, GroupBookPoint& unsubGroup)
{
    DEBUG_METHOD();
    try {
        vector<BDMessage> msgs;
        converter_.GroupBookPointToMessages(subGroup, unsubGroup, msgs);
        for(vector<BDMessage>::iterator i = msgs.begin(), end = msgs.end();
            i != end; ++ i){
            fastcomm->do_write(*i);    
            last_send_ = boost::posix_time::second_clock::local_time();
        }
    }
    catch(exception& e){
        std::cerr << "sub_unsub error: " << e.what() << std::endl;
    }
}

void 
MessageBroker::handle_receive_msg(BDMessage& msg)
{
    //received a BDMessage
    //  std::cout << "received a BDMessage" << std::endl;
    //dcode to fastmessage
    //BookPointPtr bookPoint = converter_.MessageToBookPoint(msg);
    //  const Messages::FieldCPtr field = converter_.field();
    //  formater_.formatMessage(converter_.message());
    //  std::cout << bookPoint->to_string() << std::endl;

    //if (on_receive_bookpoint_ != NULL)
    //  on_receive_bookpoint_(*bookPoint, converter_.message()); 

    vector< BookPointFieldItem > book_point_vector;
    converter_.MessageToBookPointVector(msg, book_point_vector);
    vector< BookPointFieldItem >::iterator i;
    if (on_receive_bookpoint_ != NULL){
        for (i = book_point_vector.begin(); i != book_point_vector.end(); ++ i) {
            BookPointFieldItem item = *i;
            BookPointPtr bookPoint = item.getBookPoint();
            QuickFAST::Messages::MessageField msg_field = item.getMessageField();
            string s = bookPoint->to_string();
            // std::cout<< "dispach message in broker:" << s << std::endl;
            on_receive_bookpoint_(bookPoint, msg_field);
        }
    }
}


void
MessageBroker::set_on_receive_bookpoint(receive_bookpoint_func func)
{
    on_receive_bookpoint_ = func;
}

void 
MessageBroker::handle_heartbeat_timer(const boost::system::error_code &e)
{
    heartbeat();
    heartbeat_timer_.expires_at(heartbeat_timer_.expires_at() + boost::posix_time::seconds(15));
    heartbeat_timer_.async_wait(boost::bind(&MessageBroker::handle_heartbeat_timer,
                                            this, 
                                            boost::asio::placeholders::error));  
}

void
MessageBroker::heartbeat()
{
    //send heartbeat
    DEBUG_METHOD();
    BDMessage heartbeat;
    converter_.EncodeHeartbeat(heartbeat);
    fastcomm->do_write(heartbeat);  
}

bool
MessageBroker::is_connected()
{
    return fastcomm->is_connected();
}

void 
MessageBroker::set_on_error(error_func func)
{
    fastcomm->set_on_error(func);
}

void 
MessageBroker::set_on_close_socket(event_func func)
{
    fastcomm->set_on_close_socket(func);
}

void 
MessageBroker::set_on_connect_socket(event_func func)
{
    fastcomm->set_on_connect_socket(func);
}
