#include "FastComm.hpp"
#include "logging/DebugLog.hpp"

#include <boost/bind.hpp>
#include <boost/asio.hpp>
#include <boost/thread/thread.hpp>
#include <boost/asio.hpp>


using namespace quotelib;

DEBUG_USING_NAMESPACE

// FastComm::FastComm(boost::asio::io_service& io_service,
// 		   tcp::resolver::iterator endpoint_iterator)
//     : io_service_(io_service)
//     , socket_(io_service)
//     , strand_(io_service)
//     , read_msg_()
//     , write_msgs_()
//     , is_connected_(false)
      
// {
//     DEBUG_METHOD();
  
//     //std::cout << "async_connect" << std::endl;
//     boost::asio::async_connect(socket_, endpoint_iterator,
//                                boost::bind(&FastComm::handle_connect, this,
//                                            boost::asio::placeholders::error));

// }

FastComm::
FastComm(boost::asio::io_service& io_service,
         const std::string ip, const std::string port)
    : io_service_(io_service)
    , socket_(io_service)
    , strand_(io_service)
    , read_msg_()
    , write_msgs_()
    , is_connected_(false)

{
    DEBUG_METHOD();

    tcp::resolver resolver(io_service_);
    tcp::resolver::query query(ip, port);
    try {
        tcp::resolver::iterator iterator = resolver.resolve(query);
        boost::asio::async_connect(socket_, iterator,
                                   boost::bind(&FastComm::handle_connect, this,
                                               boost::asio::placeholders::error));
    } catch (const boost::system::system_error& e) {
        do_close(e.code(), "endpoint not found");
    }
    
}


FastComm::~FastComm()
{
    DEBUG_METHOD();
    do_close_socket();
}

void
FastComm::handle_connect(const boost::system::error_code& error)
{
    if (!error){
        //std::cout << "handle_connect" << std::endl;
        boost::asio::async_read(socket_,
                                boost::asio::buffer(read_msg_.data(), BDMessage::header_length),
                                boost::bind(&FastComm::handle_read_header, this,
                                            boost::asio::placeholders::error));
        is_connected_ = true;
        if (on_connect_socket_ != NULL)
            on_connect_socket_();
    }
    else
        is_connected_ = false;
}



void 
FastComm::handle_read_header(const boost::system::error_code& error)
{
    if (!error){
        if (read_msg_.size() < read_msg_.length() ){
            read_msg_.resize(read_msg_.length());
        }

        // stringstream ss;
        // ss << "read_msg_.length: " << read_msg_.length();
        // std::cout << ss.str() << std::endl;

        boost::asio::async_read(socket_,
                                boost::asio::buffer(read_msg_.body(), read_msg_.body_length()),
                                boost::bind(&FastComm::handle_read_body, this,
                                            boost::asio::placeholders::error));
    }
    else{
        do_close(error, "handle_read_header");
    }
}

void 
FastComm::handle_read_body(const boost::system::error_code& error)
{
    if (!error){
        //received a BDMessage
        if (on_receive_msg_ != NULL)
            on_receive_msg_(read_msg_);
    
        // stringstream ss;
        // ss << "try to read next message read_msg_.size:"<< read_msg_.size();
        // std::cout << ss.str() << std::endl;
        boost::asio::async_read(socket_,
                                boost::asio::buffer(read_msg_.data(), BDMessage::header_length),
                                boost::bind(&FastComm::handle_read_header, this,
                                            boost::asio::placeholders::error));
    }
    else {
        do_close(error, "handle_read_body");
    }
}

void
FastComm::do_write(BDMessage& msg)
{
    DEBUG_METHOD();
    // stringstream ss;
    // ss << "do_write data_length:" << msg.length() << 
    //   " data:" << msg.data();
    // std::cout << ss.str() << std::endl;

    strand_.post(boost::bind(&FastComm::write_impl, this , msg));
  
    // bool write_in_progress = !write_msgs_.empty();
    // write_msgs_.push_back(msg);
    // if (!write_in_progress){
    //   //std::cout << "do_write" << std::endl;
    //   boost::asio::async_write(socket_,
    // 			     boost::asio::buffer(write_msgs_.front().data(),
    // 						 write_msgs_.front().length()),
    // 			     boost::bind(&FastComm::handle_write, this,
    // 					 boost::asio::placeholders::error));
    //std::cout << "do_write1" << std::endl;      
    //}
}

void 
FastComm::write_impl(BDMessage& msg)
{
    write_msgs_.push_back(msg);
    if (write_msgs_.size() > 1){
        return;
    }
    do_async_write();
    // boost::asio::async_write(socket_,
    // 			   boost::asio::buffer(write_msgs_.front().data(),
    // 					       write_msgs_.front().length()),
    // 			   boost::bind(&FastComm::handle_write, this,
    // 				       boost::asio::placeholders::error));
}

void 
FastComm::handle_write(const boost::system::error_code& error)
{
    if (!error){
        write_msgs_.pop_front();
        // std::cout << "handle_write finished, pop_front msg" << std::endl;        
        if (!write_msgs_.empty()){
            do_async_write();
        }
    }
    else{
        do_close(error, "handle_write");
    }
}

void
FastComm::do_async_write()
{
    // stringstream ss;
    // ss << "handle_write data_length:" << write_msgs_.front().length() << 
    //   " data:" << write_msgs_.front().data();
    // std::cout << ss.str() << std::endl;
    boost::asio::async_write(socket_,
                             boost::asio::buffer(write_msgs_.front().data(),
                                                 write_msgs_.front().length()),
                             boost::bind(&FastComm::handle_write, this,
                                         boost::asio::placeholders::error));
  
}

void 
FastComm::do_close(const boost::system::error_code& error, const std::string msg)
{
    print_error(error, msg);
    if (on_error_ != NULL){
        on_error_(error, msg);
    }
    do_close_socket();
}

void
FastComm::do_close_socket()
{
    is_connected_ = false;
    boost::system::error_code ec;
    socket_.shutdown(boost::asio::ip::tcp::socket::shutdown_both, ec);
    if (ec){
        print_error(ec, "do_close_socket");
        if (on_error_ != NULL)
            on_error_(ec, "do_close_socket error");
    }
    socket_.close();
    io_service_.stop();
    if (on_close_socket_ != NULL)
        on_close_socket_();
}

void 
FastComm::print_error(const boost::system::error_code& error, const std::string msg)
{
    std::cerr << "do_close error_code:" << error << " message:" << error.message() 
              << " msg:" << msg << std::endl;
}

void 
FastComm::set_on_receive_msg(receive_msg_func func)
{
    on_receive_msg_ = func;
}

bool 
FastComm::is_connected()
{
    return is_connected_;
}

void 
FastComm::set_on_error(error_func func)
{
    on_error_ = func;
}

void 
FastComm::set_on_close_socket(event_func func)
{
    on_close_socket_ = func;
}

void 
FastComm::set_on_connect_socket(event_func func)
{
    on_connect_socket_ = func;
}
