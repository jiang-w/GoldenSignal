#ifndef _MESSAGEBROKER_H_
#define _MESSAGEBROKER_H_

#include "GroupBookPoint.hpp"
#include "MessageBookPointConverter.hpp"
#include "FastComm.hpp"
#include <boost/thread.hpp>
#include <boost/asio.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include "Messages/MessageFormatter.h"
#include "Codecs/TemplateRegistry.h"
#include "Codecs/Decoder.h"

using namespace QuickFAST;

namespace quotelib
{
    typedef boost::function<void (BookPointPtr& bookPoint, Messages::MessageField& msg_field)> receive_bookpoint_func;
    class MessageBroker
    {
    public:
        MessageBroker(Codecs::TemplateRegistryPtr registry);
        MessageBroker(Codecs::TemplateRegistryPtr registry, const std::string ip, const std::string port);
        virtual ~MessageBroker();
        //subscrib to the send buffer
        void sub(GroupBookPoint& group);
        //unsubscrib to the send buffer
        void unsub(GroupBookPoint& group);
        void sub_unsub(GroupBookPoint& subGroup, GroupBookPoint& unsubGroup);
        void set_on_receive_bookpoint(receive_bookpoint_func func);
        void heartbeat();
        bool is_connected();
        void set_on_error(error_func func);
        void set_on_close_socket(event_func func);
        void set_on_connect_socket(event_func func);
    private:
        void handle_receive_msg(BDMessage& msg);
        void handle_heartbeat_timer(const boost::system::error_code& e);
    private:
        boost::asio::io_service io_service_;
        Codecs::TemplateRegistryPtr registry_;
        MessageBookPointConverter converter_;
        Messages::MessageFormatter formater_;
        boost::thread* t;
        boost::asio::deadline_timer heartbeat_timer_;
        boost::posix_time::ptime last_send_;
        FastComm* fastcomm;
        receive_bookpoint_func on_receive_bookpoint_;
    };
}

#endif /* _MESSAGEBROKER_H_ */
















