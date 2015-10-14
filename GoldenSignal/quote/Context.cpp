#include "Context.hpp"
#include "GroupBookPoint.hpp"
#include "logging/DebugLog.hpp"
#include "Codecs/Template.h"

using namespace std;
using namespace quotelib;
using namespace QuickFAST;

DEBUG_USING_NAMESPACE

Context::Context(istream& template_stream)
{
    DEBUG_METHOD();

    //load template
    Codecs::XMLTemplateParser parser;
    registry_ = parser.parse(template_stream);
    broker = new MessageBroker(registry_);
    finder_ = new TemplateFinder(registry_);
}

Context::Context(istream& template_stream, const std::string ip, const std::string port)
{
    DEBUG_METHOD();

    //load template
    Codecs::XMLTemplateParser parser;
    registry_ = parser.parse(template_stream);
    broker = new MessageBroker(registry_, ip, port);
    finder_ = new TemplateFinder(registry_);
}

Context::~Context()
{
    DEBUG_METHOD();
    delete broker;
    delete finder_;
}

void
Context::sub(GroupBookPoint& group)
{
    DEBUG_METHOD();
    //todo: calculate diff
    broker->sub(group);
}


void
Context::unsub(GroupBookPoint& group)
{
    DEBUG_METHOD();
    //todo: calculate diff
    broker->unsub(group);
}

void
Context::sub_unsub(GroupBookPoint& subGroup, GroupBookPoint& unsubGroup)
{
    DEBUG_METHOD();
    broker->sub_unsub(subGroup, unsubGroup);
}


uint32
Context::get_indicate(string indicateName)
{
    Codecs::TemplatePtr t;
    if (registry_->findNamedTemplate(indicateName, "",  t)){
        return t->getId();
    }
    return -1;
}

string
Context::get_indicateName(uint32 indicate)
{
    Codecs::TemplateCPtr t;
    if (registry_->getTemplate(indicate, t)) {
        return t->getTemplateName();
    }
    return "";
}


void 
Context::set_on_receive_bookpoint(receive_bookpoint_func func)
{
    broker->set_on_receive_bookpoint(func);
}

void 
Context::heartbeat()
{
    broker->heartbeat();
}

bool
Context::is_connected()
{
    return broker->is_connected();
}

void 
Context::set_on_error(error_func func)
{
    broker->set_on_error(func);
}

void 
Context::set_on_close_socket(event_func func)
{
    broker->set_on_close_socket(func);
}

void 
Context::set_on_connect_socket(event_func func)
{
    broker->set_on_connect_socket(func);
}
