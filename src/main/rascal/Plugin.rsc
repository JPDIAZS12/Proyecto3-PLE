module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;

import Syntax;

PathConfig pcfg = getProjectPathConfig(|project://dsl-project|);

Language veriLang = language(pcfg, "VeriLang", "vlang", "Plugin", "contribs");

set[LanguageService] contribs() = {
  parser(start[Program] (str program, loc src) {
    return parse(#start[Program], program, src);
  })
};

void main() {
  registerLanguage(veriLang);
}