//a helper class to translate between indicate and indicateName

#ifndef _TEMPLATEFINDER_H_
#define _TEMPLATEFINDER_H_

#include "Codecs/TemplateRegistry.h"

using namespace std;
using namespace QuickFAST;

namespace quotelib
{
  class TemplateFinder
  {
  public:
    TemplateFinder(Codecs::TemplateRegistryPtr& registry);
    virtual ~TemplateFinder();

    uint32 get_indicate(string indicateName);
    string get_indicateName(uint32 indicate);
    
  private:
    Codecs::TemplateRegistryPtr registry_;
  };
  
}

#endif /* _TEMPLATEFINDER_H_ */
