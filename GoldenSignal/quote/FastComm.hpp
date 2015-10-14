#ifndef _FASTCOMM_H_
#define _FASTCOMM_H_

#include "BDMessage.hpp"
//#include "Endianness.hpp"
#include <deque>
#include <boost/bind.hpp>
#include <boost/function.hpp>
#include <boost/asio.hpp>


using boost::asio::ip::tcp;
namespace quotelib
{
    typedef std::deque<BDMessage> message_queue;
    typedef boost::function<void (BDMessage& msg)> receive_msg_func;
    typedef boost::function<void (const boost::system::error_code& error, const std::string msg)> error_func;
    typedef boost::function<void (void)> event_func;
    class FastComm
    {
    public:
        // FastComm(boost::asio::io_service& io_service, 
        //          tcp::resolver::iterator endpoint_iterator);
        FastComm(boost::asio::io_service& io_service,
                 const std::string ip, const std::string port);
        virtual ~FastComm();
        
        void do_write(BDMessage& msg);
        void set_on_receive_msg(receive_msg_func func);
        bool is_connected();
        void set_on_error(error_func func);
        void set_on_close_socket(event_func func);
        void set_on_connect_socket(event_func func);
    private:
        void write_impl(BDMessage& msg);
        void handle_connect(const boost::system::error_code& error);
        void handle_read_header(const boost::system::error_code& error);
        void handle_read_body(const boost::system::error_code& error);
        void handle_write(const boost::system::error_code& error);
        void do_close(const boost::system::error_code& error, const std::string msg = "");
        void print_error(const boost::system::error_code& error, const std::string msg = "");
        void do_close_socket();
        void do_async_write();
    private:
        boost::asio::io_service& io_service_;
        tcp::socket socket_;
        boost::asio::io_service::strand strand_;
        BDMessage read_msg_;
        message_queue write_msgs_;

        receive_msg_func on_receive_msg_;
        bool is_connected_;
        error_func on_error_;
        event_func on_close_socket_;
        event_func on_connect_socket_;
    };
}

#endif /* _FASTCOMM_H_ */
