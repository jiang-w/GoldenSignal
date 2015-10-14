#include "TemplateFinder.hpp"
#include "Codecs/TemplateRegistry.h"
#include "Codecs/Template.h"

using namespace std;
using namespace quotelib;
using namespace QuickFAST;


TemplateFinder::TemplateFinder(Codecs::TemplateRegistryPtr& registry)
  : registry_(registry)
{
  
}

TemplateFinder::~TemplateFinder()
{

}

uint32
TemplateFinder::get_indicate(string indicateName)
{
  Codecs::TemplatePtr t;
  if (registry_->findNamedTemplate(indicateName, "",  t)){
    return t->getId();
  }
  return -1;
}

string
TemplateFinder::get_indicateName(uint32 indicate)
{
  Codecs::TemplateCPtr t;
  if (registry_->getTemplate(indicate, t)) {
    return t->getTemplateName();
  }
  return "";
}
