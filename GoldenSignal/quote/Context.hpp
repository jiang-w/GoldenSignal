#ifndef _CONTEXT_H_
#define _CONTEXT_H_

#include "MessageBroker.hpp"
#include "GroupBookPoint.hpp"
#include "Codecs/TemplateRegistry.h"
#include "TemplateFinder.hpp"

using namespace std;
using namespace QuickFAST;

namespace quotelib
{
    class Context
    {
    public:
        Context(istream& template_stream);
        Context(istream& template_stream, const std::string ip, const std::string port);
        virtual ~Context();

        //subscribe bunch of bookpoints
        void sub(GroupBookPoint& group);
        //unsubscribe bunch of bookpoints
        void unsub(GroupBookPoint& group);
        void sub_unsub(GroupBookPoint& subGroup, GroupBookPoint& unsubGroup);
        void heartbeat();
        uint32 get_indicate(string indicateName);
        string get_indicateName(uint32 indicate);
    
        Codecs::TemplateRegistryPtr registry()
        {
            return registry_;
        }

        TemplateFinder* finder()
        {
            return finder_;
        }
        

        void set_on_receive_bookpoint(receive_bookpoint_func func);
        bool is_connected();
        void set_on_error(error_func func);
        void set_on_close_socket(event_func func);
        void set_on_connect_socket(event_func func);
    private:
        MessageBroker* broker;
        Codecs::TemplateRegistryPtr registry_;
        TemplateFinder* finder_;
    };
  
}

#endif /* _CONTEXT_H_ */















