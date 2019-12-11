(:~
 : Startpage
 : @version 1.3
 : @author Florian Eckey, Katharina Großer
 : @license Copyright (C) 2015-2019
 :  This program is free software: you can redistribute it and/or modify
 :  it under the terms of the GNU General Public License as published by
 :  the Free Software Foundation, version 3 of the License.
 :
 :  This program is distributed in the hope that it will be useful,
 :  but WITHOUT ANY WARRANTY; without even the implied warranty of
 :  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 :  GNU General Public License for more details.
 :
 :  You should have received a copy of the GNU General Public License
 :  along with this program.  If not, see <https://www.gnu.org/licenses/>.
:)
module namespace page = 'masterthesis/modules/web-page';

import module namespace ui = 'masterthesis/modules/ui-manager';

(:~
 : Redirects generic http request to default English start page
 : @return redirect to English startpage
 :)
declare
  %rest:path("care-webapp")
  updating function page:redirectstart() {
    db:output(<restxq:redirect>/care-webapp/en</restxq:redirect>)
};

(:~
 : Calls function to generate start page with language attribute
 : @return call of start page generator
 :)
declare
  %rest:path("care-webapp/{$lng}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:care($lng)
  as element(Q{http://www.w3.org/1999/xhtml}html) {
    page:start($lng)
};

(:~
 : Generates (X)HTML content of start page
 : @return start page (X)HTML
 :)
declare
  %rest:path("care/{$lng}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start($lng)
  as element(Q{http://www.w3.org/1999/xhtml}html) {
    ui:page($lng,
      <div class="container">
          <div class="login">
            <div class="login-screen" style="width:81.3%;font-size:1.5em">
              <span data-i18n="home.welcome"></span> <span class="brand" data-i18n="brand"></span> ... 
               
               <div style="font-size:13pt">
               <span data-i18n="home.system"></span>
               
                <a href="{$ui:prefix}/requirements-manager/{$lng}" style="color:green" data-i18n="[html]home.go"></a>
               </div>
               <div style="font-size:13pt">
                <a href="{$ui:prefix}/setup/{$lng}" style="color:green" data-i18n="home.loadndelete"></a>
               </div>
               <div style="font-size:13pt">
                <a href="{$ui:prefix}/inspection/{$lng}" style="color:green" data-i18n="home.docs"></a><br/>
                
                <span data-i18n="[html]home.authors"></span><br/>
                </div>
                 
            </div>
          </div>
      </div>)
};

(:~
 : REST call to initalize database
 : @return redirect to start page
 :)
declare
  %rest:path("setup/{$lng}")
  updating function page:setup($lng) {
    db:create("care-packages"),
    db:create("inspection",<Inspections xmlns="inspections"/>,"inspections.xml"),
    db:create("glossary",<Glossary xmlns="glossary"/>,"glossary.xml"),
    db:output(<restxq:redirect>/care/{$lng}</restxq:redirect>)
  };

(:~
 : REST call to delete database
 : @return redirect to start page
 :)
declare
  %rest:path("setup/drop/{$lng}")
  updating function page:setup-drop($lng) {
    db:drop("care-packages"),
    db:drop("inspectiosn"),
    db:drop("glossary"),
    db:output(<restxq:redirect>/care/{$lng}</restxq:redirect>)
  };